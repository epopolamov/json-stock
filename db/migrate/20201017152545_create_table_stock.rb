# frozen_string_literal: true

class CreateTableStock < ActiveRecord::Migration[6.0]
  def up
    return if table_exists? :stocks

    create_table :stocks do |t|
      t.string :name, null: false
      t.integer :bearer_id, null: false
      t.boolean :deleted, default: false

      t.timestamps
    end
  end

  def down
    return unless table_exists? :stocks

    drop_table :stocks
  end
end
