require 'sinatra'
require 'haml'
require 'rest_client'
require 'json'
require 'cgi'

DB_ARTICLES = nil

configure do
	DB_ARTICLES = "http://localhost:5984/articles"
end

configure :production do
  DB_ARTICLES = "#{ENV['CLOUDANT_URL']}/articles"
end

set :haml, :format => :html5

get '/' do
	haml :index
end

get '/article/form' do
	haml :articleForm
end
post '/article/form' do
	doc_url = "#{DB_ARTICLES}/#{CGI.escape(params[:name])}"
	new_doc = {
		'name' => params[:name],
		'email' => params[:mail],
        'blurb' => params[:blurb]
	}
	RestClient.put doc_url, new_doc.to_json, :content_type => 'application/json'
	haml :articlePosted
end

get '/article/view/:name' do

    doc = RestClient.get "#{DB_ARTICLES}/#{params[:name]}"
    @result = JSON.parse(doc)
    
	haml :articleView
end

not_found do
	'Oh snap! That page doesn\'t exist!'
end