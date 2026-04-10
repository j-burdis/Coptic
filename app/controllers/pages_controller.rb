class PagesController < ApplicationController
  def home
  end

  def contact
    @contacts_by_category = Contact.published
                                   .ordered
                                   .group_by(&:category)
  end

  def copyright_permissions
  end

  def privacy
  end
end
