module DatarepoHelper
  def link_to_user_or_facet(user_string, field_string)
    user = User.find_by_email(user_string)
    unless user.nil?
      label = !user.display_name.nil? ? user.display_name : user.email
      link_to(label, sufia.profile_path(user))
    else
      link_to_facet(user_string, field_string)
    end
  end

  def link_to_user_or_field(user_string, fieldname)
    user = User.find_by_email(user_string)
    unless user.nil?
      label = !user.display_name.nil? ? user.display_name : user.email
      link_to(label, sufia.profile_path(user))
    else
      link_to_field(fieldname, user_string)
    end
  end
end
