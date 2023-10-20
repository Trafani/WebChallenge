namespace :db do
  desc 'Configura o banco de dados PostgreSQL e executa migrações'
  task setup_database: :environment do
    # Configura o banco de dados
    system('rails db:create')
    
    # Executa todas as migrações
    system('rails db:migrate')
  end
end
