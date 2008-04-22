class <%= server_controller_class_name %>Controller < ApplicationController
  
  include AuthenticatedSystem
  
  before_filter :login_required

  layout "<%= File.join(model_controller_class_path,
                        "#{model_controller_file_name}") %>"

  def authorized?
    authorized = false

    # Admin <%= model_controller_plural_name %>
    authorized = true if current_<%= model_controller_singular_name %>.admin?
    authorized
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @<%= server_singular_name %>_pages, @<%= server_plural_name %> = paginate :<%= server_plural_name %>, :per_page => 10, :class_name => "<%= server_class_name %>"
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
      redirect_to :action => 'list'
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
    redirect_to :action => 'list'
  end
  
  def search_<%= model_controller_singular_name %>
    @<%= server_singular_name %> = <%= server_class_name %>.find(params[:id])
    @<%= model_controller_plural_name %> = request.post? ? @<%= server_singular_name %>.<%= model_controller_plural_name %>_search(params[:search]) : []
  end
end
