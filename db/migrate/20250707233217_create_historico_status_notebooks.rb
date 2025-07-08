class CreateHistoricoStatusNotebooks < ActiveRecord::Migration[8.0]
  def change
    create_table :historico_status_notebooks do |t|
      t.references :notebook, null: false, foreign_key: true
      t.integer :estado, null: false
      t.datetime :data_alteracao, null: false
      t.text :informacoes_adicionais

      t.timestamps
    end
    add_index :historico_status_notebooks, [:notebook_id, :data_alteracao]
  end
end 