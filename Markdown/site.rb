require 'sinatra'
require 'haml'
require 'rest_client'
require 'json'
require 'kramdown'

DB_SPEAKER = nil

configure do
	DB_SPEAKER = "http://localhost:5984/speakers"
end

configure :production do
  DB_SPEAKER = "#{ENV['CLOUDANT_URL']}/speakers"
end


set :haml, :format => :html5

get '/' do
	haml :index
end

get '/article/form' do
	haml :articleForm
end
post '/article/form' do
	doc_url = "#{DB_SPEAKER}/#{CGI.escape(params[:name])}"
	new_doc = {
		'name' => params[:name],
		'email' => params[:mail],
        'outline' => params[:blurb]
        }
	RestClient.put doc_url, new_doc.to_json, :content_type => 'application/json'
    
	haml :articlePosted
end

get '/article/view' do

    docs = RestClient.get "#{DB_SPEAKER}/_all_docs"

    r = JSON.parse(docs)
    
    @result = r["rows"]
    
	haml :articleView
end

get '/article/view/:name' do

    docs = RestClient.get "#{DB_SPEAKER}/#{CGI.escape(params[:name])}"

    r = JSON.parse(docs)
    
    @result = r
    @blurb = Kramdown::Document.new(r["outline"]).to_html
    
	haml :articleSingle
end

not_found do
	'Oh snap! That page doesn\'t exist!'
end