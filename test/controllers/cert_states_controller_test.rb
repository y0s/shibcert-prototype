require 'test_helper'

class CertStatesControllerTest < ActionController::TestCase
  setup do
    @cert_state = cert_states(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cert_states)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cert_state" do
    assert_difference('CertState.count') do
      post :create, cert_state: { name: @cert_state.name }
    end

    assert_redirected_to cert_state_path(assigns(:cert_state))
  end

  test "should show cert_state" do
    get :show, id: @cert_state
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cert_state
    assert_response :success
  end

  test "should update cert_state" do
    patch :update, id: @cert_state, cert_state: { name: @cert_state.name }
    assert_redirected_to cert_state_path(assigns(:cert_state))
  end

  test "should destroy cert_state" do
    assert_difference('CertState.count', -1) do
      delete :destroy, id: @cert_state
    end

    assert_redirected_to cert_states_path
  end
end
