class NetSuite::Normalizer
  GENDER_MAP = {
    "Male" => "_male",
    "Female" => "_female",
    "Not specified" => "_omitted",
  }
  GENDER_MAP.default = "_omitted"

  delegate :field_mappings, to: :attribute_mapper
  delegate :mapping_direction, to: :attribute_mapper
  delegate :persisted?, to: :attribute_mapper

  def initialize(attribute_mapper:, configuration:)
    @attribute_mapper = attribute_mapper
    @configuration = configuration
  end

  def export(profile)
    attributes = attribute_mapper.export(profile)
    Export.new(attributes, @configuration.subsidiary_id).to_hash
  end

  private

  class Export
    def initialize(attributes, subsidiary_id)
      @attributes = attributes
      @subsidiary_id = subsidiary_id
    end

    def to_hash
      mapped_attributes.merge(string_attributes)
    end

    private

    def mapped_attributes
      @mapped_attributes ||= {
        "gender" => gender,
        "isInactive" => user_status,
        "subsidiary" => subsidiary,
        "customFieldList" => custom_fields
      }
    end

    def string_attributes
      string_keys.each_with_object({}) do |(key, value), result|
        result[key] = value.to_s
      end
    end

    def string_keys
      @attributes.
        except(*mapped_attributes.keys).
        except(*custom_keys(@attributes))
    end

    def gender
      GENDER_MAP[@attributes["gender"].to_s]
    end

    def user_status
      @attributes["isInactive"].to_s == "inactive"
    end

    def subsidiary
      { "internalId" => @subsidiary_id }
    end

    def custom_keys(attributes)
      attributes.keys.grep(/^custom:/)
    end

    def custom_fields
      custom_field_values = custom_keys(@attributes).map do |key|
        (_, internal_id, script_id) = key.split(":", 3)
        {
          "internalId" => internal_id,
          "scriptId" => script_id,
          "value" => @attributes[key].to_s,
        }
      end
      { "customField" => custom_field_values }
    end
  end

  private_constant :Export
  attr_reader :attribute_mapper
end
