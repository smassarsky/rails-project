module DraftHelper

  def my_pick?(matchup)
    matchup.whose_pick?.user == current_user
  end

  def next_pick_header(matchup)
    if my_pick?(matchup)
      "It's your pick!  Please choose a player.".html_safe
    else
      "It's #{matchup.whose_pick?.display_name}'s pick!".html_safe
    end
  end

end