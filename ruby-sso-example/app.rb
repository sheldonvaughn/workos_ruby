# frozen_string_literal: true

require 'sinatra'
require 'workos'
require 'json'

# Get your project_id and configure your domain and
# redirect_uris at https://dashboard.workos.com/sso/configuration
DOMAIN = 'example.com'
PROJECT_ID = 'project_01DGR79TEPRE7Q0FQTZKY7VPD1'
REDIRECT_URI = 'http://localhost:4567/callback'
WorkOS.key = 'sk_live_pZyOPP2DEO8eq4oQAq68Gqca8'
use(
  Rack::Session::Cookie, 
  key: 'rack.session',
  domain: 'localhost',
  path: '/',
  expire_after: 2_592_000,
  secret: SecureRandom.hex(16)
)

get '/' do
  @current_user = session[:user] && JSON.pretty_generate(session[:user])

  erb :index, :layout => :layout
end

get '/auth' do
  authorization_url = WorkOS::SSO.authorization_url(
    domain: DOMAIN,
    project_id: PROJECT_ID,
    redirect_uri: REDIRECT_URI,
  )

  redirect authorization_url
end

get '/callback' do
  profile = WorkOS::SSO.profile(
    code: params['code'],
    project_id: PROJECT_ID,
  )

  session[:user] = profile.to_json

  redirect '/'
end

get '/logout' do
  session[:user] = nil

  redirect '/'
end
