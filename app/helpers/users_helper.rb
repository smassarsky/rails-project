module UsersHelper

  def user_errors?(field="all")
    if field == "all"
      !@user.errors.empty?
    else
      !@user.errors[field].empty?
    end
  end

  def user_errors(field="all")
    if field == "all"
      @user.errors.full_messages.join(". ")
    else
      if user_errors?(field)
        html = <<~HTML
          <div class="text-danger">#{@user.errors[field].uniq.join(". ")}</div>
        HTML
        html.html_safe
      else
        nil
      end
    end
  end

end
