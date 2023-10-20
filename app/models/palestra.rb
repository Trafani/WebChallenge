class Palestra < ApplicationRecord
  validates :nome, presence: true
  validates :duracao, presence: true, numericality: { greater_than_or_equal_to: 5 }
end
