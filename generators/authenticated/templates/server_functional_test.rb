<% modules = server_controller_class_nesting.split('/::/') %>
require File.dirname(__FILE__) + '<%= "/.." * modules.size %>' + '/../test_helper'

# Define the module path for the following require
<% modules.size.times do |n| %><%= "module " + modules[0..n].join('::') + "; " %><% end %><%= ("end; " * modules.size).slice(0..-3) %>

require '<%= server_controller_file_path %>_controller'

# Re-raise errors caught by the controller.
class <%= server_controller_class_name %>Controller; def rescue_action(e) raise e end; end

class <%= server_controller_class_name %>ControllerTest < Test::Unit::TestCase
  fixtures :<%= server_plural_name %>, :<%= model_controller_plural_name %>

  def setup
    @controller = <%= server_controller_class_name %>Controller.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @admin = <%= model_controller_plural_name %>(:admin).id
    @user  = <%= model_controller_plural_name %>(:user).id
    
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
  end

  def test_index_without_user
    get :index
    assert_response :redirect
    assert_redirected_to :action => "login"
  end
  
  def test_index_as_admin
    get :index, {}, { :<%= model_controller_singular_name %> => @admin }
    assert_response :success
    assert_template "list"
  end
  
  def test_index_as_user
    get :index, {}, { :<%= model_controller_singular_name %> => @user }
    assert_response :redirect
    assert_redirected_to File.join("<%= model_controller_file_path %>", "login")
#    assert_redirected_to :controller => "/<%= model_controller_file_path %>",
#                         :action => "login"
  end

  def test_list_as_admin
    get :list, {}, { :<%= model_controller_singular_name %> => @admin }

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:<%= server_plural_name %>)
  end

  def test_show_as_admin
    get :show, { :id => 1 }, { :<%= model_controller_singular_name %> => @admin }

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:<%= server_singular_name %>)
    assert assigns(:<%= server_singular_name %>).valid?
  end

  def test_new_as_admin
    get :new, {}, { :<%= model_controller_singular_name %> => @admin }

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:<%= server_singular_name %>)
  end

  def test_create_as_admin
    num_ldap_servers = <%= server_class_name %>.count

    post :create, { :<%= server_singular_name %> =>  @ldap_server }, { :<%= model_controller_singular_name %> => @admin }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_ldap_servers + 1, <%= server_class_name %>.count
  end

  def test_edit_as_admin
    get :edit, { :id => 1 }, { :<%= model_controller_singular_name %> => @admin }

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:<%= server_singular_name %>)
    assert assigns(:<%= server_singular_name %>).valid?
  end

  def test_update_as_admin
    post :update, { :id => 1 }.merge(@ldap_server), { :<%= model_controller_singular_name %> => @admin }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy_as_admin
    assert_not_nil <%= server_class_name %>.find(1)

    post :destroy, { :id => 1 }, { :<%= model_controller_singular_name %> => @admin }
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      <%= server_class_name %>.find(1)
    }
  end
end
