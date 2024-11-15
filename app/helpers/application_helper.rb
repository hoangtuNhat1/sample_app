module ApplicationHelper
  include Pagy::Frontend
  def full_title page_title
    base_title = t :page_title
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def home_link
    Settings.href.home_href
  end
end
