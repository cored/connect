require "rails_helper"

describe Icims::Connection do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "#connected?" do
    it "returns true when the username and password are set" do
      icims_connection = described_class.new(
        username: "username",
        password: "password",
      )

      expect(icims_connection).to be_connected
    end

    it "returns false when the username or password is missing" do
      expect(described_class.new).not_to be_connected
      expect(described_class.new(username: "username")).not_to be_connected
      expect(described_class.new(password: "password")).not_to be_connected
    end
  end

  describe "#disconnect" do
    it "sets the username and password to nil" do
      icims_connection = create(
        :icims_connection,
        username: "crashoverride",
        password: "riscisgood",
      )

      icims_connection.disconnect

      expect(icims_connection.username).to be_nil
      expect(icims_connection.password).to be_nil
    end
  end
end
