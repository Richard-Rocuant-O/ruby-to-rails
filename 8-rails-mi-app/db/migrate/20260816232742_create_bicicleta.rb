class CreateBicicleta < ActiveRecord::Migration[8.1]
  def change
    create_table :bicicleta do |t|
      t.string :marca
      t.string :modelo
      t.integer :rodada
      t.boolean :activa

      t.timestamps
    end
  end
end
