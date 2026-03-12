class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :category, null: false, default: "other"
      t.boolean :published, default: false
      t.datetime :published_at
      t.string :author, default: "Today.bike"
      t.text :meta_description
      t.string :source_url

      t.timestamps
    end

    add_index :blog_posts, :slug, unique: true
    add_index :blog_posts, :category
    add_index :blog_posts, :published
    add_index :blog_posts, :published_at
    add_index :blog_posts, :source_url, unique: true
  end
end
