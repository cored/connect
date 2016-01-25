require "rails_helper"

feature "User view supervisor netsuite field mapping" do
  scenario "successfully" do
    user = create(:user)
    cloud_elements = "https://api.cloud-elements.com/elements/api-v2/hubs/erp"
    subsidiary_url = "#{cloud_elements}/lookups/subsidiary"
    subsidiary_id = 52

    employee_json =
      File.read("spec/fixtures/api_responses/net_suite_employee.json")

    stub_request(:get, %r{#{cloud_elements}/employees\?pageSize=5}).
      to_return(status: 200, body: employee_json)

    stub_request(
      :get,
      "#{cloud_elements}/employees?where=subsidiary%3D#{subsidiary_id}"
    ).to_return(
      body: [
        {internalId: "1234", firstName: "TT"},
      ].to_json
    )
    stub_namely_data("/profiles", "profiles_with_net_suite_fields")
    stub_request(:put, %r{.*api/v1/profiles/.*}).to_return(status: 200)
    stub_request(:post, "#{cloud_elements}/employees").
      with(body: /Sally/).
      to_return(status: 200, body: { "internalId" => "123" }.to_json)
    stub_request(:patch, "#{cloud_elements}/employees/1234").
      with(body: /Tina/).
      to_return(status: 200, body: { "internalId" => "1234" }.to_json)
    stub_request(:post, "#{cloud_elements}/employees").
      with(body: /Mickey/).
      to_return(status: 400, body: { "message" => "Bad Data" }.to_json)

    stub_namely_fields("fields_with_net_suite")
    stub_request(
      :post,
      "https://api.cloud-elements.com/elements/api-v2/instances"
    ).to_return(status: 200, body: { id: "1", token: "2" }.to_json)
    stub_request(:get, subsidiary_url).
      to_return(status: 200, body: [{ name: "hello", internalId: subsidiary_id }].to_json)

    visit dashboard_path(as: user)

    find(".net-suite-account").click_on t("dashboards.show.connect")

    fill_in("net_suite_authentication_account_id", with: "123xy")
    fill_in("net_suite_authentication_email", with: user.email)
    fill_in("net_suite_authentication_password", with: "abc12z")
    click_button t("helpers.submit.net_suite_connection.update")

    select("hello", from: "net_suite_connection_subsidiary_id")
    click_button t("helpers.submit.net_suite_connection.update")

    expect(page).to have_select("Supervisor", selected: "Supervisor NetSuite Id")
    select("Home", from: "Supervisor")
    expect(page).not_to have_select("Supervisor", selected: "Home")
  end

  def click_netsuite_mappings_link
    within(".net-suite-account") do
      click_link t("dashboards.show.edit_mappings")
    end
  end
end
