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
      Team.find_or_create_by(api_id: team["id"]) do |t|
        t.name = team["teamName"]
        t.abbreviation = team["abbreviation"]
        t.city = team["locationName"]
        t.division = team["division"]["name"]
        t.conference = team["conference"]["name"]
        t.website = team["officialSiteUrl"]
      end
    end

  end

  class GamesFetcher

    BASE_URL = 'https://statsapi.web.nhl.com/api/v1/'

    # Format (1 = Y1, 2 = Y2) : 11112222
    def self.fetch_games_by_season(season)
      uri = URI.parse("#{BASE_URL}/schedule?season=#{season}")
      response = Net::HTTP.get_response(uri)
      season_hash = JSON.parse(response.body)

      season_hash["dates"].each do |date|
        date["games"].each do |game|
          build_game(game)
        end
      end
    end

    # format YYYY-MM-DD
    def self.fetch_games_by_date_range(start_date, end_date)
      uri = URI.parse("#{BASE_URL}/schedule?startDate=#{start_date}&endDate=#{end_date}")
      response = Net::HTTP.get_response(uri)
      games_hash = JSON.parse(response.body)
      games_hash["dates"].each do |date|
        date["games"].each do |game|
          build_game(game)
        end
      end
    end

    def self.build_game(game)
      if Team.exists?(api_id: game["teams"]["home"]["team"]["id"]) && Team.exists?(api_id: game["teams"]["away"]["team"]["id"])
        new_game = Game.find_or_create_by(api_id: game["gamePk"]) do |g|
          g.datetime = DateTime.parse(game["gameDate"])
          g.game_type = game["gameType"]
          g.season = game["season"]
          g.status = game["status"]["abstractGameState"]
          g.home_team = Team.find_by(api_id: game["teams"]["home"]["team"]["id"])
          g.away_team = Team.find_by(api_id: game["teams"]["away"]["team"]["id"])
        end
        build_game_rosters_and_events(new_game)
      end
    end

    def self.build_game_rosters_and_events(game)
      uri = URI.parse("#{BASE_URL}/game/#{game.api_id}/feed/live")
      response = Net::HTTP.get_response(uri)
      game_hash = JSON.parse(response.body)

      build_roster(game, game.home_team, game_hash["liveData"]["boxscore"]["teams"]["home"])
      build_roster(game, game.away_team, game_hash["liveData"]["boxscore"]["teams"]["away"])

      build_events(game, game_hash["liveData"]["plays"])

      add_game_videos(game)
    end

    def self.build_roster(game, team, team_hash)
      team_hash["players"].each do |key, player|
        build_player(game, team, player)
      end
    end

    def self.build_player(game, team, player_hash)
      if !player_hash["stats"].empty?
        player = Player.find_or_create_by(api_id: player_hash["person"]["id"]) do |pl|
          pl.name = player_hash["person"]["fullName"]
        end
        build_game_player(game, team, player, player_hash)
      end
    end

    def self.build_game_player(game, team, player, player_hash)
      GamePlayer.find_or_create_by(game: game, player: player) do |gp|
        gp.team = team
        gp.position = player_hash["position"]["abbreviation"]
        gp.jersey_num = player_hash["jerseyNumber"].to_i
      end
    end

    def self.build_events(game, plays_hash)
      plays_hash["scoringPlays"].each do |goal_id|
        build_goal(game, plays_hash["allPlays"][goal_id])
      end
    end

    def self.build_goal(game, goal_hash)
      goal = Goal.find_or_create_by(game: game, api_id: goal_hash["about"]["eventIdx"]) do |g|
        g.player = Player.find_by(api_id: goal_hash["players"][0]["player"]["id"])
        g.team = team = Team.find_by(api_id: goal_hash["team"]["id"])
        g.api_id = goal_hash["about"]["eventIdx"]
        g.time = goal_hash["about"]["periodTime"]
        g.period = goal_hash["about"]["ordinalNum"]
        g.video_id = goal_hash["about"]["eventId"]
      end

      # add assists
      goal_hash["players"].each do |player|
        build_assist(goal, player["player"]["id"]) if player["playerType"] == "Assist"
      end 
    end

    def self.build_assist(goal, player_api_id)
      Assist.find_or_create_by(goal: goal, player: Player.find_by(api_id: player_api_id))
    end

    # pulls game content page from API
    def self.add_game_videos(game)
      uri = URI.parse("#{BASE_URL}/game/#{game.api_id}/content")
      response = Net::HTTP.get_response(uri)
      game_content_hash = JSON.parse(response.body)

      # event codes match up with event IDs in game_content_hash
      event_codes = game.goals.pluck(:video_id)

      #separate possible goals
      if game_content_hash["media"]["milestones"]["items"]
        goals_hash = game_content_hash["media"]["milestones"]["items"].select{|item| item["type"] == "GOAL"}
        if !goals_hash.empty?
          goals_hash.each do |possible_goal|

            # see if match in event codes
            if event_codes.include?(possible_goal["statsEventId"].to_i)
              if possible_goal["highlight"]["playbacks"]

                # see if there's video and update goal with url in db
                video = possible_goal["highlight"]["playbacks"].find{|playback| playback["name"].start_with?("FLASH_1800K")}
                if !!video
                  goal = game.goals.find_by(video_id: possible_goal["statsEventId"].to_i)
                  goal.update(video_url: video["url"])
                end
              end
            end
          end
        end
      end
    end

  end
  
end