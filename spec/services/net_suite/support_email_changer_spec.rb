require_relative "../../../app/services/net_suite/support_email_changer"

describe NetSuite::SupportEmailChanger do
  subject(:changed_message) { described_class.new(message: message).call }
  describe "#to_s" do
    context "when the message contains an email at the beginning" do
      let(:message) { "email@from.com blah blah blah" }
      it "change the email to the proper support email" do
        expect(changed_message).to eql "api@namely.com blah blah blah"
      end
    end

    context "when the email is in the middle" do
      let(:message) { "The registering of the partner failed. Please contact support@cloud-elements.com to get setup as a partner." }
      it "change the email to the proper support email" do
        expect(changed_message).to eql "The registering of the partner failed. Please contact api@namely.com to get setup as a partner."
      end

    end

    context "when the email is at the end of the message" do
      let(:message) { "blah blah email@from.com" }
      it "change the email to the proper support email" do
        expect(changed_message).to eql "blah blah api@namely.com"
      end
    end
  end
end

