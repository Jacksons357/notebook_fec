require 'rails_helper'

RSpec.describe Notebook, type: :model do
  subject { build(:notebook) }

  describe 'validations' do
    it { should validate_presence_of(:marca) }
    it { should validate_presence_of(:modelo) }
    it { should validate_presence_of(:numero_patrimonio) }
    it { should validate_presence_of(:numero_serie) }
    it { should validate_presence_of(:identificacao_equipamento) }
    it { should validate_presence_of(:data_compra) }
    it { should validate_presence_of(:estado) }

    it { should validate_uniqueness_of(:numero_patrimonio).case_insensitive }
    it { should validate_uniqueness_of(:numero_serie).case_insensitive }
    it { should validate_uniqueness_of(:identificacao_equipamento).case_insensitive }
  end

  describe 'associations' do
    it { should have_many(:historico_status_notebooks).dependent(:destroy) }
    it { should have_many(:emprestimos).dependent(:destroy) }
    it { should have_one_attached(:nota_fiscal_pdf) }
  end

  describe 'enums' do
    it { should define_enum_for(:estado).with_values(disponivel: 0, emprestado: 1, indisponivel: 2) }
  end

  describe 'scopes' do
    let!(:notebook_disponivel) { create(:notebook, estado: :disponivel) }
    let!(:notebook_emprestado) { create(:notebook, estado: :emprestado) }
    let!(:notebook_indisponivel) { create(:notebook, estado: :indisponivel) }
    let!(:notebook_com_emprestimo) { create(:notebook, :emprestado) }
    let!(:notebook_sem_emprestimo) { create(:notebook) }

    describe '.disponiveis' do
      it 'returns only available notebooks' do
        expect(Notebook.disponiveis).to include(notebook_disponivel)
        expect(Notebook.disponiveis).not_to include(notebook_emprestado, notebook_indisponivel)
      end
    end

    describe '.emprestados' do
      it 'returns only borrowed notebooks' do
        expect(Notebook.emprestados).to include(notebook_emprestado)
        expect(Notebook.emprestados).not_to include(notebook_disponivel, notebook_indisponivel)
      end
    end

    describe '.indisponiveis' do
      it 'returns only unavailable notebooks' do
        expect(Notebook.indisponiveis).to include(notebook_indisponivel)
        expect(Notebook.indisponiveis).not_to include(notebook_disponivel, notebook_emprestado)
      end
    end

    describe '.nunca_emprestados' do
      it 'returns notebooks that have never been borrowed' do
        expect(Notebook.nunca_emprestados).to include(notebook_sem_emprestimo)
        expect(Notebook.nunca_emprestados).not_to include(notebook_com_emprestimo)
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      it 'creates initial status history' do
        notebook = build(:notebook)
        expect { notebook.save! }.to change(HistoricoStatusNotebook, :count).by(1)
        
        history = notebook.historico_status_notebooks.last
        expect(history.estado).to eq('disponivel')
        expect(history.informacoes_adicionais).to eq('Notebook cadastrado no sistema')
      end
    end

    describe 'after_update' do
      it 'creates status history when estado changes' do
        notebook = create(:notebook)
        expect { notebook.update!(estado: :emprestado) }.to change(HistoricoStatusNotebook, :count).by(1)
        
        history = notebook.historico_status_notebooks.last
        expect(history.estado).to eq('emprestado')
      end

      it 'does not create status history when other attributes change' do
        notebook = create(:notebook)
        expect { notebook.update!(marca: 'Nova Marca') }.not_to change(HistoricoStatusNotebook, :count)
      end
    end
  end

  describe 'instance methods' do
    describe '#emprestimo_atual' do
      let(:notebook) { create(:notebook, :emprestado) }
      let(:emprestimo_devolvido) { create(:emprestimo, :devolvido, notebook: notebook) }

      it 'returns the active loan' do
        expect(notebook.emprestimo_atual).to eq(notebook.emprestimos.where(data_devolucao: nil).first)
      end

      it 'returns nil when no active loan' do
        notebook.emprestimos.update_all(data_devolucao: Date.current)
        expect(notebook.emprestimo_atual).to be_nil
      end
    end

    describe '#pode_ser_excluido?' do
      let(:notebook_disponivel) { create(:notebook) }
      let(:notebook_emprestado) { create(:notebook, :emprestado) }
      let(:notebook_com_historico) { create(:notebook) }

      before do
        create(:emprestimo, notebook: notebook_com_historico, data_emprestimo: 5.days.ago, data_devolucao: 2.days.ago)
      end

      it 'returns true for available notebook with no loans' do
        expect(notebook_disponivel.pode_ser_excluido?).to be true
      end

      it 'returns false for borrowed notebook' do
        expect(notebook_emprestado.pode_ser_excluido?).to be false
      end

      it 'returns false for notebook with loan history' do
        expect(notebook_com_historico.pode_ser_excluido?).to be false
      end
    end

    describe '#emprestar!' do
      let(:notebook) { create(:notebook) }

      context 'when notebook is available' do
        it 'changes estado to emprestado' do
          expect { notebook.emprestar!('João Silva', 'TI') }.to change { notebook.reload.estado }.to('emprestado')
        end

        it 'creates a loan record' do
          expect { notebook.emprestar!('João Silva', 'TI') }.to change(Emprestimo, :count).by(1)
        end

        it 'creates loan with correct attributes' do
          notebook.emprestar!('João Silva', 'TI')
          emprestimo = notebook.emprestimos.last
          expect(emprestimo.nome_colaborador).to eq('João Silva')
          expect(emprestimo.setor).to eq('TI')
          expect(emprestimo.data_emprestimo).to eq(Date.current)
        end

        it 'returns true' do
          expect(notebook.emprestar!('João Silva', 'TI')).to be true
        end
      end

      context 'when notebook is not available' do
        let(:notebook_emprestado) { create(:notebook) }

        before do
          notebook_emprestado.emprestar!('João Silva', 'TI')
        end

        it 'returns false' do
          expect(notebook_emprestado.emprestar!('Maria Silva', 'RH')).to be false
        end

        it 'does not create loan' do
          expect { notebook_emprestado.emprestar!('Maria Silva', 'RH') }.not_to change(Emprestimo, :count)
        end
      end
    end

    describe '#devolver!' do
      let(:notebook) { create(:notebook) }

      before do
        notebook.emprestar!('João Silva', 'TI')
      end

      context 'when notebook is borrowed' do
        it 'changes estado to disponivel' do
          expect { notebook.devolver!('Bom estado') }.to change { notebook.reload.estado }.to('disponivel')
        end

        it 'updates loan with return information' do
          notebook.devolver!('Bom estado')
          emprestimo = notebook.emprestimos.last
          expect(emprestimo.data_devolucao).to eq(Date.current)
          expect(emprestimo.motivo_devolucao).to eq('Bom estado')
        end

        it 'returns true' do
          expect(notebook.devolver!('Bom estado')).to be true
        end
      end

      context 'when notebook is not borrowed' do
        let(:notebook_disponivel) { create(:notebook) }

        it 'returns false' do
          expect(notebook_disponivel.devolver!('Bom estado')).to be false
        end
      end
    end

    describe '#baixar!' do
      let(:notebook) { create(:notebook) }

      before do
        notebook.emprestar!('João Silva', 'TI')
      end

      context 'when notebook is borrowed' do
        it 'changes estado to indisponivel' do
          expect { notebook.baixar!('Tela quebrada') }.to change { notebook.reload.estado }.to('indisponivel')
        end

        it 'updates loan with deactivation information' do
          notebook.baixar!('Tela quebrada')
          emprestimo = notebook.emprestimos.last
          expect(emprestimo.data_devolucao).to eq(Date.current)
          expect(emprestimo.motivo_devolucao).to eq('Baixa: Tela quebrada')
        end

        it 'returns true' do
          expect(notebook.baixar!('Tela quebrada')).to be true
        end
      end

      context 'when notebook is not borrowed' do
        let(:notebook_disponivel) { create(:notebook) }

        it 'returns false' do
          expect(notebook_disponivel.baixar!('Tela quebrada')).to be false
        end
      end
    end
  end

  describe 'search' do
    let!(:notebook1) { create(:notebook, identificacao_equipamento: 'NB001', numero_patrimonio: '2024001') }
    let!(:notebook2) { create(:notebook, identificacao_equipamento: 'NB002', numero_patrimonio: '2024002') }
    let!(:emprestimo) { create(:emprestimo, notebook: notebook1, nome_colaborador: 'João Silva', setor: 'TI') }

    it 'finds notebook by identificacao_equipamento' do
      expect(Notebook.buscar('NB001')).to include(notebook1)
    end

    it 'finds notebook by numero_patrimonio' do
      expect(Notebook.buscar('2024001')).to include(notebook1)
    end

    it 'finds notebook by employee name' do
      expect(Notebook.buscar('João')).to include(notebook1)
    end

    it 'finds notebook by department' do
      expect(Notebook.buscar('TI')).to include(notebook1)
    end

    it 'returns empty when no match' do
      expect(Notebook.buscar('inexistente')).to be_empty
    end
  end

  describe 'nota_fiscal_pdf validation' do
    let(:notebook) { build(:notebook) }

    it 'accepts PDF files' do
      notebook.nota_fiscal_pdf.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.pdf')),
        filename: 'nota_fiscal.pdf',
        content_type: 'application/pdf'
      )
      expect(notebook).to be_valid
    end

    it 'rejects non-PDF files' do
      notebook.nota_fiscal_pdf.attach(
        io: StringIO.new('not a pdf'),
        filename: 'document.txt',
        content_type: 'text/plain'
      )
      expect(notebook).not_to be_valid
      expect(notebook.errors[:nota_fiscal_pdf]).to include('deve ser um arquivo PDF')
    end
  end
end
