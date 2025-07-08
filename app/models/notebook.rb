class Notebook < ApplicationRecord
  # Enums
  enum :estado, { disponivel: 0, emprestado: 1, indisponivel: 2 }, default: :disponivel
  
  # Associations
  has_many :historico_status_notebooks, dependent: :destroy
  has_many :emprestimos, dependent: :destroy
  has_one_attached :nota_fiscal_pdf
  
  # Validations
  validates :marca, presence: { message: "é obrigatória" }
  validates :modelo, presence: { message: "é obrigatório" }
  validates :numero_patrimonio, presence: { message: "é obrigatório" }, uniqueness: { message: "já está em uso" }
  validates :numero_serie, presence: { message: "é obrigatório" }, uniqueness: { message: "já está em uso" }
  validates :identificacao_equipamento, presence: { message: "é obrigatória" }, uniqueness: { message: "já está em uso" }
  validates :data_compra, presence: { message: "é obrigatória" }
  validates :estado, presence: { message: "é obrigatório" }
  validate :nota_fiscal_pdf_deve_ser_pdf
  
  # Callbacks
  after_create :criar_historico_inicial
  after_update :criar_historico_status, if: :saved_change_to_estado?
  
  # Scopes
  scope :disponiveis, -> { where(estado: 0) }
  scope :emprestados, -> { where(estado: 1) }
  scope :indisponiveis, -> { where(estado: 2) }
  scope :nunca_emprestados, -> { left_joins(:emprestimos).where(emprestimos: { id: nil }) }
  
  # Search method
  def self.buscar(query)
    return all if query.blank?
    
    where("notebooks.identificacao_equipamento LIKE ? OR notebooks.numero_serie LIKE ? OR notebooks.numero_patrimonio LIKE ? OR 
           DATE_FORMAT(notebooks.data_compra, '%d/%m/%Y') LIKE ? OR 
           EXISTS (
             SELECT 1 FROM emprestimos 
             WHERE emprestimos.notebook_id = notebooks.id 
             AND (emprestimos.nome_colaborador LIKE ? OR emprestimos.setor LIKE ?)
           )",
          "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
  end
  
  # Instance methods
  def emprestimo_atual
    emprestimos.where(data_devolucao: nil).first
  end
  
  def pode_ser_excluido?
    disponivel? && emprestimos.empty?
  end
  
  def emprestar!(nome_colaborador, setor)
    return false unless disponivel?
    
    transaction do
      update!(estado: :emprestado)
      emprestimos.create!(
        nome_colaborador: nome_colaborador,
        setor: setor,
        data_emprestimo: Date.current
      )
    end
    true
  rescue => e
    false
  end
  
  def devolver!(motivo_devolucao = nil)
    return false unless emprestado?
    
    emprestimo_atual = self.emprestimo_atual
    return false unless emprestimo_atual
    
    transaction do
      update!(estado: :disponivel)
      emprestimo_atual.update!(
        data_devolucao: Date.current,
        motivo_devolucao: motivo_devolucao
      )
    end
    
    true
  rescue => e
    Rails.logger.error "Erro em devolver!: #{e.message}"
    false
  end
  
  def baixar!(justificativa)
    return false unless emprestado?
    
    emprestimo_atual = self.emprestimo_atual
    return false unless emprestimo_atual
    
    transaction do
      update!(estado: :indisponivel)
      emprestimo_atual.update!(
        data_devolucao: Date.current,
        motivo_devolucao: "Baixa: #{justificativa}"
      )
    end
    
    true
  rescue => e
    Rails.logger.error "Erro em baixar!: #{e.message}"
    false
  end
  
  private
  
  def criar_historico_inicial
    historico_status_notebooks.create!(
      estado: estado,
      data_alteracao: created_at,
      informacoes_adicionais: "Notebook cadastrado no sistema"
    )
  end
  
  def criar_historico_status
    historico_status_notebooks.create!(
      estado: estado,
      data_alteracao: Time.current,
      informacoes_adicionais: motivo_mudanca_estado
    )
  end
  
  def motivo_mudanca_estado
    case estado
    when 'emprestado'
      "Emprestado para #{emprestimo_atual&.nome_colaborador} do setor #{emprestimo_atual&.setor}"
    when 'disponivel'
      emprestimo_devolvido = emprestimos.where.not(data_devolucao: nil).order(data_devolucao: :desc).first
      emprestimo_devolvido&.motivo_devolucao || "Disponibilizado no sistema"
    when 'indisponivel'
      "Baixado do sistema"
    end
  end

  def nota_fiscal_pdf_deve_ser_pdf
    return unless nota_fiscal_pdf.attached?
    if !nota_fiscal_pdf.content_type.in?(["application/pdf"])
      errors.add(:nota_fiscal_pdf, "deve ser um arquivo PDF")
    end
  end
end
