class HistoricoStatusNotebook < ApplicationRecord
  # Enums
  enum :estado, { disponivel: 0, emprestado: 1, indisponivel: 2 }
  
  # Associations
  belongs_to :notebook
  
  # Validations
  validates :estado, presence: true
  validates :data_alteracao, presence: true
  
  # Scopes
  scope :ordenados, -> { order(data_alteracao: :desc) }
  
  # Instance methods
  def texto_estado
    case estado
    when 'disponivel'
      'Disponível'
    when 'emprestado'
      'Emprestado'
    when 'indisponivel'
      'Indisponível'
    end
  end
end
