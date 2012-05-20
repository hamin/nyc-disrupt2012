require 'sinatra'

configure do
  set :views, ['views/layouts', 'views/pages', 'views/partials']
  #enable :sessions
end

Dir["./app/models/*.rb"].each { |file| require file }
Dir["./app/helpers/*.rb"].each { |file| require file }
Dir["./app/controllers/*.rb"].each { |file| require file }

klout_client = Klout::API.new # ENV['KLOUT_API_KEY']

before "/*" do 
  if mobile_request?
    set :erb, :layout => :mobile
  else
    set :erb, :layout => :layout
  end
end

post '/klout' do
  klout_id = klout_client.identity( params[:username] )["id"]
  klout_user = klout_client.user(klout_id)
  @user_klout_score = klout_user["score"]["score"]
  @topics = klout_client.user(klout_user,:topics)
  @klout_influence = klout_client.user(klout_user,:influence)
  @influencers = @klout_influence["myInfluencers"]
  @influencees = @klout_influence["myInfluencees"]
  @influencers_count = @klout_influence["myInfluencersCount"]
  @influencees_count = @klout_influence["myInfluenceesCount"]
  
  
  erb :klout
end