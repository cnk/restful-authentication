class <%= server_controller_class_name %>Controller < ApplicationController
  
  include AuthenticatedSystem
  
  before_filter :login_required

  layout "authenticated"

  def index
    @<%= server_plural_name %> = <%= server_class_name %>.find(:all)
  end

  def show
    @<%= server_singular_name %> = <%= server_class_name %>.find(params[:id])
  end

  def new
    @<%= server_singular_name %> = <%= server_class_name %>.new
  end

  def create
    @<%= server_singular_name %> = <%= server_class_name %>.new(params[:<%= server_singular_name %>])
    if @<%= server_singular_name %>.save
      flash[:notice] = '<%= server_singular_name.humanize %> was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @<%= server_singular_name %> = <%= server_class_name %>.find(params[:id])
  end

  def update
    @<%= server_singular_name %> = <%= server_class_name %>.find(params[:id])
    if @<%= server_singular_name %>.update_attributes(params[:<%= server_singular_name %>])
      flash[:notice] = '<%= server_singular_name.humanize %> was successfully updated.'
      redirect_to :action => 'show', :id => @<%= server_singular_name %>
    else
      render :action => 'edit'
    end
  end

  def destroy
    <%= server_class_name %>.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
  
  def search_<%= model_controller_singular_name %>
    @<%= server_singular_name %> = <%= server_class_name %>.find(params[:id])
    @<%= model_controller_plural_name %> = request.post? ? @<%= server_singular_name %>.<%= model_controller_plural_name %>_search(params[:search]) : []
  end
end
