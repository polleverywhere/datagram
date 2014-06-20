require 'coffee-script'
require 'sinatra'
require 'sequel'
require 'haml'
require 'json'

SQL_DEFAULT = <<-eos
/*
Enter your SQL query below.
You can run, save, or delete queries using the buttons above
*/

SELECT *
FROM users
LIMIT 100
eos

FILTER_DEFAULT = <<-eos
// Enter your JavaScript filter below.
// Filters modify the returned SQL dataset
// Query results are available for manipulation
// via the global variable `results`. Your filtered
// results will be used to build the report.
// results.map(function(row){
//   var mailto = "mailto:" + row.email + "?Subject=Checking%20in"
//
//   return {
//     full_name: row.first_name + " " + row.last_name,
//     email: "<a href='" + mailto + "' target='_top'>" + row.email + "</a>"
//   }
// });
eos

module Datagram
  class App < Sinatra::Base
    set :public_dir, File.expand_path('../public', __FILE__)

    enable :logging

    include Datagram::Model

    get '/' do
      haml :index
    end

    get "/schema" do
      load_schema.to_json
    end

    post "/queries" do
      create_default_query
    end

    get "/folders" do
      load_folders.to_json
    end

    post "/folders" do
      create_folder(params)
    end

    get '/queries/:id/run' do |id|
      query = Query[id]

      execute(query)
    end

    get '/queries/:id' do |id|
      haml :index
    end

    put '/queries/:id' do |id|
      query = Query[id]
      attrs = {
        :name => params[:name] || "Query #{id}"
      }

      if params.has_key?("content")
        attrs[:content] = params[:content]
      end

      if params.has_key?("filter")
        attrs[:filter] = params[:filter]
      end

      if params.has_key?("locked_at")
        attrs[:locked_at] = params[:locked_at]
      end

      if params.has_key?("description")
        attrs[:description] = params[:description]
      end

      if params.has_key?("folder_id")
        attrs[:folder_id] = params[:folder_id]
      end

      update(query, attrs)
    end

    delete "/queries/:id" do |id|
      Query[id].destroy
      status 204
    end

    delete "/folders/:id" do |id|
      Query.where(:folder_id => id).update(:folder_id => nil)

      Folder[id].destroy
      status 204
    end

    get '/queries/:id/download' do |id|
      @query = Query[id]
      queryName = @query.name || "Query #{id}"

      headers "Content-Disposition" => "attachment;filename=#{queryName}.csv"

      @ds = db.fetch(@query.content)
      @ds.to_csv
    end

    # assets
    get '/style.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass :style
    end

    get "/editor.js" do
      coffee :editor
    end

    get "/results.js" do
      coffee :results
    end

    get "/query.js" do
      coffee :query
    end

    get "/folder.js" do
      coffee :folder
    end

    get "/application.js" do
      coffee :application
    end

  private
    def create_folder(params={})
      folder = Folder.create({
        :name => params[:name]
      })

      status 200
      body(folder.to_json)
    rescue Sequel::Error => e
      status 500
      body({:message => e.message}.to_json)
    end

    def create_default_query
      query = Query.create({
        :name => "New Query",
        :content => SQL_DEFAULT,
        :filter => FILTER_DEFAULT
      })

      status 200
      body(query.to_json)
    rescue Sequel::Error => e
      status 500
      body({:message => e.message}.to_json)
    end

    def update(query, attrs)
      query.update_all(attrs)

      status 200
      body(query.to_json)
    rescue Sequel::Error => e
      status 500
      body({:message => e.message}.to_json)
    end

    def execute(query)
      @ds = db.dataset.with_sql(query.content)

      # gross way to make sure we get float formatted results
      # rather than scientific notation
      results = format(@ds)

      status 200
      body({:columns => @ds.columns, :items => results}.to_json)
    rescue Sequel::Error => e
      status 500
      body({:message => e.message}.to_json)
    end

    def load_folders
      folders = [
        {
          :id => -1,
          :name => "Ungrouped",
          :queries => Query.where(:folder_id => nil)
        }
      ]

      Folder.each do |f|
        attrs = {
          :id => f.id,
          :name => f.name,
          :queries => Query.where(:folder_id => f.id)
        }

        folders << attrs
      end

      folders
    end

    def load_schema
      db.tables.inject({}) do |schema, table|
        schema[table] = db.schema(table).map(&:first)
        schema
      end
    end

    def format(results)
      results.to_a.map do |row|
        hash = {}

        row.each_pair do |col_name, value|
          if value.class == BigDecimal
            hash[col_name] = value.to_f
          else
            hash[col_name] = value
          end
        end

        hash
      end
    end

    def db
      self.class.reporting_db
    end

    def self.reporting_db
      @reporting_db ||= Sequel.connect(ENV['REPORTING_DATABASE_URL']).tap do |db|
        db.logger = Datagram.logger
      end
    end
  end
end
