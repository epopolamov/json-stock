# frozen_string_literal: true

class Stock < ApplicationRecord
  default_scope -> { where(deleted: false) }

  validates :name, uniqueness: { allow_blank: false }, presence: true

  belongs_to :bearer
end
