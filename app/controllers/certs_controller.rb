# coding: utf-8
class CertsController < ApplicationController
  before_action :set_cert, only: [:edit, :update, :destroy]
  before_action :set_cert_of_user, only: [:show, :edit_memo_remote]
  # GET /certs
  # GET /certs.json
  def index
    @certs = Cert.where(user_id: current_user.id)
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
    # state: 0 => now requesting, 1 => issued, 2 => issued but expired,
    #        3 => invadidated, -1 => error
    # purpose_type: profile ID of
    #   https://certs.nii.ac.jp/archive/TSV_File_Format/client_tsv/
    
    if params[:cert]["purpose_type"] == "5"
      current_user.cert_serial_max += 1
      current_user.save # TODO: need error check
      dn = "CN=#{current_user.name},OU=No #{current_user.cert_serial_max.to_s},OU=Institute for Information Management and Communication,O=Kyoto University,L=Academe,C=JP"
    elsif params[:cert]["purpose_type"] == "7"
      dn = "CN=#{current_user.email},OU=Institute for Information Management and Communication,O=Kyoto University,L=Academe,C=JP"
    else
      dn = params[:cert]["purpose_type"].to_s # something wrong. TODO: need error handling
    end
    
    request_params = params.require(:cert).permit(:purpose_type).merge({user_id: current_user.id, state: 0, dn: dn})
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
