# coding: utf-8
class CertsController < ApplicationController
  before_action :set_cert, only: [:edit, :update, :destroy]
  before_action :set_cert_of_user, only: [:show, :edit_memo_remote, :request_result]
  # GET /certs
  # GET /certs.json
  def index
    if current_user
      @certs = Cert.where(user_id: current_user.id)
    end
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

  # POST /certs/request_post [with RPG pattern]
  def request_post
    # purpose_type: profile ID of
    #   https://certs.nii.ac.jp/archive/TSV_File_Format/client_tsv/

    ActiveRecord::Base.transaction do      
      current_user.cert_serial_max += 1
      current_user.save # TODO: need error check
    end        
    
    case params[:cert]["purpose_type"].to_i
    when Cert::PurposeType::CLIENT_AUTH_CERTIFICATE
      dn = "CN=#{current_user.uid},OU=No #{current_user.cert_serial_max.to_s}," + SHIBCERT_CONFIG[Rails.env]['base_dn']

    when Cert::PurposeType::SMIME_CERTIFICATE
      dn = "CN=#{current_user.name}," + SHIBCERT_CONFIG[Rails.env]['base_dn']
    else
      # something wrong. TODO: need error handling
      Rails.logger.info "#{__method__}: unknown purpose_type #{params[:cert]['purpose_type']}"
      dn = ""
    end
    
    request_params = params.require(:cert).permit(:purpose_type).merge(
      {user_id: current_user.id,
       state: Cert::State::NEW_REQUESTED_FROM_USER,
       dn: dn,
       req_seq: current_user.cert_serial_max})
    @cert = Cert.new(request_params)
    @cert.save

    Rails.logger.debug "RaReq.request call: @cert = #{@cert.inspect}"
    RaReq.request(@cert)
 
    redirect_to request_result_path(@cert.id)
  end

  # POST /certs/request_post [with RPG pattern]
  def request_result
    
  end

  # GET /certs/new
  def new
    @cert = Cert.new
  end

  # GET /certs/1/edit
  def edit
  end

  # POST /certs/1/edit_memo_remote
  def edit_memo_remote
    #    @cert.update('memo = ' + params[:memo])
    #    @cert.update_attributes = {memo: params[:memo]}
    if @cert
      @cert.attributes = params.require(:cert).permit(:memo)
      @cert.save
    end
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

  def set_cert_of_user
    # FIXME: fix for not found error
    begin
      mycert = Cert.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      mycert = nil
    end
    if mycert and mycert.user_id == current_user.id
      @cert = mycert
    else
      @cert = nil
    end
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
    def cert_params
      params.require(:cert).permit(:memo, :get_at, :expire_at, :pin, :pin_get_at, :user_id, :cert_state_id, :cert_type_id, :purpose_type)
    end
end
