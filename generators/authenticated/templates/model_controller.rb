class <%= model_controller_class_name %>Controller < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  before_filter :login_required, :except => [ :new, :create ]

  layout "authenticated"

  <% if options[:stateful] %>
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_<%= file_name %>, :only => [:suspend, :unsuspend, :destroy, :purge]
  <% end %>

  def index
    @<%= model_controller_plural_name %> = <%= class_name %>.find(:all <% if options[:ldap_capable] -%>, :include => :<%= server_singular_name %><% end -%>)
  end 

  def show 
    @<%= model_controller_singular_name %> = <%= class_name %>.find(params[:id])      
  end                                                            

  # render new.rhtml
  def new
    <% if options[:ldap_capable] -%>@<%= file_name %> = <%= class_name %>.new(params[:user])
    @server_name = <%= server_class_name %>.find(@<%= file_name %>.<%= server_singular_name %>_id).name unless @<%= file_name %>.<%= server_singular_name %>_id.nil? <% else -%>
    @<%= file_name %> = <%= class_name %>.new <% end %>
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
    @<%= file_name %>.<% if options[:stateful] %>register! if @<%= file_name %>.valid?<% else %>save<% end %>
    if @<%= file_name %>.errors.empty?
      self.current_<%= file_name %> = @<%= file_name %>
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end
<% if options[:include_activation] %>
  def activate
    self.current_<%= file_name %> = params[:activation_code].blank? ? false : <%= class_name %>.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_<%= file_name %>.active?
      current_<%= file_name %>.activate<% if options[:stateful] %>!<% end %>
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
<% end %><% if options[:stateful] %>
  def suspend
    @<%= file_name %>.suspend! 
    redirect_to <%= table_name %>_path
  end

  def unsuspend
    @<%= file_name %>.unsuspend! 
    redirect_to <%= table_name %>_path
  end

  def destroy
    @<%= file_name %>.delete!
    redirect_to <%= table_name %>_path
  end

  def purge
    @<%= file_name %>.destroy
    redirect_to <%= table_name %>_path
  end
<% end -%>

  # render edit.rhtml
  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    <% if options[:ldap_capable] -%>@server_name = <%= server_class_name %>.find(@<%= file_name %>.<%= server_singular_name %>_id).name unless @<%= file_name %>.<%= server_singular_name %>_id.nil? <% end -%>
  end

  def update                                              
    @<%= file_name %> = <%= class_name %>.find(params[:id]) 
    if @<%= file_name %>.update_attributes(params[:<%= file_name %>]) 
      flash[:notice] = '<%= file_name.humanize %> was successfully updated.' 
      redirect_to :action => 'show', :id => @<%= file_name %> 
    else 
      render :action => 'edit'                         
    end                                       
  end

  def destroy 
    <%= class_name %>.find(params[:id]).destroy 
    redirect_to :action => 'list'                                               
  end 

   
<% if options[:stateful] %>
protected
  def find_<%= file_name %>
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end
<% end %>

end
