require "test_helper"

class DeploymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deployment = deployments(:one)
    @user = users(:one)

    # post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get index" do
    get deployments_url
    assert_response :success
  end

  test "should get new" do
    get new_deployment_url
    assert_response :success
  end

  test "should create deployment" do
    assert_difference("Deployment.count") do
      post deployments_url, params: { deployment: { component_id: @deployment.component_id, environment: @deployment.environment, location_identifier: @deployment.location_identifier, platform: @deployment.platform } }
    end

    assert_redirected_to deployment_url(Deployment.last)
  end

  test "should show deployment" do
    get deployment_url(@deployment)
    assert_response :success
  end

  test "should get edit" do
    get edit_deployment_url(@deployment)
    assert_response :success
  end

  test "should update deployment" do
    patch deployment_url(@deployment), params: { deployment: { component_id: @deployment.component_id, environment: @deployment.environment, location_identifier: @deployment.location_identifier, platform: @deployment.platform } }
    assert_redirected_to deployment_url(@deployment)
  end

  test "should destroy deployment" do
    assert_difference("Deployment.count", -1) do
      delete deployment_url(@deployment)
    end

    assert_redirected_to deployments_url
  end
end
