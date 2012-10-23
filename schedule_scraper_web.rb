require 'sinatra'
require './term_master_schedule.rb'

get '/' do
    erb :index
end

get '/output' do
    redirect to('/')
end

post '/output' do
    p = Program.new(params[:program_uri])
    @courses = p.grab_courses(params[:sections],params[:keyword])
    erb :output
end

