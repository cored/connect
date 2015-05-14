require 'rails_helper'

feature 'User connects Slack account' do

  scenario 'successfully' do
    user = create(:user)
    allow(SecureRandom).to receive(:hex).and_return('token')

    visit dashboard_path(as: user)

    within(".slack-account") do
      expect(page).to have_no_link t("dashboards.show.disconnect")
    end

    within(".slack-account") do

    end
  end
end
