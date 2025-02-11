class UpdatePostcodesAddLupFlag < ActiveRecord::Migration[8.0]
  def up
    add_column :postcodes, :large_user_postcode, :boolean, default: false, null: false

    add_index :postcodes, %i[retired large_user_postcode updated_at]

    Postcode.onspd.find_in_batches(batch_size: 50) do |group|
      group.select { |r| r.results.first["ONS"]["TYPE"] == "L" }.each do |r|
        r.update(large_user_postcode: true)
      end
    end
  end

  def down
    remove_index :postcodes, %i[retired large_user_postcode updated_at]

    remove_column :postcodes, :large_user_postcode, :boolean, default: false, null: false
  end
end
