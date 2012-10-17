require 'net/https'
require 'nokogiri'
require 'open-uri'

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

url = ""

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
doc = Nokogiri::HTML open( url )

course_list = doc.css('table').css('tr')[3].css('td').css('tr')[6].css('tr')

course_data = Hash.new

courses = Array.new

course_list.css('tr').each do |course|
    courses << course if (course.css('td').length > 2) && (course.css('td')[0].content.match(/[A-Z]{3,}/))
end

courses.each do |course|
    course_name = "#{get_subject_code(course)}-#{get_course_number(course)}-#{get_course_sec(course)}"
    course_data[course_name] = {}
    course_data[course_name]["Subject Code"] = get_subject_code(course)
    course_data[course_name]["Course Number"] = get_course_number(course)
    course_data[course_name]["Instr Type"] = get_course_type(course)
    course_data[course_name]["CRN"] = get_course_crn(course)
    course_data[course_name]["Instructor"] = get_course_instructor(course)
end

puts course_data

