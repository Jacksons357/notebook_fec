# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_07_233228) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "emprestimos", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "notebook_id", null: false
    t.string "nome_colaborador", null: false
    t.string "setor", null: false
    t.date "data_emprestimo", null: false
    t.date "data_devolucao"
    t.text "motivo_devolucao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome_colaborador"], name: "index_emprestimos_on_nome_colaborador"
    t.index ["notebook_id", "data_emprestimo"], name: "index_emprestimos_on_notebook_id_and_data_emprestimo"
    t.index ["notebook_id"], name: "index_emprestimos_on_notebook_id"
    t.index ["setor"], name: "index_emprestimos_on_setor"
  end

  create_table "historico_status_notebooks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "notebook_id", null: false
    t.integer "estado", null: false
    t.datetime "data_alteracao", null: false
    t.text "informacoes_adicionais"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notebook_id", "data_alteracao"], name: "idx_on_notebook_id_data_alteracao_237599db6d"
    t.index ["notebook_id"], name: "index_historico_status_notebooks_on_notebook_id"
  end

  create_table "notebooks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "marca", null: false
    t.string "modelo", null: false
    t.string "numero_patrimonio", null: false
    t.string "numero_serie", null: false
    t.string "identificacao_equipamento", null: false
    t.date "data_compra", null: false
    t.date "data_fabricacao"
    t.text "descricao"
    t.integer "estado", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estado"], name: "index_notebooks_on_estado"
    t.index ["identificacao_equipamento"], name: "index_notebooks_on_identificacao_equipamento", unique: true
    t.index ["numero_patrimonio"], name: "index_notebooks_on_numero_patrimonio", unique: true
    t.index ["numero_serie"], name: "index_notebooks_on_numero_serie", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "emprestimos", "notebooks"
  add_foreign_key "historico_status_notebooks", "notebooks"
end
