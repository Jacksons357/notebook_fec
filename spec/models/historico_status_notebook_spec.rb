require 'rails_helper'

RSpec.describe HistoricoStatusNotebook, type: :model do
  describe 'validations' do
    subject { build(:historico_status_notebook) }

    it { should validate_presence_of(:estado) }
    it { should validate_presence_of(:data_alteracao) }
  end

  describe 'associations' do
    it { should belong_to(:notebook) }
  end

  describe 'enums' do
    it { should define_enum_for(:estado).with_values(disponivel: 0, emprestado: 1, indisponivel: 2) }
    it { should define_enum_for(:estado).backed_by_column_of_type(:integer) }
  end

  describe 'scopes' do
    let!(:historico_antigo) { create(:historico_status_notebook, data_alteracao: 1.day.ago) }
    let!(:historico_recente) { create(:historico_status_notebook, data_alteracao: Time.current) }

    describe '.ordenados' do
      it 'returns records ordered by data_alteracao desc' do
        result = HistoricoStatusNotebook.ordenados.to_a
        expect(result.index(historico_recente)).to be < result.index(historico_antigo)
      end
    end
  end

  describe 'instance methods' do
    let(:historico) { build(:historico_status_notebook) }

    describe '#texto_estado' do
      it 'returns correct text for disponivel' do
        historico.estado = :disponivel
        expect(historico.texto_estado).to eq('Disponível')
      end

      it 'returns correct text for emprestado' do
        historico.estado = :emprestado
        expect(historico.texto_estado).to eq('Emprestado')
      end

      it 'returns correct text for indisponivel' do
        historico.estado = :indisponivel
        expect(historico.texto_estado).to eq('Indisponível')
      end
    end
  end
end
