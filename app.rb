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

    get '/fruits' do 
      @fruits = db.execute("SELECT * FROM products ORDER BY name ASC")
      ap @fruits
      erb :"fruits/index"
    end

    get '/fruits/new' do 
      erb :"fruits/new"
    end

    post '/fruits' do
      name = params["name"]
      tasti = params["tasti"]
      desc = params["desc"]
      db.execute("INSERT INTO products (name, tastiness, description) VALUES (?, ?, ?)",[name, (tasti.to_i > 10) ? 10 : (tasti.to_i < 1) ? 1 : tasti, desc])
      redirect("/fruits")
    end

    get '/fruits/:id' do |id|
      @fruit = db.execute('SELECT * FROM products WHERE id=? ORDER BY name ASC',id).first
      ap @fruit
      erb :"fruits/show"
    end
    
    post '/fruits/:id/delete' do |id|
      db.execute("DELETE FROM products WHERE id =?", id)
      redirect("/fruits")
    end
end
