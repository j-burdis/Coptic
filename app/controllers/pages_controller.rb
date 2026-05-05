class PagesController < ApplicationController
  def home
    @carousel_slides = CarouselSlide.published.ordered.includes(:artwork)
    @home_sections = HomeSection.published.ordered
  end

  def contact
    @contacts_by_category = Contact.published
                                   .ordered
                                   .group_by(&:category)
  end

  def copyright_permissions
    @page = Page.find_by(slug: 'copyright-permissions')
  end

  def privacy
    @page = Page.find_by(slug: 'privacy')
  end
end
