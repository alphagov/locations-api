class CreateImports < ActiveRecord::Migration[8.0]
  def change
    create_table :imports do |t|
      t.string :url
      t.timestamps
    end
  end
end
