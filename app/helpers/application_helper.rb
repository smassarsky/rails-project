module ApplicationHelper

  def current_user
    @user ||= User.find(session[:user_id])
  end

  def is_logged_in?
    !!session[:user_id]
  end

  def date_format(date)
    date.strftime("%B %e, %Y")
  end

  def owner?(thing)
    thing.owner == current_user
  end

  def errors?(thing, field="all")
    if field == "all"
      !thing.errors.empty?
    else
      !thing.errors[field].empty?
    end
  end

  def errors(thing, field="all")
    if field == "all"
      thing.errors.full_messages.join(". ")
    else
      if errors?(thing, field)
        html = <<~HTML
          <div class="text-danger">#{thing.errors[field].uniq.join(". ")}</div>
        HTML
        html.html_safe
      else
        nil
      end
    end
  end

end
