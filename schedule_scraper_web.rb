require 'sinatra'
require './term_master_schedule.rb'
require './saved_searches.rb'

enable :sessions

get '/' do
    
    @saved_searches = $saved_searches

    erb :index
end

get '/output' do
    redirect to('/')
end

post '/output' do
    @courses = []
    @total = 0

    if params[:use_saved_values]
        programs = $saved_searches[params[:name]]
    else
        programs = params["programs"]
    end

    programs.each do |k, program|
        p = Program.new(program["program_uri"]) unless program["program_uri"].empty?
        if p 
            @courses << p.grab_courses(program["sections"],program["keyword"])
        end
    end
    programs.each do |k,program|
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
   
    
    if params["save"]
        $saved_searches[params[:save_name]] = params[:programs]
        file = File.new("./saved_searches.rb", "w")
        file.syswrite("$saved_searches = #{$saved_searches}")
    end

    erb :output
    
end

post '/download' do
end

get '/download' do
    redirect to('/')
end
