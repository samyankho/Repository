note
	description: "Documentation of how a REPOSITORY should be used."
	date: "$Date$"
	revision: "$Revision$"

class
	EXAMPLE_REPOSITORY_TESTS

inherit
	ES_TEST
		redefine
			setup, teardown
		end

create
	make

feature  -- Add tests

	make
			-- Run application.
		do
			create repos.make
			check repos.count = 0 end

			add_boolean_case (agent test_array_comparison)
			add_boolean_case (agent test_hash_table_retrieval)
			add_boolean_case (agent test_setup)
			add_boolean_case (agent test_matching_keys)
			add_boolean_case (agent test_check_out)
			add_boolean_case (agent test_iterable_repository)
			add_boolean_case (agent test_iteration_cursor)
			add_boolean_case (agent test_another_cursor)
		end




feature -- Auxiliary tests for clarifying concepts

	test_array_comparison: BOOLEAN
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






	test_hash_table_retrieval: BOOLEAN
		local
			table: HASH_TABLE[STRING, INTEGER]
			values: LINKED_LIST[STRING]
		do
			comment ("test_hash_table_retrieval: test return value from hash table")

			create table.make (10) -- maximum capacity of 10 entries to begin with
			Result := table.count = 0 and table.is_empty
			check Result end

			table.extend ("value1", 1)
			table.extend ("value2", 2)

			Result := table.count = 2 and table[1] ~ "value1" and table[2] ~ "value2"
			check Result end

			create values.make
			-- Version 1: this line does not compile because
			-- each member of the `values` array is expected to be non-void,
			-- but table[k], from the compiler's point of view, might return void
			-- if k is not an existing key of the has table.

--			values.extend (table[1])

			-- Version 2: assert to the compiler (via a check assertion) that
			-- table[1] and table[2] specifically would return non-void value,
			-- because we are certain that 1 and 2 are existing keys.
			-- Overall a check assertion goes like: check B then S end,
			-- where B is a Boolean expression, and S is a sequene of instructions (assignments, if-statements, loops, etc.).
			check
				-- `attached` is a keyword.
				-- Writing `attached E as VAR` evalues to either true or false.
				-- If `E` is an expression that denotes a non-void (i.e., attached) object, then
				-- let a new local variable `VAR` point to that object.
				-- Otherwise, if `E` is not attached, the expression evalues to false.
				attached table[1] as v1  and attached table[2] as v2
			then
				values.extend (v1)
				values.extend (v2)
			end

			Result := values.count = 2 and values[1] ~ "value1" and values[2] ~ "value2"
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



	test_setup: BOOLEAN
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






	test_check_out: BOOLEAN
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






	test_matching_keys: BOOLEAN
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






	test_iterable_repository: BOOLEAN
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





	test_iteration_cursor: BOOLEAN
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





	test_another_cursor: BOOLEAN
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
end
