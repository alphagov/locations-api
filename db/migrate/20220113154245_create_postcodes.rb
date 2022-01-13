class CreatePostcodes < ActiveRecord::Migration[6.1]
  def change
    create_table :postcodes do |t|
      t.string :postcode
      t.json :results

      t.timestamps
    end
    add_index :postcodes, :postcode, unique: true
  end
end
