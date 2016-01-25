class NamelyFieldsByLabel
  DISABLE_FIELDS = [
    ["Supervisor NetSuite Id", "netsuite_supervisor_id"]
  ]
  def initialize(namely_fields:)
    @namely_fields = namely_fields
  end

  def to_a
    namely_fields + DISABLE_FIELDS
  end

  def is_disable_field?(namely_field_name)
    DISABLE_FIELDS.map do |disable_field|
      disable_field.last
    end.include?(namely_field_name)
  end

  def disable_namely_fields
    namely_fields.map { |namely_field_tuple| namely_field_tuple.last }
  end

  private

  attr_reader :namely_fields
end
