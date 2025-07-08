require 'rails_helper'

RSpec.describe Emprestimo, type: :model do
  describe 'validations' do
    subject { build(:emprestimo) }

    it { should validate_presence_of(:nome_colaborador) }
    it { should validate_presence_of(:setor) }
    it { should validate_presence_of(:data_emprestimo) }
  end

  describe 'associations' do
    it { should belong_to(:notebook) }
  end

  describe 'scopes' do
    let!(:emprestimo_ativo) { create(:emprestimo) }
    let!(:emprestimo_devolvido) { create(:emprestimo, :devolvido) }

    describe '.ativos' do
      it 'returns only active loans' do
        expect(Emprestimo.ativos).to include(emprestimo_ativo)
        expect(Emprestimo.ativos).not_to include(emprestimo_devolvido)
      end
    end

    describe '.devolvidos' do
      it 'returns only returned loans' do
        expect(Emprestimo.devolvidos).to include(emprestimo_devolvido)
        expect(Emprestimo.devolvidos).not_to include(emprestimo_ativo)
      end
    end

    describe '.ordenados' do
      let!(:emprestimo_antigo) { create(:emprestimo, data_emprestimo: 2.days.ago) }
      let!(:emprestimo_recente) { create(:emprestimo, data_emprestimo: 1.day.ago) }

      it 'returns loans ordered by data_emprestimo desc' do
        result = Emprestimo.ordenados.to_a
        expect(result.index(emprestimo_recente)).to be < result.index(emprestimo_antigo)
      end
    end
  end

  describe 'instance methods' do
    let(:emprestimo) { build(:emprestimo) }
    let(:emprestimo_devolvido) { build(:emprestimo, :devolvido) }

    describe '#ativo?' do
      it 'returns true for active loan' do
        expect(emprestimo.ativo?).to be true
      end

      it 'returns false for returned loan' do
        expect(emprestimo_devolvido.ativo?).to be false
      end
    end

    describe '#devolvido?' do
      it 'returns false for active loan' do
        expect(emprestimo.devolvido?).to be false
      end

      it 'returns true for returned loan' do
        expect(emprestimo_devolvido.devolvido?).to be true
      end
    end

    describe '#dias_emprestado' do
      it 'returns nil for active loan' do
        expect(emprestimo.dias_emprestado).to be_nil
      end

      it 'returns correct days for returned loan' do
        emprestimo_devolvido.data_emprestimo = 5.days.ago.to_date
        emprestimo_devolvido.data_devolucao = 2.days.ago.to_date
        expect(emprestimo_devolvido.dias_emprestado).to eq(3)
      end
    end
  end

  describe 'validations' do
    let(:emprestimo) { build(:emprestimo) }

    context 'when return date is before loan date' do
      it 'is invalid' do
        emprestimo.data_emprestimo = Date.current
        emprestimo.data_devolucao = 1.day.ago
        expect(emprestimo).not_to be_valid
        expect(emprestimo.errors[:data_devolucao]).to include('deve ser posterior ou igual à data do empréstimo')
      end
    end

    context 'when return date is after loan date' do
      it 'is valid' do
        emprestimo.data_emprestimo = 1.day.ago
        emprestimo.data_devolucao = Date.current
        expect(emprestimo).to be_valid
      end
    end
  end
end
