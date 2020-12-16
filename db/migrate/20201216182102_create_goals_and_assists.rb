class CreateGoalsAndAssists < ActiveRecord::Migration[6.0]
  def change

    create_table :goals do |t|
      t.integer :game_id
      t.integer :player_id
      t.integer :team_id
      t.integer :api_id
      t.string :time
      t.string :period
    end

    create_table :assists do |t|
      t.integer :goal_id
      t.integer :player_id
    end

  end
end
