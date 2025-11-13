# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

# Optional: Run this to create example category pages
# You can run with: rails runner db/seeds/category_pages.rb

puts "Creating Gallery Category Pages..."

gallery_categories = [
  {
    slug: 'paintings',
    title: 'Paintings',
    description: "Howard Hodgkin's paintings span over six decades, from intimate compositions to large-scale works. Each piece is a distillation of memory and emotion, rendered in bold, expressive layers of color.",
    page_type: :gallery_category,
    position: 1
  },
  {
    slug: 'prints',
    title: 'Prints',
    description: "Hodgkin's prints demonstrate his mastery of printmaking techniques, translating his distinctive visual language into editions that maintain the intensity and richness of his paintings.",
    page_type: :gallery_category,
    position: 2
  },
  {
    slug: 'design',
    title: 'Design',
    description: "Beyond painting and printmaking, Hodgkin applied his artistic vision to a wide range of design projects, from theatre sets to commemorative stamps, each bearing his unmistakable aesthetic signature.",
    page_type: :gallery_category,
    position: 3
  },
  {
    slug: 'indian-leaves',
    title: 'Indian Leaves',
    description: "Created in 1978, this series represents Hodgkin's deep engagement with Indian miniature painting and his experiences traveling in India.",
    page_type: :gallery_category,
    position: 4
  },
  {
    slug: 'indian-waves',
    title: 'Indian Waves',
    description: "Produced between 1990-1991, this series captures the rhythm and energy of the Indian landscape through Hodgkin's characteristically bold approach.",
    page_type: :gallery_category,
    position: 5
  },
  {
    slug: 'quantel-paintbox',
    title: 'Quantel Paintbox',
    description: "In 1986, Hodgkin experimented with digital technology, creating a series of works using the Quantel Paintbox system at Channel 4.",
    page_type: :gallery_category,
    position: 6
  },
  {
    slug: 'memories-of-bombay-mumbai',
    title: 'Memories of Bombay / Mumbai',
    description: "A series of works reflecting Hodgkin's longstanding connection to India and particularly to the city of Mumbai (formerly Bombay).",
    page_type: :gallery_category,
    position: 7
  },
  {
    slug: 'other',
    title: 'Other',
    description: "A collection of works that don't fit neatly into other categories, showcasing the breadth of Hodgkin's artistic practice.",
    page_type: :gallery_category,
    position: 8
  }
]

gallery_categories.each do |attrs|
  category_page = CategoryPage.find_or_initialize_by(slug: attrs[:slug])
  category_page.update!(attrs)
  puts "  ✓ Created/Updated: #{category_page.title}"
end

puts "\nCreating Special Collection Pages..."

special_collections = [
  {
    slug: 'missing-works',
    title: 'Missing Works',
    description: "Works whose current whereabouts are unknown. If you have information about any of these pieces, please contact us.",
    page_type: :special_collection,
    position: 1
  },
  {
    slug: 'destroyed',
    title: 'Destroyed',
    description: "Early works that were destroyed by the artist in 1961-1962.",
    page_type: :special_collection,
    position: 2
  },
  {
    slug: 'all',
    title: 'All Artworks',
    description: "Browse the complete catalogue raisonné of Howard Hodgkin's works.",
    page_type: :special_collection,
    position: 3
  }
]

special_collections.each do |attrs|
  category_page = CategoryPage.find_or_initialize_by(slug: attrs[:slug])
  category_page.update!(attrs)
  puts "  ✓ Created/Updated: #{category_page.title}"
end

puts "\nCreating Design Subcategory Pages (examples)..."

design_subcategories = [
  {
    slug: 'artplate',
    title: 'Artplate',
    description: "Ceramic plate designs for Artplate.",
    page_type: :design_subcategory,
    position: 1
  },
  {
    slug: 'glyndebourne-festival',
    title: 'Glyndebourne Festival',
    description: "Set and costume designs for Glyndebourne Festival Opera.",
    page_type: :design_subcategory,
    position: 2
  },
  {
    slug: 'olympic-games',
    title: 'Olympic Games',
    description: "Commemorative designs for the Olympic Games.",
    page_type: :design_subcategory,
    position: 3
  }
  # Add more as needed...
]

design_subcategories.each do |attrs|
  category_page = CategoryPage.find_or_initialize_by(slug: attrs[:slug])
  category_page.update!(attrs)
  puts "  ✓ Created/Updated: #{category_page.title}"
end

puts "\n✅ Category pages created successfully!"
puts "\nNext steps:"
puts "1. Visit /admin/category_pages to upload hero images"
puts "2. Edit descriptions to match your content"
puts "3. Adjust position values to reorder categories"