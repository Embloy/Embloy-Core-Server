# frozen_string_literal: true

class CreateJobLists < ActiveRecord::Migration[7.0]
  def change
    create_table :job_lists do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
