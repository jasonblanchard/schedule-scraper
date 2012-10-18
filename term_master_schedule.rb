require 'net/https'
require 'nokogiri'
require 'open-uri'
require 'simple_xlsx'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Program

    attr_accessor :url, :course_data

    def initialize(url)
        @url = url
    end

    def get_subject_code(c)
        c.css('td')[0].content
    end

    def get_course_number(c)
        c.css('td')[1].content
    end

    def get_course_section(c)
        c.css('td')[3].content
    end

    def get_course_crn(c)
        c.css('td')[4].css('a')[0].content
    end

    def get_course_title(c)
        c.css('td')[5].content
    end

    def get_course_instructor(c)
        c.css('td').reverse[0].content
    end

    def get_course_type(c)
        c.css('td')[2].content
    end

    def create_course_name(c)
        "#{get_subject_code(c)}-#{get_course_number(c)}-#{get_course_section(c)}"
    end

    def get_program(page)
        page.css('table').css('tr')[3].css('td')[6].content.split.reverse[0]
    end

    def is_course?(html, page)
        (html.css('td').length > 2) && (html.css('td')[0].content.match(/#{get_program(page)}/))
    end
    
    def grab_courses(section=nil, keyword=nil)
        page  = Nokogiri::HTML open( @url )

        course_list = page.css('table').css('tr')[3].css('td').css('tr')[6].css('tr')

        program = get_program(page)

        @course_data = Array.new

        raw_courses = Array.new

        course_list.css('tr').each do |course|
            raw_courses << course if is_course?(course, page)
        end

        raw_courses.each do |course|
            @course_data << [create_course_name(course),
                             get_subject_code(course), 
                             get_course_number(course), 
                             get_course_section(course),
                             get_course_type(course), 
                             get_course_crn(course),
                             get_course_instructor(course),
                             get_course_title(course)]
        end

        @course_data
    end

    def create_sheet
        SimpleXlsx::Serializer.new("test.xlsx") do |doc|
            doc.add_sheet("course") do |sheet|
                @course_data.each do |course|
                    sheet.add_row(course)
                end
            end
        end
    end

end

all = []

p = Program.new("https://duapp2.drexel.edu/webtms_du/app?component=subjectDetails&page=CollegesSubjects&service=direct&sp=ZH4sIAAAAAAAAAFvzloG1uIhBPjWlVC%2BlKLUiNUcvs6hErzw1qSS3WC8lsSRRLyS1KJcBAhiZGJh9GNgTk0tCMnNTSxhEfLISyxL1iwtz9EECxSWJuQXWPgwcJUAtzvkpQBVCEBU5iXnp%2BsElRZl56TB5l9Ti5EKGOgamioKCEgY2IwNDIyNToJHhmXlAaYXA0sQiEG1opGtoDACLMly%2FpgAAAA%3D%3D&sp=SG&sp=SCULA&sp=12")

puts p.grab_courses.inspect
