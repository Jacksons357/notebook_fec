class Emprestimo < ApplicationRecord
  # Associations
  belongs_to :notebook
  
  # Validations
  validates :nome_colaborador, presence: true
  validates :setor, presence: true
  validates :data_emprestimo, presence: true
  validate :data_devolucao_apos_emprestimo, if: :data_devolucao?
  
  # Scopes
  scope :ativos, -> { where(data_devolucao: nil) }
  scope :devolvidos, -> { where.not(data_devolucao: nil) }
  scope :ordenados, -> { order(data_emprestimo: :desc) }
  
  # Instance methods
  def ativo?
    data_devolucao.nil?
  end
  
  def devolvido?
    data_devolucao.present?
  end
  
  def dias_emprestado
    return nil unless data_devolucao
    (data_devolucao - data_emprestimo).to_i
  end
  
  private
  
  def data_devolucao_apos_emprestimo
    if data_devolucao < data_emprestimo
      errors.add(:data_devolucao, "deve ser posterior ou igual à data do empréstimo")
    end
  end
end
