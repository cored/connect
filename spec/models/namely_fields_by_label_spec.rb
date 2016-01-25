require_relative "../../app/models/namely_fields_by_label"

describe NamelyFieldsByLabel do
  subject(:namely_fields_by_label) do
    described_class.new(namely_fields: namely_fields)
  end
  let(:namely_fields) { [["First Name", "first_name"]] }

  describe "#to_a" do
    it "appends netsuite supervisor id to the standard fields from Namely" do
      expect(namely_fields_by_label.to_a).to eql [
        ["First Name", "first_name"],
        ["Supervisor NetSuite Id", "netsuite_supervisor_id"]
      ]
    end
  end

  describe "#disable_namely_fields" do
    it "returns the names of all namely fields" do
      expect(
        namely_fields_by_label.disable_namely_fields
      ).to eql ["first_name"]
    end
  end

  describe "#is_disable_field?" do
    let(:field_to_disable) { "netsuite_supervisor_id" }
    context "when the field name is marked for be disabled" do
      it "returns true" do
        expect(namely_fields_by_label).to be_is_disable_field(field_to_disable)
      end
    end

    context "when the field name is not marked for be disabled" do
      it "returns false" do
        expect(namely_fields_by_label).not_to be_is_disable_field("non_field")
      end
    end
  end
end
