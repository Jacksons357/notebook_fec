class NotebooksController < ApplicationController
  before_action :set_notebook, only: [:show, :edit, :update, :destroy, :emprestar, :devolver, :baixar, :download_pdf]

  def index
    # Prevent caching to ensure filters work correctly
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
    
    # Log filter parameters for debugging
    Rails.logger.info "Filter params: query=#{params[:query]}, estado=#{params[:estado]}"
    
    @notebooks = Notebook.includes(:emprestimos)
                        .order(Arel.sql("CASE estado 
                                        WHEN 0 THEN 1 
                                        WHEN 1 THEN 2 
                                        WHEN 2 THEN 3 
                                        END, identificacao_equipamento"))
    
    # Apply search filter if query is present and not blank
    if params[:query].present? && params[:query].strip.present?
      query = params[:query].strip
      Rails.logger.info "Applying search filter: #{query}"
      @notebooks = @notebooks.buscar(query)
    end
    
    # Apply status filter if estado is present and not blank
    if params[:estado].present? && params[:estado].strip.present?
      estado = params[:estado].strip
      Rails.logger.info "Applying status filter: #{estado}"
      @notebooks = @notebooks.where(estado: estado)
    end
    
    Rails.logger.info "Final notebooks count: #{@notebooks.count}"
  end

  def show
    @historico_status = @notebook.historico_status_notebooks.ordenados
    @emprestimos = @notebook.emprestimos.ordenados
  end

  def new
    @notebook = Notebook.new
  end

  def create
    @notebook = Notebook.new(notebook_params)
    
    if @notebook.save
      redirect_to @notebook, notice: 'Notebook cadastrado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @notebook.update(notebook_params)
      redirect_to @notebook, notice: 'Notebook atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @notebook.pode_ser_excluido?
      @notebook.destroy
      redirect_to notebooks_path, notice: 'Notebook excluído com sucesso!'
    else
      motivo = if !@notebook.disponivel?
        'O notebook só pode ser excluído se estiver disponível.'
      elsif @notebook.emprestimos.any?
        'O notebook não pode ser excluído porque já foi emprestado. Use a funcionalidade de baixa para removê-lo do uso.'
      else
        'Não é possível excluir este notebook.'
      end
      redirect_to @notebook, alert: motivo
    end
  end

  def emprestar
    if request.post?
      if @notebook.emprestar!(params[:nome_colaborador], params[:setor])
        redirect_to @notebook, notice: 'Notebook emprestado com sucesso!'
      else
        redirect_to @notebook, alert: 'Não foi possível emprestar o notebook.'
      end
    end
  end

  def devolver
    if request.post?
      if @notebook.devolver!(params[:motivo_devolucao])
        redirect_to @notebook, notice: 'Notebook devolvido com sucesso!'
      else
        redirect_to @notebook, alert: 'Não foi possível devolver o notebook.'
      end
    end
  end

  def baixar
    if request.post?
      if @notebook.baixar!(params[:justificativa])
        redirect_to @notebook, notice: 'Notebook baixado com sucesso!'
      else
        redirect_to @notebook, alert: 'Não foi possível baixar o notebook.'
      end
    end
  end

  def download_pdf
    if @notebook.nota_fiscal_pdf.attached?
      send_data @notebook.nota_fiscal_pdf.download,
                filename: @notebook.nota_fiscal_pdf.filename.to_s,
                type: @notebook.nota_fiscal_pdf.content_type,
                disposition: 'attachment'
    else
      redirect_to @notebook, alert: 'Nenhum arquivo PDF anexado a este notebook.'
    end
  end



  private

  def set_notebook
    @notebook = Notebook.find(params[:id])
  end

  def notebook_params
    params.require(:notebook).permit(
      :marca, :modelo, :numero_patrimonio, :numero_serie, :identificacao_equipamento,
      :data_compra, :data_fabricacao, :descricao, :nota_fiscal_pdf
    )
  end
end
