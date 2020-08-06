class AddDummyUsers < ActiveRecord::Migration[5.0]
  def self.up
    change_table :users do |t|
      t.boolean :dummy, :default => false
    end
    User.update_all ["dummy = ?", false]
  end

  def self.down
    remove_column :users, :dummy
  end

end
