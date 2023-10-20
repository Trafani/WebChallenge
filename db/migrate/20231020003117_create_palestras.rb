class CreatePalestras < ActiveRecord::Migration[7.1]
  def change
    execute <<~SQL
      CREATE TABLE IF NOT EXISTS palestras (
        id serial PRIMARY KEY,
        nome varchar(255) UNIQUE NOT NULL,
        duracao integer NOT NULL,
        created_at timestamp without time zone,
        updated_at timestamp without time zone
      );
    SQL
  end
end
