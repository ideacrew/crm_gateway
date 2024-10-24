# frozen_string_literal: true

module Operations
  module SugarCRM
    # Compares a local family account with its corresponding SugarCRM account to determine
    # if the local account is stale, and if so, what updates are necessary.
    #
    # This operation follows a series of steps to validate input parameters, fetch the eligible
    # subject (family), check if the account is stale, fetch previous CRM account details,
    # compare accounts and contacts, and finally create a comparison object based on the comparison
    # results.
    #
    # @example
    #   Operations::SugarCRM::CompareRequest.new.call(params)
    #
    class CompareRequest
      include Dry::Monads[:do, :result]

      # Initiates the comparison process.
      #
      # @param params [Hash] The parameters required for the comparison operation.
      # @option params [DateTime] :after_updated_at The timestamp after which updates are considered.
      # @option params [Family] :family The family object to compare.
      #
      # @return [Dry::Monads::Result] The result of the comparison operation, either a success or failure.
      def call(params = {})
        after_updated_at, family, force_sync = yield validate(params)
        eligible_subject                     = yield fetch_eligible_subject(family, force_sync)
        is_stale                             = yield check_stale(after_updated_at, eligible_subject)
        previous_crm_account                 = yield fetch_previous_crm_account(eligible_subject, is_stale)
        sugar_account                        = yield fetch_sugar_account(previous_crm_account, family, is_stale)
        comparison_params                    = yield compare_accounts_and_contacts(family, sugar_account, previous_crm_account, is_stale)
        comparison_object                    = yield create_comparison_object(comparison_params)

        Success(comparison_object)
      end

      private

      # Validates the input parameters for presence and correctness.
      #
      # @param params [Hash] The parameters to validate.
      # @return [Dry::Monads::Result] Success if valid, failure otherwise.
      def validate(params)
        return Failure('a valid after_updated_at is required') unless params[:after_updated_at].is_a?(Time)
        return Failure('a valid family is required') unless params[:family].is_a?(::Family)

        Success([params[:after_updated_at], params[:family], params[:force_sync]])
      end

      # Fetches the eligible subject for comparison based on the family details.
      #
      # @param family [Family] The family object to find the eligible subject for.
      # @return [Dry::Monads::Result] Success with the eligible subject, or nil if not found.
      def fetch_eligible_subject(family, force_sync: false)
        return Success(nil) if force_sync
        families = ::Family.by_family_and_primary_person_hbx_id(
          family.family_hbx_id,
          family.primary_person_hbx_id
        ).where(:id.ne => family.id)

        return Success(nil) if families.blank?

        transaction = ::Transmittable::Transaction.where(
          :transactable_id.in => families.pluck(:id)
        ).newest.first

        # transactable is subject i.e. family
        Success(transaction&.transactable)
      end

      # Checks if the eligible subject is stale based on the provided timestamp.
      #
      # @param after_updated_at [DateTime] The timestamp to compare against.
      # @param eligible_subject [Family] The subject to check for staleness.
      # @return [Dry::Monads::Result] Success with boolean indicating if the subject is stale.
      def check_stale(after_updated_at, eligible_subject)
        return Success(false) if eligible_subject.blank?

        return Success(false) if eligible_subject.updated_at.blank?

        Success(
          eligible_subject.inbound_after_updated_at > after_updated_at
        )
      end

      # Fetches the previous CRM account for the eligible subject if it's not stale.
      #
      # @param eligible_subject [Family] The subject to fetch the CRM account for.
      # @param is_stale [Boolean] Indicates if the subject is stale.
      # @return [Dry::Monads::Result] Success with the previous CRM account, or nil if not applicable.
      def fetch_previous_crm_account(eligible_subject, is_stale)
        return Success(nil) if is_stale || eligible_subject.blank?

        Success(eligible_subject.outbound_account_entity)
      end

      # Fetches the SugarCRM account for the family unless it's stale or a previous CRM account exists.
      #
      # @param previous_crm_account [Account] The previous CRM account, if any.
      # @param family [Family] The family to fetch the CRM account for.
      # @param is_stale [Boolean] Indicates if the subject is stale.
      # @return [Dry::Monads::Result] Success with the SugarCRM account, or nil if not applicable.
      def fetch_sugar_account(previous_crm_account, family, is_stale)
        return Success(nil) if is_stale || previous_crm_account.present?

        Operations::SugarCRM::FetchAccount.new.call(
          { account_hbx_id: family.primary_person_hbx_id }
        )
      end

      # Compares the accounts and contacts to determine the action for each eligible object.
      #
      # @param family [Family] The family involved in the comparison.
      # @param sugar_account [Account] The SugarCRM account to compare against.
      # @param previous_crm_account [Account] The previous CRM account, if any.
      # @param is_stale [Boolean] Indicates if the subject is stale.
      # @return [Dry::Monads::Result] Success with the comparison parameters.
      def compare_accounts_and_contacts(family, sugar_account, previous_crm_account, is_stale)
        current_account = family.outbound_account_entity
        return Success(construct_stale_account_comparison_params(current_account)) if is_stale

        comparable_account = previous_crm_account || sugar_account
        compare_info = {}
        compare_info[:account_hbx_id] = current_account.hbxid_c
        compare_info[:account_action] = fetch_account_action(current_account, comparable_account)
        compare_info[:contacts] = []
        current_account.contacts.each do |contact|
          comparable_contact = comparable_account&.contacts&.detect { |c| c.hbxid_c == contact.hbxid_c }
          compare_info[:contacts] << fetch_contact_action(contact, comparable_contact)
        end

        compare_info[:action] = fetch_comparison_action(compare_info)

        Success(compare_info)
      end

      # Returns comparison params for :stale action.
      #
      # @param account [Account] The account to be marked as stale.
      # @return [Hash] A hash containing the stale comparison details.
      def construct_stale_account_comparison_params(account)
        {
          action: :stale,
          account_hbx_id: account.hbxid_c,
          account_action: :stale,
          contacts: account.contacts.map { |c| { hbx_id: c.hbxid_c, action: :stale } }
        }
      end

      # Determines the overall comparison action based on account and contact actions.
      #
      # @param compare_info [Hash] The comparison information including account and contacts actions.
      # @return [Symbol] The overall comparison action (:noop, :create, :update, :create_and_update).
      def fetch_comparison_action(compare_info)
        if compare_info[:account_action] == :noop && compare_info[:contacts].all? { |c| c[:action] == :noop }
          :noop
        elsif compare_info[:account_action] == :create && compare_info[:contacts].all? { |c| c[:action] == :create }
          :create
        elsif compare_info[:account_action] == :update && compare_info[:contacts].all? { |c| c[:action] == :update }
          :update
        else
          :create_and_update
        end
      end

      # Determines the action for the account based on comparison with a CRM account.
      #
      # @param current_account [Account] The current account to compare.
      # @param comparable_account [Account] The CRM account to compare against.
      # @return [Symbol] The action for the account (:noop, :create, :update).
      def fetch_account_action(current_account, comparable_account)
        return :create if comparable_account.blank?

        current_account.account_same_as?(comparable_account) ? :noop : :update
      end

      # Determines the action for each contact based on comparison with CRM contacts.
      #
      # @param contact [Contact] The contact to compare.
      # @param comparable_contact [Contact] The CRM contact to compare against.
      # @return [Hash] The action for the contact (:noop, :create, :update) with hbx_id of a person/family_member.
      def fetch_contact_action(contact, comparable_contact)
        return { hbx_id: contact.hbxid_c, action: :create } if comparable_contact.blank?

        if contact.contact_same_as?(comparable_contact)
          { hbx_id: contact.hbxid_c, action: :noop }
        else
          { hbx_id: contact.hbxid_c, action: :update }
        end
      end

      # Creates a comparison object based on the comparison parameters.
      #
      # @param comparison_params [Hash] The parameters resulting from the comparison.
      # @return [Dry::Monads::Result] Success with the comparison object.
      def create_comparison_object(comparison_params)
        ::Operations::AccountComparison::Create.new.call(comparison_params)
      end
    end
  end
end
