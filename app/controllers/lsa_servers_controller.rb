class LsaServersController < ApplicationController

  # Filters

  # Variables
  before_action :set_lsa_server, except: [:new, :index, :create]

  # Permissions
  before_action :require_assistant

  # Actions (Resources)

  def index
    @lsa_servers = LsaServer.all.decorate
  end

  def show
  end

  def new
    @lsa_server = LsaServer.new
  end

  def edit
  end

  def update
    if @lsa_server.update(lsa_server_params)
      flash[:notice] = trl("LSA Server was successfully updated.")
      redirect_to lectures_path
    else
      render :action => 'edit'
    end
  end

  def create
    @lsa_server = LsaServer.new(lsa_server_params)
    if @lsa_server.save
      flash[:notice] = trl("LSA Server was successfully updated.")
      redirect_to lectures_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @lsa_server.destroy
    flash[:notice] = trl("LSA Server was succesfully deleted.")
    redirect_to lectures_path
  end

  # ---

  private

	# ---

  # Variables

  def set_lsa_server
    @lsa_server = LsaServer.find(params[:id]).decorate
  end

  # Strong Parameters

  def lsa_server_params
    params.require(:lsa_server).permit(:name,
																			 :json_url,
																			 :json_port,
																			 :json_path,
																			 :rmi_url,
																			 :rmi_port)
  end

end
