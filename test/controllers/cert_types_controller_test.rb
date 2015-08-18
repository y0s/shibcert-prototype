require 'test_helper'

class CertTypesControllerTest < ActionController::TestCase
  setup do
    @cert_type = cert_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cert_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cert_type" do
    assert_difference('CertType.count') do
      post :create, cert_type: { name: @cert_type.name }
    end

    assert_redirected_to cert_type_path(assigns(:cert_type))
  end

  test "should show cert_type" do
    get :show, id: @cert_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cert_type
    assert_response :success
  end

  test "should update cert_type" do
    patch :update, id: @cert_type, cert_type: { name: @cert_type.name }
    assert_redirected_to cert_type_path(assigns(:cert_type))
  end

  test "should destroy cert_type" do
    assert_difference('CertType.count', -1) do
      delete :destroy, id: @cert_type
    end

    assert_redirected_to cert_types_path
  end
end
