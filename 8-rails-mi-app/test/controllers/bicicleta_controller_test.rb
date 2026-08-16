require "test_helper"

class BicicletaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bicicletum = bicicleta(:one)
  end

  test "should get index" do
    get bicicleta_index_url
    assert_response :success
  end

  test "should get new" do
    get new_bicicletum_url
    assert_response :success
  end

  test "should create bicicletum" do
    assert_difference("Bicicleta.count") do
      post bicicleta_index_url, params: { bicicletum: { activa: @bicicletum.activa, marca: @bicicletum.marca, modelo: @bicicletum.modelo, rodada: @bicicletum.rodada } }
    end

    assert_redirected_to bicicletum_url(Bicicleta.last)
  end

  test "should show bicicletum" do
    get bicicletum_url(@bicicletum)
    assert_response :success
  end

  test "should get edit" do
    get edit_bicicletum_url(@bicicletum)
    assert_response :success
  end

  test "should update bicicletum" do
    patch bicicletum_url(@bicicletum), params: { bicicletum: { activa: @bicicletum.activa, marca: @bicicletum.marca, modelo: @bicicletum.modelo, rodada: @bicicletum.rodada } }
    assert_redirected_to bicicletum_url(@bicicletum)
  end

  test "should destroy bicicletum" do
    assert_difference("Bicicleta.count", -1) do
      delete bicicletum_url(@bicicletum)
    end

    assert_redirected_to bicicleta_index_url
  end
end
