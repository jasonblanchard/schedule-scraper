require 'sinatra'
require './term_master_schedule.rb'
require 'sinatra/partial'

enable :sessions

get '/' do
    erb :index
end

get '/output' do
    redirect to('/')
end

post '/output' do
    @courses = []
    @total = 0

    params.each do |k,program|
        p = Program.new(program["program_uri"]) unless program["program_uri"].empty?
        if p 
            @courses << p.grab_courses(program["sections"],program["keyword"])
        end
    end
    
    @courses.each do |courses|
        courses.each do |program|
            @total += 1
        end
    end

    session[:courses] = @courses

    #Spreadsheet.create_sheet(@courses)
    erb :output
end

post '/download' do
end

get '/download' do
    redirect to('/')
end
