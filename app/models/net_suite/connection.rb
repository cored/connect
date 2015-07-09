class NetSuite::Connection < ActiveRecord::Base
  belongs_to :user

  validates :subsidiary_id, presence: true, allow_nil: true

  def integration_id
    :net_suite
  end

  def allowed_parameters
    [:subsidiary_id]
  end

  def connected?
    instance_id.present? && authorization.present?
  end

  def enabled?
    ENV["CLOUD_ELEMENTS_ORGANIZATION_SECRET"].present?
  end

  def ready?
    subsidiary_id.present?
  end

  def required_namely_field
    :netsuite_id
  end

  def subsidiaries
    client.
      subsidiaries.
      map { |subsidiary| [subsidiary["name"], subsidiary["internalId"]] }
  end

  def sync
    NetSuite::Export.new(
      configuration: self,
      namely_profiles: user.namely_profiles.all,
      net_suite: client
    ).perform
  end

  def client
    NetSuite::Client.from_env(user).authorize(authorization)
  end

  def disconnect
    update!(instance_id: nil, authorization: nil)
  end
end
