class CreateRepairs < ActiveRecord::Migration[8.1]
  def change
    create_table :repairs do |t|
      t.text :description
      t.string :status
      t.decimal :cost
      t.references :car, null: false, foreign_key: true

      t.timestamps
    end
  end
end
