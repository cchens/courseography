#! /usr/bin/env python3

from urllib.request import urlopen
from html.parser import HTMLParser
import re

# Extract data from Time Table
html = urlopen('http://www.artsandscience.utoronto.ca/ofr/timetable/winter/csc.html')
htmlData = html.read()

# The regular expressions for all 6 fields
course = re.compile('^CSC\d{3}(Y|H)1$')
section = re.compile('^[FSY]{1}$')
lecture = re.compile('^([TL]){1}[0123456789]{2}0{1}\d{1}$')
time = re.compile('^[MWTRF]{1,3}\d{0,2}[-]?\d{0,2}$|Cancel|TBA')
instructor = re.compile('^\w\.|Tba|Staff')
location = re.compile('^\w{2} \d{1,4}')

# Different cases for extracted data
class MyHTMLParser(HTMLParser):
    courseMemory = ''
    sectionMemory = ''
    typeMemory = 'stringsAgainstIndexErrors!'
    timeMemory = ''
    locationMemory = ''
    instructorMemory = ''
    switch = False
    fieldMemory = 0
    coloursToCourses = {
    	
    }

    def handle_data(self, data):
    	if course.match(data):
	        if self.fieldMemory == 4:
	        	print('<tr class=timeTableRow><td></td><td class=timeTableBlock></td><td class=timeTableBlock>' + self.typeMemory +'</td><td class=timeTableBlock>' + self.timeMemory+ '</td><td class=timeTableBlock>'+self.locationMemory+'</td><td class=timeTableBlock>'+ self.instructorMemory+'</td>')
	        self.switch = True
	        self.fieldMemory = 0
	        self.courseMemory = data
    	elif section.match(data) and self.switch:
	        print('<tr class=timeTableRow><td class=timeTableCourse>' + self.courseMemory + '</td><td class=timeTableBlockSection>' + data + '</td>\n')
	        self.sectionMemory = data
	        self.fieldMemory = 1
	        self.switch = False
    	elif lecture.match(data):
	        self.typeMemory = data
	        self.fieldMemory = 2
    	elif time.match(data):
	        self.timeMemory = data
	        self.fieldMemory = 3
	        if data == 'Cancel':
	        	print('<tr class=timeTableRow><td class=timeTableBlock></td><td class=timeTableBlock></td><td class=timeTableBlockTypeLecture>' + self.typeMemory +'</td><td class=timeTableBlockTime>' + data+ '</td><td class=timeTableBlock></td><td class=timeTableBlock></td>')
	        if self.typeMemory[0] == 'T':
	            print('<tr class=timeTableRow><td class=timeTableBlock></td><td class=timeTableBlock></td><td class=timeTableBlockTypeTutorial>' + self.typeMemory +'</td><td class=timeTableBlockTime>' + data+ '</td><td class=timeTableBlock></td><td class=timeTableBlock></td>')
    	elif location.match(data):
	        self.locationMemory = data
	        self.fieldMemory = 4
    	elif instructor.match(data):
	        print('<tr class=timeTableRow><td class=timeTableBlock></td><td class=timeTableBlock></td><td class=timeTableBlockType>' + self.typeMemory +'</td><td class=timeTableBlockTime>' + self.timeMemory+ '</td><td class=timeTableBlockLocation>'+self.locationMemory+'</td><td class=timeTableBlockInstructor>'+data+'</td>')
	        self.fieldMemory = 5
	        self.instructorMemory = data
	        

parser = MyHTMLParser(strict=False)
print('<table class=\"timeTable\">')
print('<tr class=timeTableRow>'
	+ '<td class=timeTableHeader>Course</td>'
	+ '<td class=timeTableHeader>Section</td>'
	+ '<td class=timeTableHeader>Type</td>'
	+ '<td class=timeTableHeader>Time</td>'
	+ '<td class=timeTableHeader>Location</td>'
	+ '<td class=timeTableHeader>Instructor</td>'
	+ '</tr><div><p>')
parser.feed(str(htmlData))
print('</p></div></table>')