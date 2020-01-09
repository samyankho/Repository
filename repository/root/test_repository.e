note
	description: "Test the REPOSITORY ADT"
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_REPOSITORY

inherit
	ES_SUITE

create
	make

feature -- Add test classes
	make
		do
			add_test (create {EXAMPLE_REPOSITORY_TESTS}.make)
			add_test (create {STUDENT_TESTS}.make)
			show_browser
			run_espec
		end
end
