require 'rails_helper'

RSpec.describe "Notebooks", type: :request do
  let(:valid_attributes) do
    {
      marca: "Dell",
      modelo: "Latitude 5520",
      numero_patrimonio: "PAT123",
      numero_serie: "SN123456",
      identificacao_equipamento: "NB001",
      data_compra: Date.today
    }
  end

  let(:notebook) { Notebook.create!(valid_attributes) }

  describe "GET /notebooks" do
    it "renders the index page" do
      get notebooks_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Gerenciamento de Notebooks")
    end
  end

  describe "GET /notebooks/:id" do
    it "shows a notebook" do
      get notebook_path(notebook)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(notebook.identificacao_equipamento)
    end
  end

  describe "GET /notebooks/new" do
    it "renders the new notebook form" do
      get new_notebook_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Adicionar Notebook").or include("Atualizar Notebook")
    end
  end

  describe "POST /notebooks" do
    it "creates a new notebook" do
      expect {
        post notebooks_path, params: { notebook: valid_attributes }
      }.to change(Notebook, :count).by(1)
      expect(response).to redirect_to(notebook_path(Notebook.last))
    end
  end

  describe "GET /notebooks/:id/edit" do
    it "renders the edit form" do
      get edit_notebook_path(notebook)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Atualizar Notebook").or include("Adicionar Notebook")
    end
  end

  describe "PATCH /notebooks/:id" do
    it "updates a notebook" do
      patch notebook_path(notebook), params: { notebook: { marca: "HP" } }
      expect(response).to redirect_to(notebook_path(notebook))
      notebook.reload
      expect(notebook.marca).to eq("HP")
    end
  end

  describe "DELETE /notebooks/:id" do
    it "exclui notebook disponível e nunca emprestado" do
      nb = Notebook.create!(valid_attributes)
      expect {
        delete notebook_path(nb)
      }.to change(Notebook, :count).by(-1)
      expect(response).to redirect_to(notebooks_path)
    end

    it "não exclui notebook emprestado" do
      nb = Notebook.create!(valid_attributes)
      nb.emprestar!("Colaborador", "TI")
      expect {
        delete notebook_path(nb)
      }.not_to change(Notebook, :count)
      expect(response).to redirect_to(notebook_path(nb))
    end
  end

  describe "POST /notebooks/:id/emprestar" do
    it "empresta notebook disponível" do
      post emprestar_notebook_path(notebook), params: { nome_colaborador: "João", setor: "TI" }
      expect(response).to redirect_to(notebook_path(notebook))
      notebook.reload
      expect(notebook.estado).to eq("emprestado")
      expect(notebook.emprestimos.last.nome_colaborador).to eq("João")
    end
  end

  describe "POST /notebooks/:id/devolver" do
    it "devolve notebook emprestado" do
      notebook.emprestar!("João", "TI")
      post devolver_notebook_path(notebook), params: { motivo_devolucao: "Devolução normal" }
      expect(response).to redirect_to(notebook_path(notebook))
      notebook.reload
      expect(notebook.estado).to eq("disponivel")
      expect(notebook.emprestimos.last.motivo_devolucao).to eq("Devolução normal")
    end
  end

  describe "POST /notebooks/:id/baixar" do
    it "baixa notebook emprestado" do
      notebook.emprestar!("João", "TI")
      post baixar_notebook_path(notebook), params: { justificativa: "Defeito" }
      expect(response).to redirect_to(notebook_path(notebook))
      notebook.reload
      expect(notebook.estado).to eq("indisponivel")
      expect(notebook.emprestimos.last.motivo_devolucao).to include("Baixa")
    end
  end

  describe "GET /notebooks?query=" do
    it "busca notebook por identificação" do
      nb = Notebook.create!(valid_attributes.merge(identificacao_equipamento: "BUSCA01"))
      get notebooks_path, params: { query: "BUSCA01" }
      expect(response.body).to include("BUSCA01")
    end
  end
end 