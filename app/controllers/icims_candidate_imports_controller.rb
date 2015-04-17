class IcimsCandidateImportsController < ApplicationController
  skip_before_filter :require_login

  def create
    candidate = Icims::Client.new(connection: connection).candidate(person_id)
    import = namely_importer.single_import(candidate)

    if import.success?
      mailer.delay.successful_import(user, candidate)
    else
      mailer.delay.unsuccessful_import(user, candidate, import)
    end
    render text: nil
  end

  private

  def namely_importer
    NamelyImporter.new(
      namely_connection: user.namely_connection,
      attribute_mapper: Icims::AttributeMapper.new,
    )
  end

  def mailer
    IcimsCandidateImportMailer
  end

  def connection
    Icims::Connection.find_by(customer_id: customer_id)
  end

  def user
    connection.user
  end

  def customer_id
    params[:data][:customerId]
  end

  def person_id
    params[:data][:personId]
  end
end