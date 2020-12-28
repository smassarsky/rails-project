# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_18_152735) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assists", force: :cascade do |t|
    t.integer "goal_id"
    t.integer "player_id"
  end

  create_table "game_players", force: :cascade do |t|
    t.integer "game_id"
    t.integer "player_id"
    t.integer "team_id"
    t.string "position"
    t.integer "jersey_num"
  end

  create_table "game_teams", force: :cascade do |t|
    t.integer "game_id"
    t.integer "team_id"
    t.string "home_away"
  end

  create_table "games", force: :cascade do |t|
    t.integer "api_id"
    t.datetime "datetime"
    t.string "game_type"
    t.string "season"
    t.string "status"
  end

  create_table "goals", force: :cascade do |t|
    t.integer "game_id"
    t.integer "player_id"
    t.integer "team_id"
    t.integer "api_id"
    t.string "time"
    t.string "period"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "matchup_id"
    t.string "code"
    t.string "nickname"
  end

  create_table "matchups", force: :cascade do |t|
    t.string "name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "owner_id"
    t.integer "team_id"
    t.string "status"
  end

  create_table "picks", force: :cascade do |t|
    t.integer "user_matchup_id"
    t.integer "player_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "api_id"
    t.string "name"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "api_id"
    t.string "name"
    t.string "abbreviation"
    t.string "city"
    t.string "division"
    t.string "conference"
    t.string "website"
  end

  create_table "user_matchups", force: :cascade do |t|
    t.string "nickname"
    t.integer "user_id"
    t.integer "matchup_id"
    t.integer "draft_order"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
