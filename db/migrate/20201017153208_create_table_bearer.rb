# frozen_string_literal: true

class CreateTableBearer < ActiveRecord::Migration[6.0]
  def up
    return if table_exists? :bearers

    create_table :bearers do |t|
      t.string :name, null: false

      t.timestamps
    end
  end

  def down
    return unless table_exists? :bearers

    drop_table :bearers
  end
end
