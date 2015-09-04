# coding: utf-8
class CertsController < ApplicationController
  before_action :set_cert, only: [:show, :edit, :update, :destroy]

  # GET /certs
  # GET /certs.json
  def index
    @certs = Cert.all
  end

  # GET /certs/1
  # GET /certs/1.json
  def show
    # FIXME: user authorization needed
  end

  # GET /certs/request_select
  # [memo] "request" is reserved by rails system
  def request_select
  end

  # POST /certs/request_result
  def request_result
    uid = SESSION_USER_DUMMY_ID
    cs = CertState.new
    cs.save
    ct = CertType.new
    ct.save
    
    request_params = {user_id: uid, cert_state_id: cs.id, cert_type_id: ct.id}
    @cert = Cert.new(request_params)
    @cert.save
    @new_cert_id = @cert.id
  end

  # GET /certs/new
  def new
    @cert = Cert.new
  end

  # GET /certs/1/edit
  def edit
  end

  # POST /certs
  # POST /certs.json
  def create
    @cert = Cert.new(cert_params)

    respond_to do |format|
      if @cert.save
        format.html { redirect_to @cert, notice: 'Cert was successfully created.' }
        format.json { render action: 'show', status: :created, location: @cert }
      else
        format.html { render action: 'new' }
        format.json { render json: @cert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /certs/1
  # PATCH/PUT /certs/1.json
  def update
    respond_to do |format|
      if @cert.update(cert_params)
        format.html { redirect_to @cert, notice: 'Cert was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /certs/1
  # DELETE /certs/1.json
  def destroy
    @cert.destroy
    respond_to do |format|
      format.html { redirect_to certs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cert
      @cert = Cert.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cert_params
      params.require(:cert).permit(:name, :get_at, :expire_at, :pin, :pin_get_at, :user_id, :cert_state_id, :cert_type_id)
    end
end
