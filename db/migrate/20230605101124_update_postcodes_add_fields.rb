class UpdatePostcodesAddFields < ActiveRecord::Migration[7.0]
  def change
    add_column :postcodes, :source, :string, default: "os_places", null: false
    add_column :postcodes, :retired, :boolean, default: false, null: false

    add_index :postcodes, :source
    add_index :postcodes, :retired
  end
end
