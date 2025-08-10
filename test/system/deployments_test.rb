require "application_system_test_case"

class DeploymentsTest < ApplicationSystemTestCase
  setup do
    @deployment = deployments(:one)
  end

  test "visiting the index" do
    visit deployments_url
    assert_selector "h1", text: "Deployments"
  end

  test "should create deployment" do
    visit deployments_url
    click_on "New deployment"

    fill_in "Component", with: @deployment.component_id
    fill_in "Environment", with: @deployment.environment
    fill_in "Location identifier", with: @deployment.location_identifier
    fill_in "Platform", with: @deployment.platform
    click_on "Create Deployment"

    assert_text "Deployment was successfully created"
    click_on "Back"
  end

  test "should update Deployment" do
    visit deployment_url(@deployment)
    click_on "Edit this deployment", match: :first

    fill_in "Component", with: @deployment.component_id
    fill_in "Environment", with: @deployment.environment
    fill_in "Location identifier", with: @deployment.location_identifier
    fill_in "Platform", with: @deployment.platform
    click_on "Update Deployment"

    assert_text "Deployment was successfully updated"
    click_on "Back"
  end

  test "should destroy Deployment" do
    visit deployment_url(@deployment)
    accept_confirm { click_on "Destroy this deployment", match: :first }

    assert_text "Deployment was successfully destroyed"
  end
end
