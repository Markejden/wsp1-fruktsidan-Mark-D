require 'debug'
require "awesome_print"

class App < Sinatra::Base
    register Sinatra::Reloader

    def db
      return @db if @db

      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    get '/categories' do
      @categories = db.execute('SELECT * FROM categories')
      ap @categories
      erb(:"categories/index")
    end

    get '/categories/new' do 
      erb :"categories/new"
    end

    post '/categories' do
      name, desc = params["name"], params["desc"]
      db.execute("INSERT INTO categories (name, description) VALUES (?, ?)",[name, desc])
      redirect("/categories")
    end

    get '/categories/:id' do | id |
      @fruits = db.execute('SELECT * FROM products WHERE category_id=?', id)
      @categories = db.execute('SELECT * FROM categories WHERE id=?', id).first
      erb(:"categories/show")
    end

    get '/categories/:id/edit' do | id |
      @category = db.execute('SELECT * FROM categories WHERE id=? ORDER BY name ASC',id).first
      erb :"categories/edit"
    end

    post "/categories/:id/update" do | id |
    name, desc = params["name"], params["desc"]
    db.execute("UPDATE categories SET name =?, description=? WHERE id =?", [name, desc, id])
    redirect("/categories")
    end

    post '/categories/:id/delete' do |id|
      db.execute("DELETE FROM categories WHERE id =?", id)
      redirect("/categories")
    end

    get '/fruits' do 
      @fruits = db.execute("SELECT * FROM products ORDER BY name ASC")
      ap @fruits
      erb :"fruits/index"
    end

    get '/fruits/new' do 
      erb :"fruits/new"
    end

    post '/fruits' do
      name, tasti, desc = params["name"], params["tasti"], params["desc"]
      db.execute("INSERT INTO products (name, tastiness, description) VALUES (?, ?, ?)",[name, (tasti.to_i > 10) ? 10 : (tasti.to_i < 1) ? 1 : tasti, desc])
      redirect("/fruits")
    end

    get '/fruits/:id' do | id |
      @fruit = db.execute('SELECT * FROM products WHERE id=?', id).first
      @category = db.execute('SELECT * FROM categories WHERE id=?', @fruit['category_id']).first
      @categories = db.execute('SELECT * FROM categories')
      erb(:"fruits/show")
    end


    get '/fruits/:id/edit' do | id |
      @fruit = db.execute('SELECT * FROM products WHERE id=? ORDER BY name ASC',id).first
      erb :"fruits/edit"
    end

    post "/fruits/:id/update" do | id |
    name, tasti, desc = params["fruit_name"], params["fruit_tastiness"], params["fruit_description"]
    db.execute("UPDATE products SET name =?, tastiness=?, description=? WHERE id =?", [name, (tasti.to_i > 10) ? 10 : (tasti.to_i < 1) ? 1 : tasti, desc, id])
    redirect("/fruits")
    end

    post '/fruits/:id/delete' do |id|
      db.execute("DELETE FROM products WHERE id =?", id)
      redirect("/fruits")
    end
    
    post '/fruits/:id/category' do
      fruit_id = params["id"]
      c_id = params["category_id"]
      db.execute("UPDATE products SET category_id = ? WHERE id = ?",[c_id, fruit_id])
      redirect ("/fruits/#{fruit_id}")
    end
end
