class BicicletaController < ApplicationController
  before_action :set_bicicletum, only: %i[ show edit update destroy ]

  # GET /bicicleta or /bicicleta.json
  def index
    @bicicleta = Bicicleta.all
  end

  # GET /bicicleta/1 or /bicicleta/1.json
  def show
  end

  # GET /bicicleta/new
  def new
    @bicicletum = Bicicleta.new
  end

  # GET /bicicleta/1/edit
  def edit
  end

  # POST /bicicleta or /bicicleta.json
  def create
    @bicicletum = Bicicleta.new(bicicletum_params)

    respond_to do |format|
      if @bicicletum.save
        format.html { redirect_to bicicleta_path(@bicicletum), notice: "Bicicleta was successfully created." }
        format.json { render :show, status: :created, location: @bicicletum }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @bicicletum.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /bicicleta/1 or /bicicleta/1.json
  def update
    respond_to do |format|
      if @bicicletum.update(bicicletum_params)
        format.html { redirect_to bicicleta_path(@bicicletum), notice: "Bicicleta was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @bicicletum }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @bicicletum.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /bicicleta/1 or /bicicleta/1.json
  def destroy
    @bicicletum.destroy!

    respond_to do |format|
      format.html { redirect_to bicicletas_path, notice: "Bicicleta was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bicicletum
      @bicicletum = Bicicleta.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def bicicletum_params
      params.expect(bicicleta: [ :marca, :modelo, :rodada, :activa ])
    end
end
