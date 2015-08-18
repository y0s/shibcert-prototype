class CertStatesController < ApplicationController
  before_action :set_cert_state, only: [:show, :edit, :update, :destroy]

  # GET /cert_states
  # GET /cert_states.json
  def index
    @cert_states = CertState.all
  end

  # GET /cert_states/1
  # GET /cert_states/1.json
  def show
  end

  # GET /cert_states/new
  def new
    @cert_state = CertState.new
  end

  # GET /cert_states/1/edit
  def edit
  end

  # POST /cert_states
  # POST /cert_states.json
  def create
    @cert_state = CertState.new(cert_state_params)

    respond_to do |format|
      if @cert_state.save
        format.html { redirect_to @cert_state, notice: 'Cert state was successfully created.' }
        format.json { render action: 'show', status: :created, location: @cert_state }
      else
        format.html { render action: 'new' }
        format.json { render json: @cert_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cert_states/1
  # PATCH/PUT /cert_states/1.json
  def update
    respond_to do |format|
      if @cert_state.update(cert_state_params)
        format.html { redirect_to @cert_state, notice: 'Cert state was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cert_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cert_states/1
  # DELETE /cert_states/1.json
  def destroy
    @cert_state.destroy
    respond_to do |format|
      format.html { redirect_to cert_states_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cert_state
      @cert_state = CertState.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cert_state_params
      params.require(:cert_state).permit(:name)
    end
end
