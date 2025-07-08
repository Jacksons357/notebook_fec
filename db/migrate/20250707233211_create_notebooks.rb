class CreateNotebooks < ActiveRecord::Migration[8.0]
  def change
    create_table :notebooks do |t|
      t.string :marca, null: false
      t.string :modelo, null: false
      t.string :numero_patrimonio, null: false
      t.string :numero_serie, null: false
      t.string :identificacao_equipamento, null: false
      t.date :data_compra, null: false
      t.date :data_fabricacao
      t.text :descricao
      t.integer :estado, default: 0, null: false

      t.timestamps
    end
    add_index :notebooks, :identificacao_equipamento, unique: true
    add_index :notebooks, :numero_serie, unique: true
    add_index :notebooks, :numero_patrimonio, unique: true
    add_index :notebooks, :estado
  end
end
