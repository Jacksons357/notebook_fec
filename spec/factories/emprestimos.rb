FactoryBot.define do
  factory :emprestimo do
    association :notebook
    nome_colaborador { Faker::Name.name }
    setor { Faker::Company.department }
    data_emprestimo { Faker::Date.between(from: 30.days.ago, to: Date.current) }

    trait :devolvido do
      data_devolucao { Faker::Date.between(from: data_emprestimo, to: Date.current) }
      motivo_devolucao { Faker::Lorem.sentence }
    end

    trait :com_motivo_devolucao do
      data_devolucao { Faker::Date.between(from: data_emprestimo, to: Date.current) }
      motivo_devolucao { "Equipamento devolvido por #{Faker::Lorem.word}" }
    end
  end
end 