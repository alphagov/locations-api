class UpdatePostcodesAddLupFlag < ActiveRecord::Migration[8.0]
  def up
    add_column :postcodes, :large_user_postcode, :boolean, default: false, null: false

    add_index :postcodes, %i[retired large_user_postcode updated_at]
  end

  def down
    remove_index :postcodes, %i[retired large_user_postcode updated_at]

    remove_column :postcodes, :large_user_postcode, :boolean, default: false, null: false
  end
end
