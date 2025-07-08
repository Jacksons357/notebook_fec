FactoryBot.define do
  factory :historico_status_notebook do
    association :notebook
    estado { :disponivel }
    data_alteracao { Time.current }
    informacoes_adicionais { "Notebook cadastrado no sistema" }

    trait :emprestado do
      estado { :emprestado }
      informacoes_adicionais { "Notebook emprestado" }
    end

    trait :indisponivel do
      estado { :indisponivel }
      informacoes_adicionais { "Notebook baixado do sistema" }
    end

    trait :devolvido do
      estado { :disponivel }
      informacoes_adicionais { "Notebook devolvido" }
    end
  end
end 