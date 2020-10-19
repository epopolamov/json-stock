# frozen_string_literal: true

class Bearer < ApplicationRecord
  has_many :stock

  validates :name, length: { in: 0..255, allow_nil: false }
  validates :name, uniqueness: { allow_blank: false }, presence: true
end
