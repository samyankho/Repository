note
	description: "Tests created by student"
	author: "You"
	date: "$Date$"
	revision: "$Revision$"

class
	STUDENT_TESTS

inherit
	ES_TEST
		redefine
			setup, teardown
		end

create
	make

feature -- Add tests

	make   --run
		do

			create repos.make
			check repos.count = 0 end
			add_boolean_case (agent t1)
			add_boolean_case (agent t2)
			add_boolean_case (agent t3)
			add_boolean_case (agent t4)
			add_boolean_case (agent t5)
			add_boolean_case (agent t6)
			add_boolean_case (agent t7)
			add_boolean_case (agent t8)
			add_boolean_case (agent t9)
			add_boolean_case (agent t10)
			add_boolean_case (agent t11)


		end




feature -- Setup

	repos: REPOSITORY[STRING, CHARACTER, INTEGER]

	setup
			-- Initialize 'd' as a 4-data-sets repository.
			-- This feature is executed in the beginning of every test feature.
		do
			repos.check_in ('a', 1, "A")
			repos.check_in ('b', 2, "B")
			repos.check_in ('c', 3, "C")
			repos.check_in ('d', 4, "D")
		end


	teardown
			-- Recreate 'd' as an empty repository.
			-- This feature is executed at end of every test feature.
		do
			create repos.make
		end






feature -- Tests

	t1: BOOLEAN
		local
			tuples: LINKED_LIST[TUPLE[d1: CHARACTER; d2: INTEGER; k: STRING]]
		do
			comment ("test_setup: test the initial repository")
			create tuples.make
			across
				repos is tuple
			loop
				tuples.extend (tuple)
			end

			Result :=
					repos.count = 4
				and tuples.count = 4
				and	tuples[1].d1 ~ 'a' and tuples[1].d2 ~ 1 and tuples[1].k ~ "A"
				and	tuples[2].d1 ~ 'b' and tuples[2].d2 ~ 2 and tuples[2].k ~ "B"
				and	tuples[3].d1 ~ 'c' and tuples[3].d2 ~ 3 and tuples[3].k ~ "C"
				and	tuples[4].d1 ~ 'd' and tuples[4].d2 ~ 4 and tuples[4].k ~ "D"
		end






	t2: BOOLEAN
		local
			tuples: LINKED_LIST[TUPLE[d1: CHARACTER; d2: INTEGER; k: STRING]]
		do
			comment ("test_check_out: test data set deletion")
			repos.check_out ("B")
			create tuples.make
			across
				repos as tuple_cursor
			loop
				tuples.extend (tuple_cursor.item)
			end

			Result :=
						repos.count = 3
				and 	tuples.count = 3
				-- Note: Look at the type declaration of local variable 'tuples',
				-- where 1st element has name 'd1', 2nd element 'd2', and 3rd element 'k'.
				-- So we can use 'd1', 'd2', and 'k' to access tuple elements here,
				-- equivalent to writing 'item(1)', 'item(2)', and 'item(3)'.
				and	tuples[1].d1 ~ 'a' and tuples[1].d2 ~ 1 and tuples[1].k ~ "A"
				and	tuples[2].d1 ~ 'c' and tuples[2].d2 ~ 3 and tuples[2].k ~ "C"
				and	tuples[3].d1 ~ 'd' and tuples[3].d2 ~ 4 and tuples[3].k ~ "D"
		end





	t3: BOOLEAN
		local
			keys: ARRAY[STRING]
		do
			comment ("test_matching_keys: test iterable keys")
			create keys.make_empty
			repos.check_in ('a', 1, "E")

			create keys.make_empty
			across
				repos.matching_keys ('a', 1) as k
			loop
				keys.force (k.item, keys.count + 1)
			end
			Result :=
						keys.count = 2
				 and	keys[1] ~ "A"
				 and 	keys[2] ~ "E"
			check Result end
		end




		t4: BOOLEAN
			local
				a1, a2: ARRAY[STRING]
			do
				comment ("test_array_comparison: test ref. and obj. comparison")
				create a1.make_empty
				create a2.make_empty
				a1.force ("A", 1)
				a1.force ("B", 2)
				a1.force ("C", 3)

				a2.force ("A", 1)
				a2.force ("B", 2)
				a2.force ("C", 3)

				Result :=
							not a1.object_comparison
					and	not a2.object_comparison
					and 	not (a1 ~ a2)
				check Result end



				a1.compare_objects
				a2.compare_objects
				Result :=
							a1.object_comparison
					and	a2.object_comparison
					and 	a1 ~ a2
			end









	t5: BOOLEAN
		local
			tuples: ARRAY[TUPLE[CHARACTER, INTEGER, STRING]]
		do
			comment ("test_iterable_repository: test iterating through repository")
			create tuples.make_empty
			across
				repos is tuple
			loop
				tuples.force (tuple, tuples.count + 1)
			end
			Result :=
					 	repos.count = 4
				 and	 tuples.count = 4
				-- Note: Look at the type declaration of local variable 'tuples',
				-- where no names are given to 1st, 2nd, and 3rd elements.
				-- So we can only write 'item(1)', 'item(2)', and 'item(3)'.
				 and	tuples[1].item (1) = 'a' and tuples[1].item(2) = 1 and tuples[1].item(3) ~ "A"
				 and	tuples[2].item (1) = 'b' and tuples[2].item(2) = 2 and tuples[2].item(3) ~ "B"
				 and 	tuples[3].item (1) = 'c' and tuples[3].item(2) = 3 and tuples[3].item(3) ~ "C"
				 and tuples[4].item (1) = 'd' and tuples[4].item(2) = 4 and tuples[4].item(3) ~ "D"
		end





	t6: BOOLEAN
		local
			tic: TUPLE_ITERATION_CURSOR[STRING, CHARACTER, INTEGER]
			tuples: ARRAY[TUPLE[CHARACTER, INTEGER, STRING]]
		do
			comment ("test_iteration_cursor: test the returned cursor from repository")
			create tuples.make_empty
			-- Static type of repos.new_cursor is ITERATION_CURSOR, and given that
			-- its dynamic type is TUPLE_ITERATION_CURSOR, we can do a type cast.
			check  attached {TUPLE_ITERATION_CURSOR[STRING, CHARACTER, INTEGER]} repos.new_cursor as nc then
				tic := nc
			end
			from
				-- no need to say tic.start here!
			until
				tic.after
			loop
				tuples.force (tic.item, tuples.count + 1)
				tic.forth
			end
			Result :=
					 tuples.count = 4
				 and	tuples[1].item (1) = 'a' and tuples[1].item(2) = 1 and tuples[1].item(3) ~ "A"
				 and	tuples[2].item (1) = 'b' and tuples[2].item(2) = 2 and tuples[2].item(3) ~ "B"
				 and tuples[3].item (1) = 'c' and tuples[3].item(2) = 3 and tuples[3].item(3) ~ "C"
				 and tuples[4].item (1) = 'd' and tuples[4].item(2) = 4 and tuples[4].item(3) ~ "D"
		end






	t7: BOOLEAN
		local
			ric: DATA_SET_ITERATION_CURSOR[CHARACTER, INTEGER, STRING]
			entries: ARRAY[DATA_SET[CHARACTER, INTEGER, STRING]]
		do
			comment ("test_another_cursor: test the alternative returned cursor from repository")
			create entries.make_empty
			-- Static type of repos.another_cursor is ITERATION_CURSOR, and given that
			-- its dynamic type is DATA_SET_ITERATION_CURSOR, we can do a type cast.
			check attached {DATA_SET_ITERATION_CURSOR[CHARACTER, INTEGER, STRING]} repos.another_cursor as nc then
				ric := nc
			end
			from
			until
				ric.after
			loop
				entries.force (ric.item, entries.count + 1)
				ric.forth
			end
			Result :=
						entries.count = 4
						-- Note that the right-hand side of ~ are anonymous objects.
				 and	entries [1] ~ (create {DATA_SET[CHARACTER, INTEGER, STRING]}.make ('a', 1, "A"))
				 and	entries [2] ~ (create {DATA_SET[CHARACTER, INTEGER, STRING]}.make ('b', 2, "B"))
				 and	entries [3] ~ (create {DATA_SET[CHARACTER, INTEGER, STRING]}.make ('c', 3, "C"))
				 and	entries [4] ~ (create {DATA_SET[CHARACTER, INTEGER, STRING]}.make ('d', 4, "D"))
		end




	t8: BOOLEAN
		local
			tuples: LINKED_LIST[TUPLE[d1: CHARACTER; d2: INTEGER; k: STRING]]
		do
			comment ("test_setup: test the initial repository")
			create tuples.make
			across
				repos is tuple
			loop
				tuples.extend (tuple)
			end

			Result :=
					repos.count = 4
				and tuples.count = 4
				and	tuples[1].d1 ~ 'a' and tuples[1].d2 ~ 1 and tuples[1].k ~ "A"
				and	tuples[2].d1 ~ 'b' and tuples[2].d2 ~ 2 and tuples[2].k ~ "B"
				and	tuples[3].d1 ~ 'c' and tuples[3].d2 ~ 3 and tuples[3].k ~ "C"
				and	tuples[4].d1 ~ 'd' and tuples[4].d2 ~ 4 and tuples[4].k ~ "D"
		end




	t9: BOOLEAN
		local
			tuples: LINKED_LIST[TUPLE[d1: CHARACTER; d2: INTEGER; k: STRING]]
		do
			comment ("test_check_out: test data set deletion")
			repos.check_out ("B")
			create tuples.make
			across
				repos as tuple_cursor
			loop
				tuples.extend (tuple_cursor.item)
			end

			Result :=
						repos.count = 3
				and 	tuples.count = 3
				-- Note: Look at the type declaration of local variable 'tuples',
				-- where 1st element has name 'd1', 2nd element 'd2', and 3rd element 'k'.
				-- So we can use 'd1', 'd2', and 'k' to access tuple elements here,
				-- equivalent to writing 'item(1)', 'item(2)', and 'item(3)'.
				and	tuples[1].d1 ~ 'a' and tuples[1].d2 ~ 1 and tuples[1].k ~ "A"
				and	tuples[2].d1 ~ 'c' and tuples[2].d2 ~ 3 and tuples[2].k ~ "C"
				and	tuples[3].d1 ~ 'd' and tuples[3].d2 ~ 4 and tuples[3].k ~ "D"
		end





	t10: BOOLEAN
		local
			tuples: LINKED_LIST[TUPLE[d1: CHARACTER; d2: INTEGER; k: STRING]]
		do
			comment ("delete tuple which has key A")
			repos.check_out ("A")
			create tuples.make
			across
				repos as tuple_cursor
			loop
				tuples.extend (tuple_cursor.item)
			end

			Result :=
						repos.count = 3
				and 	tuples.count = 3
				-- Note: Look at the type declaration of local variable 'tuples',
				-- where 1st element has name 'd1', 2nd element 'd2', and 3rd element 'k'.
				-- So we can use 'd1', 'd2', and 'k' to access tuple elements here,
				-- equivalent to writing 'item(1)', 'item(2)', and 'item(3)'.
				and	tuples[2].d1 ~ 'c' and tuples[2].d2 ~ 3 and tuples[2].k ~ "C"
				and	tuples[3].d1 ~ 'd' and tuples[3].d2 ~ 4 and tuples[3].k ~ "D"
		end






	t11: BOOLEAN
		local
			tuples: LINKED_LIST[TUPLE[d1: CHARACTER; d2: INTEGER; k: STRING]]
		do
			comment ("delete tuple which has key C")
			repos.check_out ("C")
			create tuples.make
			across
				repos as tuple_cursor
			loop
				tuples.extend (tuple_cursor.item)
			end

			Result :=
						repos.count = 3
				and 	tuples.count = 3
				-- Note: Look at the type declaration of local variable 'tuples',
				-- where 1st element has name 'd1', 2nd element 'd2', and 3rd element 'k'.
				-- So we can use 'd1', 'd2', and 'k' to access tuple elements here,
				-- equivalent to writing 'item(1)', 'item(2)', and 'item(3)'.
				and	tuples[3].d1 ~ 'd' and tuples[3].d2 ~ 4 and tuples[3].k ~ "D"
		end



	t12: BOOLEAN
		local
			tuples: LINKED_LIST[TUPLE[d1: CHARACTER; d2: INTEGER; k: STRING]]
		do
			comment ("add a tuple in the reposity")
			repos.check_in ('h', 8,"H")
			create tuples.make
			across
				repos is tuple
			loop
				tuples.extend (tuple)
			end

			Result :=
					repos.count = 4
				and tuples.count = 4
				and	tuples[1].d1 ~ 'a' and tuples[1].d2 ~ 1 and tuples[1].k ~ "A"
				and	tuples[2].d1 ~ 'b' and tuples[2].d2 ~ 2 and tuples[2].k ~ "B"
				and	tuples[3].d1 ~ 'c' and tuples[3].d2 ~ 3 and tuples[3].k ~ "C"
				and	tuples[4].d1 ~ 'd' and tuples[4].d2 ~ 4 and tuples[4].k ~ "D"
				and	tuples[5].d1 ~ 'h' and tuples[5].d2 ~ 8 and tuples[5].k ~ "H"
		end






end
