class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.text :note
      t.references :reportable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
