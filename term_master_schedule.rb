require 'net/https'
require 'nokogiri'
require 'open-uri'

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

    def get_course_sec(c)
        c.css('td')[3].content
    end

    def get_course_crn(c)
        c.css('td')[4].css('a')[0].content
    end

    def get_course_instructor(c)
        c.css('td')[7].content
    end

    def get_course_type(c)
        c.css('td')[2].content
    end

    def get_program(page)
        page.css('table').css('tr')[3].css('td')[6].content.split.reverse[0]
    end
    
    def grab_courses
        page  = Nokogiri::HTML open( @url )

        course_list = page.css('table').css('tr')[3].css('td').css('tr')[6].css('tr')

        program = get_program(page)

        @course_data = Hash.new

        courses = Array.new

        course_list.css('tr').each do |course|
            courses << course if (course.css('td').length > 2) && (course.css('td')[0].content.match(/#{program}/))
        end

        courses.each do |course|
            course_name = "#{get_subject_code(course)}-#{get_course_number(course)}-#{get_course_sec(course)}"
            @course_data[course_name] = {}
            @course_data[course_name]["Subject Code"] = get_subject_code(course)
            @course_data[course_name]["Course Number"] = get_course_number(course)
            @course_data[course_name]["Instr Type"] = get_course_type(course)
            @course_data[course_name]["CRN"] = get_course_crn(course)
            @course_data[course_name]["Instructor"] = get_course_instructor(course)
        end

        @course_data
    end

end

p = Program.new("https://duapp2.drexel.edu/webtms_du/app?component=subjectDetails&page=CollegesSubjects&service=direct&sp=ZH4sIAAAAAAAAAFvzloG1uIhBPjWlVC%2BlKLUiNUcvs6hErzw1qSS3WC8lsSRRLyS1KJcBAhiZGJh9GNgTk0tCMnNTSxhEfLISyxL1iwtz9EECxSWJuQXWPgwcJUAtzvkpQBVCEBU5iXnp%2BsElRZl56TB5l9Ti5EKGOgamioKCEgY2IwNDIyNToJHhmXlAaYXA0sQiEG1opGtoDACLMly%2FpgAAAA%3D%3D&sp=ST&sp=SEDUC&sp=10")

puts p.grab_courses

puts ("\n")

