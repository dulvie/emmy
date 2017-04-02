class OrganizationDecorator < Draper::Decorator
  delegate_all

  def logo_url
    (object.logo?) ? object.logo.upload.url : ""
  end

  def logo_path
    (object.logo?) ? object.logo.upload.path : ""
  end
end

