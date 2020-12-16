class CreateTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|
      t.integer :api_id
      t.string :name
      t.string :abbreviation
      t.string :city
      t.string :division
      t.string :conference
      t.string :website
    end
  end
end
