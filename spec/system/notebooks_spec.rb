require 'rails_helper'

RSpec.describe 'Notebooks', type: :system do
  let(:valid_notebook_attributes) do
    {
      marca: 'Dell',
      modelo: 'Latitude 5520',
      numero_patrimonio: 'PAT123',
      numero_serie: 'SN123456',
      identificacao_equipamento: 'NB001',
      data_compra: Date.parse('2024-01-01')
    }
  end

  before do
    driven_by(:selenium_chrome_headless)
  end

  describe 'fluxo principal do sistema' do
    it 'permite cadastrar, listar, emprestar, devolver e baixar um notebook' do
      # 1. Acessar a página inicial
      visit root_path
      expect(page).to have_content('Gerenciamento de Notebooks')
      expect(page).to have_content('Novo Notebook')

      # 2. Cadastrar um novo notebook
      click_link 'Novo Notebook', match: :first
      expect(page).to have_content('Novo Notebook')

      fill_in 'Marca', with: valid_notebook_attributes[:marca]
      fill_in 'Modelo', with: valid_notebook_attributes[:modelo]
      fill_in 'Nº Patrimônio', with: valid_notebook_attributes[:numero_patrimonio]
      fill_in 'Nº Série', with: valid_notebook_attributes[:numero_serie]
      fill_in 'ID Equipamento', with: valid_notebook_attributes[:identificacao_equipamento]
      page.execute_script("document.querySelector('input[name=\"notebook[data_compra]\"]').value = '2024-01-01'")
      fill_in 'Descrição', with: 'Notebook para testes'

      click_button 'Adicionar Notebook', match: :first

      # 3. Verificar se foi redirecionado para a página do notebook
      expect(page).to have_content('Notebook cadastrado com sucesso!')
      expect(page).to have_content(valid_notebook_attributes[:identificacao_equipamento])
      expect(page).to have_content('Disponível')

      # 4. Voltar para a listagem e verificar se o notebook aparece
      click_link 'Voltar'
      expect(page).to have_content(valid_notebook_attributes[:identificacao_equipamento])
      expect(page).to have_content(valid_notebook_attributes[:numero_patrimonio])

      # 5. Fazer busca por identificação
      fill_in 'query', with: valid_notebook_attributes[:identificacao_equipamento]
      find('button[type="submit"]').click
      expect(page).to have_content(valid_notebook_attributes[:identificacao_equipamento])

      # 6. Acessar o notebook e fazer empréstimo
      click_link 'Ver detalhes', match: :first
      expect(page).to have_content('Emprestar Notebook')

      click_link 'Emprestar Notebook'
      expect(page).to have_content('Emprestar Notebook')

      find('input[name="nome_colaborador"]').set('João Silva')
      find('input[name="setor"]').set('TI')
      click_button 'Confirmar Empréstimo'

      expect(page).to have_content('Notebook emprestado com sucesso!')
      expect(page).to have_content('Emprestado')
      expect(page).to have_content('João Silva')
      expect(page).to have_content('TI')

      # 7. Fazer devolução
      click_link 'Devolver Notebook'
      expect(page).to have_content('Devolver Notebook')

      find('textarea[name="motivo_devolucao"]').set('Devolução normal')
      click_button 'Confirmar Devolução'

      expect(page).to have_content('Notebook devolvido com sucesso!')
      expect(page).to have_content('Disponível')

      # 8. Fazer novo empréstimo para testar baixa
      click_link 'Emprestar Notebook'
      find('input[name="nome_colaborador"]').set('Maria Santos')
      find('input[name="setor"]').set('RH')
      click_button 'Confirmar Empréstimo'

      expect(page).to have_content('Notebook emprestado com sucesso!')

      # 9. Fazer baixa do notebook
      click_link 'Baixar Notebook'
      expect(page).to have_content('Baixar Notebook')

      fill_in 'Justificativa', with: 'Equipamento com defeito irreparável'
      click_button 'Baixar'

      expect(page).to have_content('Notebook baixado com sucesso!')
      expect(page).to have_content('Indisponível')
    end

    it 'permite editar um notebook' do
      notebook = Notebook.create!(valid_notebook_attributes)
      
      visit notebook_path(notebook)
      click_link 'Editar'
      
      expect(page).to have_content('Editar Notebook')
      
      fill_in 'Marca', with: 'HP'
      fill_in 'Modelo', with: 'EliteBook 840'
      click_button 'Atualizar Notebook', match: :first
      
      expect(page).to have_content('Notebook atualizado com sucesso!')
      expect(page).to have_content('HP')
      expect(page).to have_content('EliteBook 840')
    end

    it 'permite excluir notebook disponível e nunca emprestado' do
      notebook = Notebook.create!(valid_notebook_attributes)
      
      visit notebook_path(notebook)
      
      # Verificar se o botão de excluir está disponível
      expect(page).to have_content('Excluir')
      
      # Clicar no botão de excluir para abrir o modal
      click_button 'Excluir', match: :first
      
      # Confirmar exclusão no modal
      within('#deleteModal') do
        click_button 'Excluir'
      end
      
      expect(page).to have_content('Notebook excluído com sucesso!')
      expect(page).not_to have_content(notebook.identificacao_equipamento)
    end

    it 'não permite excluir notebook emprestado' do
      notebook = Notebook.create!(valid_notebook_attributes)
      notebook.emprestar!('João Silva', 'TI')
      
      visit notebook_path(notebook)
      
      # Verificar que não há botão de excluir ou que há mensagem de erro
      expect(page).to have_content('Emprestado')
      expect(page).not_to have_content('Excluir')
    end

    it 'permite filtrar por estado' do
      # Criar notebooks em diferentes estados
      notebook_disponivel = Notebook.create!(valid_notebook_attributes)
      notebook_emprestado = Notebook.create!(valid_notebook_attributes.merge(
        identificacao_equipamento: 'NB002',
        numero_patrimonio: 'PAT124',
        numero_serie: 'SN123457'
      ))
      notebook_emprestado.emprestar!('João Silva', 'TI')
      
      visit root_path
      
      # Filtrar por disponível
      select 'Disponível', from: 'estado'
      find('button[type="submit"]').click
      
      expect(page).to have_content(notebook_disponivel.identificacao_equipamento)
      expect(page).not_to have_content(notebook_emprestado.identificacao_equipamento)
      
      # Filtrar por emprestado
      select 'Emprestado', from: 'estado'
      find('button[type="submit"]').click
      
      expect(page).to have_content(notebook_emprestado.identificacao_equipamento)
      expect(page).not_to have_content(notebook_disponivel.identificacao_equipamento)
    end

    it 'mostra estatísticas corretas na página inicial' do
      # Criar notebooks em diferentes estados
      notebook_disponivel = Notebook.create!(valid_notebook_attributes)
      notebook_emprestado = Notebook.create!(valid_notebook_attributes.merge(
        identificacao_equipamento: 'NB002',
        numero_patrimonio: 'PAT124',
        numero_serie: 'SN123457'
      ))
      notebook_emprestado.emprestar!('João Silva', 'TI')
      
      visit root_path
      
      # Verificar estatísticas
      expect(page).to have_content('Disponíveis')
      expect(page).to have_content('Emprestados')
      expect(page).to have_content('Indisponíveis')
      expect(page).to have_content('Total')
    end
  end
end 