FactoryBot.define do
  factory :notebook do
    marca { Faker::Company.name }
    modelo { Faker::Device.model_name }
    numero_patrimonio { "PAT#{Faker::Number.number(digits: 6)}" }
    numero_serie { "SN#{Faker::Alphanumeric.alphanumeric(number: 10).upcase}" }
    identificacao_equipamento { "NB#{Faker::Number.number(digits: 3)}" }
    data_compra { Faker::Date.between(from: 2.years.ago, to: Date.current) }
    data_fabricacao { Faker::Date.between(from: 3.years.ago, to: 1.year.ago) }
    descricao { Faker::Lorem.sentence }
    estado { :disponivel }

    trait :emprestado do
      estado { :emprestado }
      after(:create) do |notebook|
        create(:emprestimo, notebook: notebook)
      end
    end

    trait :indisponivel do
      estado { :indisponivel }
    end

    trait :com_nota_fiscal do
      after(:create) do |notebook|
        notebook.nota_fiscal_pdf.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample.pdf')),
          filename: 'nota_fiscal.pdf',
          content_type: 'application/pdf'
        )
      end
    end
  end
end 