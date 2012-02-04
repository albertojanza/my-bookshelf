class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :asin
      t.string :permalink
      t.string :title
      t.string :author
      t.string :detail_page_url
      t.string :ean
      #t.string :edition
      t.string :isbn
      t.string :number_of_pages
      t.string :product_group
      t.string :studio
      t.string :publisher
      t.string :publication_date
      t.string :medium_image
      t.string :medium_tiny
      t.string :thumbnail_image
      t.timestamps
    end
  end
end
