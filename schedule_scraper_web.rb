require 'sinatra'
require './term_master_schedule.rb'

get '/' do
    erb :index
end

get '/output' do
    redirect to('/')
end

post '/output' do
    @courses = []

    params.each do |k,program|
        p = Program.new(program["program_uri"]) unless program["program_uri"].empty?
        if p 
            @courses << p.grab_courses
        end
    end
    @courses
    #Spreadsheet.create_sheet(@courses)
    erb :output
end

