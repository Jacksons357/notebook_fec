# Sistema de gerenciamento de notebooks

Sistema web para gestão de notebooks corporativos, desenvolvido em Ruby on Rails.

## Funcionalidades

- Cadastro, edição e exclusão de notebooks
- Empréstimo, devolução e baixa de notebooks
- Upload de nota fiscal em PDF
- Histórico de estados do notebook
- Busca e filtros avançados
- Interface amigável e responsiva
- Testes unitários, de request e de sistema (integração)

## Requisitos

- Ruby 3.3+
- Rails 8+
- MySQL 5.7+ ou MariaDB
- Node.js e Yarn (para assets)
- Chrome/Chromedriver (para testes de sistema)

## Instalação

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/Jacksons357/notebook_fec.git
   cd notebook_fec
   ```

2. **Instale as dependências:**

   ```bash
   bundle install
   yarn install --check-files
   ```

3. **Configure o banco de dados:**

   - Edite `config/database.yml` com suas credenciais.
   - Crie e migre o banco:
     ```bash
     bundle exec rails db:create db:migrate
     ```

4. **(Opcional) Popule com dados de exemplo:**

   ```bash
   bundle exec rails db:seed
   ```

5. **Inicie o servidor:**
   ```bash
   bundle exec rails server
   ```
   Acesse em [http://localhost:3000](http://localhost:3000)

## Testes

- **Executar todos os testes:**
  ```bash
  bundle exec rspec
  ```
- **Executar testes de sistema (integração):**
  ```bash
  bundle exec rspec spec/system
  ```
- **Ver relatório de cobertura:**
  Após rodar os testes, abra `coverage/index.html` no navegador.

## Upload de Nota Fiscal

- O upload de PDF é feito no cadastro/edição do notebook.
- O arquivo é armazenado localmente via ActiveStorage.

## Estrutura do Projeto

- `app/models` — Models principais (`Notebook`, `Emprestimo`, `HistoricoStatusNotebook`)
- `app/controllers` — Controllers RESTful
- `app/views` — Views em ERB com TailwindCSS
- `spec/` — Testes unitários, requests e system

## Internacionalização

- O sistema está em português (pt-BR) por padrão.

## Observações

- Para rodar testes de sistema, é necessário ter o Chrome e o Chromedriver instalados.
- O sistema exige que o banco de dados esteja rodando.
