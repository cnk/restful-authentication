<% modules = server_controller_class_nesting.split('/::/') -%>
require File.dirname(__FILE__) + '<%= "/.." * modules.size %>' + '/../test_helper'

# Define the module path for the following require
<% modules.size.times do |n| %><%= "module " + modules[0..n].join('::') + "; " %><% end %><%= ("end; " * modules.size).slice(0..-3) %>

require '<%= server_controller_file_path %>_controller'

# Re-raise errors caught by the controller.
class <%= server_controller_class_name %>Controller; def rescue_action(e) raise e end; end

class <%= server_controller_class_name %>ControllerTest < ActionController::TestCase
  fixtures :<%= server_plural_name %>, :<%= model_controller_plural_name %>

  def setup
    @controller = <%= server_controller_class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    # NB you need to add "include AuthenticatedTestHelper" to your test_helper.rb file
    login_as(:aaron)
    
    @ldap_server = {
      :name                 => "LDAP Server",
      :host                 => "localhost",
      :port                 => "389",
      :base_dn              => "ou=VMFR,o=VMCH",
      :scope                => "sub",
      :object_class         => "inetOrgPerson",
      :login_attribute      => "cn",
      :email_attribute      => "mail",
      :given_name_attribute => "givenName",
      :surname_attribute    => "sn",
      :create_<%= model_controller_plural_name %>         => "0"
    }

    @first_server = <%= server_class_name %>.find(:first)
  end

  def test_index
    get :index
    assert_response :success
    assert_template "index"
  end


  def test_show
    get :show, :id => @first_server

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:<%= server_singular_name %>)
    assert assigns(:<%= server_singular_name %>).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:<%= server_singular_name %>)
  end

  def test_create
    num_ldap_servers = <%= server_class_name %>.count

    post :create, { :<%= server_singular_name %> =>  @ldap_server }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_ldap_servers + 1, <%= server_class_name %>.count
  end

  def test_edit
    get :edit, :id => @first_server

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:<%= server_singular_name %>)
    assert assigns(:<%= server_singular_name %>).valid?
  end

  def test_update
    post :update, { :id => 1 }.merge(@ldap_server)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil <%= server_class_name %>.find(1)

    post :destroy, { :id => 1 }
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      <%= server_class_name %>.find(1)
    }
  end
end
