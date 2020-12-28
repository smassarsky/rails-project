class CreateGames < ActiveRecord::Migration[6.0]
  def change

    create_table :games do |t|
      t.integer :api_id
      t.datetime :datetime
      t.string :game_type
      t.string :season
      t.string :status
    end

    create_table :game_teams do |t|
      t.integer :game_id
      t.integer :team_id
      t.string :home_away
    end

    create_table :players do |t|
      t.integer :api_id
      t.string :name
    end

    create_table :game_players do |t|
      t.integer :game_id
      t.integer :player_id
      t.integer :team_id
      t.string :position
      t.integer :jersey_num
    end

  end
end
