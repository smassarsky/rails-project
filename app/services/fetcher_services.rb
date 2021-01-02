module FetcherServices

  class TeamsFetcher

    BASE_URL = 'https://statsapi.web.nhl.com/api/v1/'

    def self.fetch_teams
      uri = URI.parse("#{BASE_URL}/teams")
      response = Net::HTTP.get_response(uri)
      teams_hash = JSON.parse(response.body)
      teams_hash["teams"].each do |team|
        build_team(team)
      end
    end

    def self.build_team(team)
      if !Team.find_by(name: team["teamName"])
        Team.create(
          api_id: team["id"],
          name: team["teamName"],
          abbreviation: team["abbreviation"],
          city: team["locationName"],
          division: team["division"]["name"],
          conference: team["conference"]["name"],
          website: team["officialSiteUrl"]
        )
      end
    end

  end

  class SeasonGamesFetcher

    BASE_URL = 'https://statsapi.web.nhl.com/api/v1/'

    def self.fetch_season_games(season)
      # uri = URI.parse("#{BASE_URL}/schedule?season=#{season}")
      # response = Net::HTTP.get_response(uri)
      # season_hash = JSON.parse(response.body)

      # season_hash["dates"].each do |date|
      #   date["games"].each do |game|
      #     build_game(game)
      #   end
      # end

      Game.all.each do |game|
        build_game_events_and_players(game)
      end

    end

    def self.build_game(game)
      if !Game.find_by(api_id: game["gamePk"])
        Game.create(
          api_id: game["gamePk"],
          datetime: DateTime.parse(game["gameDate"]),
          game_type: game["gameType"],
          season: game["season"],
          status: game["status"]["abstractGameState"],
          home_team: Team.find_by(api_id: game["teams"]["home"]["team"]["id"]),
          away_team: Team.find_by(api_id: game["teams"]["away"]["team"]["id"])
        )
      end
    end

    def self.build_game_events_and_players(game)
      uri = URI.parse("#{BASE_URL}/game/#{game.api_id}/feed/live")
      response = Net::HTTP.get_response(uri)
      game_hash = JSON.parse(response.body)

      #build_teams(game, game_hash["liveData"]["boxscore"]["teams"])
      #build_events(game, game_hash["liveData"]["plays"])

      # fix for adding video ids

      #add_video_ids(game, game_hash["liveData"]["plays"])
    end

    # full play details: game_hash["liveData"]["plays"]["allPlays"]
    # array of scoring play event IDs: game_hash["liveData"]["plays"]["scoringPlays"]

    # team rosters: game_hash["liveData"]["boxscore"]["teams"][:home_away]

    def self.build_teams(game, teams_hash)
      teams_hash["home"]["players"].each do |key, player|
        build_player(game, game.home_team, player)
      end
      teams_hash["away"]["players"].each do |key, player|
        build_player(game, game.away_team, player)
      end
    end

    def self.build_player(game, team, player_hash)
      if !player_hash["stats"].empty?
        player = Player.find_by(api_id: player_hash["person"]["id"])
        if player
          build_game_player(game, team, player, player_hash)
        else
          player = Player.new(api_id: player_hash["person"]["id"], name: player_hash["person"]["fullName"])
          if player.save
            build_game_player(game, team, player, player_hash)
          end
        end
      end
    end

    def self.build_game_player(game, team, player, player_hash)
      if !GamePlayer.find_by(game: game, player: player)
        GamePlayer.create(
          game: game,
          player: player,
          team: team,
          position: player_hash["position"]["abbreviation"],
          jersey_num: player_hash["jerseyNumber"].to_i
        )
      end
    end

    def self.build_events(game, plays_hash)
      plays_hash["scoringPlays"].each do |goal_id|
        build_goal(game, plays_hash["allPlays"][goal_id])
      end

    end

    # full play details: plays_hash["allPlays"]
    # array of scoring play event IDs: plays_hash["scoringPlays"]

    def self.build_goal(game, goal_hash)
      if !Goal.find_by(game: game, api_id: goal_hash["about"]["eventIdx"])
        goal = Goal.create(
          game: game,
          player: Player.find_by(api_id: goal_hash["players"][0]["player"]["id"]),
          team: Team.find_by(api_id: goal_hash["team"]["id"]),
          api_id: goal_hash["about"]["eventIdx"],
          time: goal_hash["about"]["periodTime"],
          period: goal_hash["about"]["ordinalNum"]
        )

        goal_hash["players"].each do |player|
          build_assist(goal, player["player"]["id"]) if player["playerType"] == "Assist"
        end
      end
    end

    def self.build_assist(goal, player_api_id)
      if !goal.assists.map{|assist| assist.player.api_id}.include?(player_api_id)
        assist = Assist.create(goal: goal, player: Player.find_by(api_id: player_api_id))
      end
    end

    def self.add_video_ids(game, plays_hash)
      event_codes = game.goals.select(:api_id).map{|goal| goal[:api_id]}
      event_codes.each do |event_code|
        goal = game.goals.find_by(api_id: event_code)
        goal.update(video_id: plays_hash["allPlays"][event_code]["about"]["eventId"])
      end
    end

    def self.fetch_videos
      Game.all.each do |game|
        uri = URI.parse("#{BASE_URL}/game/#{game.api_id}/content")
        response = Net::HTTP.get_response(uri)
        game_content_hash = JSON.parse(response.body)

        event_codes = game.goals.select(:video_id).map{|goal| goal[:video_id]}

        if game_content_hash["media"]["milestones"]["items"]
          goals_hash = game_content_hash["media"]["milestones"]["items"].select{|item| item["type"] == "GOAL"}
          if !goals_hash.empty?
            goals_hash.each do |possible_goal|
              if event_codes.include?(possible_goal["statsEventId"].to_i)
                if possible_goal["highlight"]["playbacks"]
                  if possible_goal["highlight"]["playbacks"].last["name"] == "FLASH_1800K_960X540"
                    goal = game.goals.find_by(video_id: possible_goal["statsEventId"].to_i)
                    goal.update(video_url: possible_goal["highlight"]["playbacks"].last["url"])
                  end
                end
              end
            end
          end
        end

        
      end
    end

  end
  
end

# #{BASE_URL}/game/#{game.api_id}/content (for videos)
# game_content_hash["media"]["milestones"]["items"].select{|item| item["type"] == "GOAL"} (select goals)
# problem: event ids dont match video event ids
# 18 : 15
# 64 : 40
# 86 : 254
# 175 : 457
# 215 : 486
# 218 : 488
# 269 : 661