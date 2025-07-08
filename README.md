# Sistema de Gerenciamento de Notebooks

Sistema web para gestão de notebooks corporativos, desenvolvido em Ruby on Rails 8. Permite o controle completo do ciclo de vida dos notebooks, desde o cadastro até a baixa.

## 📋 Funcionalidades

### Gestão de Notebooks

- ✅ Cadastro, edição e visualização de notebooks
- ✅ Upload de nota fiscal em PDF
- ✅ Histórico completo de estados do notebook
- ✅ Busca e filtros avançados

### Controle de Empréstimos

- ✅ Empréstimo de notebooks para funcionários
- ✅ Devolução de notebooks
- ✅ Baixa de notebooks (desativação)
- ✅ Rastreamento completo do ciclo de vida

### Interface e Usabilidade

- ✅ Interface responsiva e amigável
- ✅ Design moderno com TailwindCSS
- ✅ PWA (Progressive Web App) habilitado
- ✅ Navegação intuitiva

### Qualidade e Testes

- ✅ Testes unitários (RSpec)
- ✅ Testes de request
- ✅ Testes de sistema (integração)
- ✅ Cobertura de código com SimpleCov

## 🛠️ Requisitos do Sistema

### Software Necessário

- **Ruby**: 3.3.6 ou superior
- **Rails**: 8.0.2 ou superior
- **MySQL**: 5.7+ ou MariaDB 10.2+
- **Node.js**: 18+ (para assets)
- **Yarn**: Para gerenciamento de dependências JavaScript

### Para Testes

- **Chrome/Chromium**: Navegador para testes de sistema
- **ChromeDriver**: Driver para automação de testes

## 🚀 Instalação e Configuração

### 1. Clone o Repositório

```bash
git clone https://github.com/Jacksons357/notebook_fec.git
cd notebook_fec
```

### 2. Instale as Dependências

```bash
# Instalar gems do Ruby
bundle install

# Instalar dependências JavaScript
yarn install --check-files
```

### 3. Configure o Banco de Dados

#### Opção A: Usando as Configurações Padrão

O sistema vem configurado com as seguintes credenciais padrão:

- **Host**: localhost
- **Porta**: 3306
- **Usuário**: root
- **Senha**: admin
- **Banco de Desenvolvimento**: notebook_development
- **Banco de Teste**: notebook_test

Se você tem um MySQL configurado com essas credenciais, pode prosseguir diretamente.

#### Opção B: Configuração Personalizada

Edite o arquivo `config/database.yml` com suas credenciais:

```yaml
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: SEU_USUARIO
  password: SUA_SENHA
  host: <%= ENV.fetch("DB_HOST") { "localhost" } %>
  port: <%= ENV.fetch("DB_PORT") { 3306 } %>
```

### 4. Crie e Configure o Banco de Dados

```bash
# Criar bancos de dados
bundle exec rails db:create

# Executar migrações
bundle exec rails db:migrate

# (Opcional) Carregar dados de exemplo
bundle exec rails db:seed
```

### 5. Inicie o Servidor

```bash
bundle exec rails server
```

O sistema estará disponível em: **http://localhost:3000**

## 🧪 Executando Testes

### Todos os Testes

```bash
bundle exec rspec
```

### Testes Específicos

```bash
# Apenas testes unitários
bundle exec rspec spec/models

# Apenas testes de controller
bundle exec rspec spec/requests

# Apenas testes de sistema (integração)
bundle exec rspec spec/system
```

### Cobertura de Código

Após executar os testes, visualize o relatório de cobertura:

```bash
# Abra no navegador
open coverage/index.html
# ou
firefox coverage/index.html
```

## 🐳 Deploy com Docker

### Build da Imagem

```bash
docker build -t notebook .
```

### Executar Container

```bash
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=<sua_master_key> \
  --name notebook notebook
```

### Deploy com Kamal

```bash
# Configurar Kamal (ver config/deploy.yml)
kamal setup
kamal deploy
```

## 📱 Como Usar o Sistema

### Acessando o Sistema

1. Abra seu navegador
2. Acesse `http://localhost:3000`
3. Você será direcionado para a página principal de notebooks

### Funcionalidades Principais

#### Cadastrar um Notebook

1. Clique em "Novo Notebook"
2. Preencha os dados obrigatórios:
   - **Patrimônio**: Número do patrimônio
   - **Marca**: Fabricante (ex: Dell, HP, Lenovo)
   - **Modelo**: Modelo específico
   - **Série**: Número de série
   - **Status**: Estado atual (Ativo, Inativo, Em Manutenção)
3. **Upload da Nota Fiscal**: Anexe o PDF da nota fiscal
4. Clique em "Criar Notebook"

#### Emprestar um Notebook

1. Na listagem de notebooks, clique em "Emprestar" ao lado do notebook desejado
2. Preencha os dados do empréstimo:
   - **Funcionário**: Nome do funcionário
   - **Data de Empréstimo**: Data atual (preenchida automaticamente)
   - **Observações**: Informações adicionais (opcional)
3. Clique em "Confirmar Empréstimo"

#### Devolver um Notebook

1. Na listagem de notebooks, clique em "Devolver" ao lado do notebook emprestado
2. Confirme a devolução
3. O notebook voltará ao status "Ativo"

#### Baixar um Notebook

1. Na listagem de notebooks, clique em "Baixar" ao lado do notebook
2. Confirme a baixa
3. O notebook será marcado como "Baixado" e não poderá mais ser emprestado

#### Buscar e Filtrar

- Use a barra de busca para encontrar notebooks por patrimônio, marca, modelo ou série
- Use os filtros para refinar a busca por status

## 🔧 Configurações Avançadas

### Variáveis de Ambiente

Configure as seguintes variáveis de ambiente para produção:

```bash
# Banco de dados
DB_HOST=localhost
DB_PORT=3306
NOTEBOOK_DATABASE_PASSWORD=sua_senha_segura

# Rails
RAILS_ENV=production
RAILS_MASTER_KEY=sua_master_key
SECRET_KEY_BASE=sua_secret_key
```

### Configuração de Storage

O sistema usa ActiveStorage para upload de arquivos. Em produção, configure:

```bash
# Para AWS S3
AWS_ACCESS_KEY_ID=sua_access_key
AWS_SECRET_ACCESS_KEY=sua_secret_key
AWS_REGION=sua_regiao
AWS_BUCKET=seu_bucket
```

## 📁 Estrutura do Projeto

```
notebook/
├── app/
│   ├── controllers/          # Controllers RESTful
│   ├── models/              # Models principais
│   │   ├── notebook.rb      # Modelo principal
│   │   ├── emprestimo.rb    # Gestão de empréstimos
│   │   └── historico_status_notebook.rb
│   ├── views/               # Views em ERB
│   └── assets/              # CSS, JS e imagens
├── config/                  # Configurações do Rails
├── db/                      # Migrações e seeds
├── spec/                    # Testes (RSpec)
│   ├── models/             # Testes unitários
│   ├── requests/           # Testes de controller
│   └── system/             # Testes de integração
└── public/                 # Arquivos públicos
```

## 🌐 Internacionalização

O sistema está configurado em português brasileiro (pt-BR) por padrão. Os arquivos de tradução estão em `config/locales/`.

## 🔒 Segurança

- Validações robustas em todos os formulários
- Sanitização de dados de entrada
- Proteção contra ataques comuns (CSRF, XSS)
- Análise de segurança com Brakeman

## 🐛 Solução de Problemas

### Erro de Conexão com Banco

```bash
# Verificar se o MySQL está rodando
sudo systemctl status mysql

# Verificar credenciais
mysql -u root -p
```

### Erro de Dependências

```bash
# Limpar cache do bundle
bundle clean --force

# Reinstalar dependências
bundle install
```

### Erro nos Testes

```bash
# Verificar se o ChromeDriver está instalado
chromedriver --version

# Instalar ChromeDriver (Ubuntu/Debian)
sudo apt-get install chromium-chromedriver
```

---

**Desenvolvido com ❤️ usando Ruby on Rails 8**
