require 'sinatra'
require './term_master_schedule.rb'

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

    @timestamp = Time.new.to_i

    Spreadsheet.create_sheet(@courses, @timestamp) unless @courses.empty?
    erb :output
end

post '/download' do
end

get '/download' do
    redirect to('/')
end
