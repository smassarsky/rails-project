class CreateTables < ActiveRecord::Migration[6.0]
  def change
    
    create_table :matchups do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :end_date
      t.integer :owner_id
      t.integer :team_id
    end

    create_table :user_matchups do |t|
      t.string :nickname
      t.integer :user_id
      t.integer :matchup_id
    end

    create_table :picks do |t|
      t.integer :user_matchup_id
      t.integer :player_id
    end


  end
end
