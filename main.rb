require 'sinatra'

configure do
  set :views, ['views/layouts', 'views/pages', 'views/partials']
  #enable :sessions
end

Dir["./app/models/*.rb"].each { |file| require file }
Dir["./app/helpers/*.rb"].each { |file| require file }
Dir["./app/controllers/*.rb"].each { |file| require file }

before "/*" do 
  if mobile_request?
    set :erb, :layout => :mobile
  else
    set :erb, :layout => :layout
  end
end

post '/klout' do
  klout_id = KloutClient.identity( params[:username] )["id"]
  klout_user = KloutClient.user(klout_id)
  @user_klout_score = klout_user["score"]["score"]
  @topics = KloutClient.user(klout_user["kloutId"],:topics)
  @klout_influence = KloutClient.user(klout_user["kloutId"],:influence)
  
  # Sorty Influencers and Influence by score
  @influencers = @klout_influence["myInfluencers"].map{|k| k["entity"] }.sort{|x, y| x["payload"]["score"]["score"] <=> y["payload"]["score"]["score"]}
  @influencees = @klout_influence["myInfluencees"].map{|k| k["entity"] }.sort{|x, y| x["payload"]["score"]["score"] <=> y["payload"]["score"]["score"]}
  @influencers_count = @klout_influence["myInfluencersCount"]
  @influencees_count = @klout_influence["myInfluenceesCount"]
  
  @influencers.each do |influencer|
    tw_id = KloutClient.ks_identity(influencer["id"])["id"]
    influencer["twitterUrl"] = Twitter.user(tw_id.to_i).profile_image_url
  end
  
  @influencees.each do |influencee|
    tw_id = KloutClient.ks_identity(influencee["id"])["id"]
    influencee["twitterUrl"] = Twitter.user(tw_id.to_i).profile_image_url
  end
  
  
  erb :klout
end