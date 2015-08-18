class CertTypesController < ApplicationController
  before_action :set_cert_type, only: [:show, :edit, :update, :destroy]

  # GET /cert_types
  # GET /cert_types.json
  def index
    @cert_types = CertType.all
  end

  # GET /cert_types/1
  # GET /cert_types/1.json
  def show
  end

  # GET /cert_types/new
  def new
    @cert_type = CertType.new
  end

  # GET /cert_types/1/edit
  def edit
  end

  # POST /cert_types
  # POST /cert_types.json
  def create
    @cert_type = CertType.new(cert_type_params)

    respond_to do |format|
      if @cert_type.save
        format.html { redirect_to @cert_type, notice: 'Cert type was successfully created.' }
        format.json { render action: 'show', status: :created, location: @cert_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @cert_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cert_types/1
  # PATCH/PUT /cert_types/1.json
  def update
    respond_to do |format|
      if @cert_type.update(cert_type_params)
        format.html { redirect_to @cert_type, notice: 'Cert type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cert_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cert_types/1
  # DELETE /cert_types/1.json
  def destroy
    @cert_type.destroy
    respond_to do |format|
      format.html { redirect_to cert_types_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cert_type
      @cert_type = CertType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cert_type_params
      params.require(:cert_type).permit(:name)
    end
end
