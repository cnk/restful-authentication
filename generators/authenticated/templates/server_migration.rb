class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= server_table_name %>", :force => true do |t|
      t.column :name,                 :string
      t.column :host,                 :string,  :default => "localhost"
      t.column :port,                 :integer, :default => 389
      t.column :ssl,                  :boolean, :default => false
      t.column :bind_dn,              :string,  :default => ""
      t.column :bind_password,        :string,  :default => ""
      t.column :base_dn,              :string
      t.column :scope,                :string,  :default => "sub"
      t.column :object_class,         :string,  :default => "inetOrgPerson"
      t.column :login_attribute,      :string,  :default => "uid"
      t.column :email_attribute,      :string,  :default => "mail"
      t.column :given_name_attribute, :string,  :default => "givenName"
      t.column :surname_attribute,    :string,  :default => "sn"
      t.column :create_<%= model_controller_plural_name %>,         :boolean, :default => false
      t.column :created_at,           :datetime
      t.column :updated_at,           :datetime
    end
  end

  def self.down
    drop_table "<%= server_table_name %>"
  end
end
