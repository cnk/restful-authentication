require 'rubygems'
require_gem 'ldap'
require 'LDAP'

class <%= server_controller_class_name %> < ActiveRecord::Base
  validates_presence_of   :name, :host, :port, :base_dn, :scope,
    :login_attribute, :email_attribute, :given_name_attribute,
    :surname_attribute
  validates_uniqueness_of :name
  validates_inclusion_of :scope, :in => %w( base one sub )
  
  has_many :<%= model_controller_plural_name %>
  
  before_destroy :dont_destroy_in_use_<%= server_singular_name %>
  
  def <%= model_controller_plural_name %>_search(name)
    filter = "(&(objectClass=#{self.object_class})" +
               "(|(#{self.login_attribute}=*#{name}*)" +
                 "(#{self.given_name_attribute}=*#{name}*)" +
                 "(#{self.surname_attribute}=*#{name}*)))"

    attributes = [
      self.login_attribute,
      self.given_name_attribute,
      self.surname_attribute,
      self.email_attribute
    ]
    
    <%= model_controller_plural_name %> = []
    self.query(filter, attributes).each do |u|
      <%= model_controller_plural_name %> << <%= model_controller_class_name %>.new({
        :distinguished_name => u['dn'],
        :login => u[self.login_attribute],
        :given_name => u[self.given_name_attribute],
        :surname => u[self.surname_attribute],
        :email => u[self.email_attribute],
        :<%= server_singular_name %>_id => self.id
      })
    end
    <%= model_controller_plural_name %>
  end
  
  def <%= model_controller_plural_name %>_by_login(login)
    filter = "(&(objectClass=#{self.object_class})" +
               "(#{self.login_attribute}=#{login}))"

    attributes = [
      self.login_attribute,
      self.given_name_attribute,
      self.surname_attribute,
      self.email_attribute
    ]
    
    <%= model_controller_plural_name %> = []
    self.query(filter, attributes).each do |u|
      <%= model_controller_plural_name %> << <%= model_controller_class_name %>.new({
        :distinguished_name => u['dn'],
        :login => u[self.login_attribute],
        :given_name => u[self.given_name_attribute],
        :surname => u[self.surname_attribute],
        :email => u[self.email_attribute],
        :<%= server_singular_name %>_id => self.id
      })
    end
    <%= model_controller_plural_name %>
  end
  
  def authenticated?(distinguished_name, password)
    authenticated = false
    conn = self.connect
    begin
      conn.bind distinguished_name, password do
        authenticated = true
      end
      rescue
    end
    authenticated
  end
  

  protected
  def connect
    conn = nil
    if self.ssl?
      conn = LDAP::SSLConn.new self.host, self.port
    else
      conn = LDAP::Conn.new self.host, self.port
    end
    conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    conn
  end
  
  def query(filter, attributes = ['dn'])
    results = []
    
    conn = self.connect

    scope = case self.scope
      when "base"
        LDAP::LDAP_SCOPE_BASE
      when "one"
        LDAP::LDAP_SCOPE_ONELEVEL
      else
        LDAP::LDAP_SCOPE_SUBTREE
    end
    
    conn.bind self.bind_dn, self.bind_password do
      conn.search(
        self.base_dn,
        scope,
        filter,
        attributes
      ) do |e|
        result = Hash.new
        attributes.each do |a|
          result[a] = e[a][0] unless e[a].nil?
        end
        result['dn'] = e.dn
        results << result
      end
    end
    results
  end
  
  def dont_destroy_in_use_<%= server_singular_name %>
    raise "Cannot destroy in use <%= server_singular_name.humanize %>" if <%= model_controller_class_name %>.count(:conditions => ["<%= server_singular_name %>_id = ?", id]) > 0
  end
end
