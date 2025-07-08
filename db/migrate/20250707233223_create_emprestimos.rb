class CreateEmprestimos < ActiveRecord::Migration[8.0]
  def change
    create_table :emprestimos do |t|
      t.references :notebook, null: false, foreign_key: true
      t.string :nome_colaborador, null: false
      t.string :setor, null: false
      t.date :data_emprestimo, null: false
      t.date :data_devolucao
      t.text :motivo_devolucao

      t.timestamps
    end
    add_index :emprestimos, [:notebook_id, :data_emprestimo]
    add_index :emprestimos, :nome_colaborador
    add_index :emprestimos, :setor
  end
end 