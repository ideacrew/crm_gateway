# frozen_string_literal: true

module Transmittable
  # Represents a persisted error for transmittable objects. This class includes functionality
  # for timestamping and supports polymorphic associations to various errorable entities.
  class Error
    include Mongoid::Document
    include Mongoid::Timestamps

    # @!attribute [rw] errorable
    #   @return [Mongoid::Document] Polymorphic association to the object that the error belongs to.
    belongs_to :errorable, polymorphic: true, inverse_of: :errorable, index: true

    # @!attribute [rw] key
    #   @return [Symbol] A symbol representing the error key or type.
    field :key, type: Symbol

    # @!attribute [rw] message
    #   @return [String] The error message describing what went wrong.
    field :message, type: String
  end
end
