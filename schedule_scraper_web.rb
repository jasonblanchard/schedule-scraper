require 'sinatra'
require './term_master_schedule.rb'
require './saved_searches.rb'
require 'rack-flash'

enable :sessions
use Rack::Flash

class ScheduleScraper
    get '/' do
        
        @saved_searches = $saved_searches

        erb :index
    end

    post '/' do
        
        $saved_searches.delete(params[:delete_saved_search])
        flash.now[:notice] = "#{params[:delete_saved_search]} was deleted"

        @saved_searches = $saved_searches

        file = File.new("./saved_searches.rb", "w")
        file.syswrite("$saved_searches = #{$saved_searches}")
        
        erb :index
    end

    get '/output' do
        redirect to('/')
    end

    post '/output' do
        @courses = []
        @total = 0
        @programs = []
        @urls = []

        if params[:use_saved_values]
            programs = $saved_searches[params[:name]]
        else
            programs = params["programs"]
        end

        if programs.respond_to?(:each)

            programs.each do |k, program|
                p = Program.new(program["program_uri"]) unless program["program_uri"].empty?
                if p 
                    @courses << p.grab_courses(program["sections"],program["keyword"])
                    @programs << program[:program_name]
                    @urls << program[:program_uri]
                end
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

    get '/admin' do
        erb :admin
    end

    post '/admin' do

        Dir.foreach('public/files') do |file|
            next if file == '.' or file == '..' or file == '.gitignore'
                File.delete("public/files/#{file}")
            end

            flash.now[:notice] = "All excel sheets destroyed"

        erb :admin
    end
end
