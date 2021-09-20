class Action
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :event

  field :kind, type: String
  field :success, type: Boolean, default: nil
  field :response_status, type: String
  field :incoming_payload, type: Hash, default: {}
  field :outgoing_payload, type: Hash, default: {}
  field :exception, type: Hash, default: {}
  field :reason, type: String
  field :url, type: String

end
