note
	description: "[
		The REPOSITORY ADT consists of data sets.
		Each data set maps from a key to two data items (which may be of different types).
		There should be no duplicates of keys. 
		However, multiple keys might map to equal data items.
		]"
	author: "Jackie and Xunyuan He"
	date: "$Date$"
	revision: "$Revision$"

-- Advice on completing the contracts:
-- It is strongly recommended (although we do not enforce this in this lab)
-- that you do NOT implement auxiliary/helper queries
-- when writing the assigned pre-/post-conditions.
-- In the final written exam, you will be required to write contracts using (nested) across expressions only.
-- You may want to practice this now!



class
	-- Here the -> means constrained genericity:
	-- client of REPOSITORY may instantiate KEY to any class,
	-- as long as it is a descendant of HASHABLE (i.e., so it can be used as a key in hash table).

	REPOSITORY[KEY -> HASHABLE, DATA1, DATA2]
	--means the dynamic type of key can be hashtable, linklist or array



inherit
	ITERABLE[TUPLE[DATA1, DATA2, KEY]]
	--make the current class iterable

create
	make

feature {ES_TEST} -- Do not modify this export status!
	-- You are required to implement all repository features using these three attributes.

	-- For any valid index i, a data set is composed of keys[i], data_items_1[i], and data_items_2[keys[i]].

	keys: LINKED_LIST[KEY]                  --keys store as a linked list
	data_items_1: ARRAY[DATA1]              --data1 stored using an array
	data_items_2: HASH_TABLE[DATA2, KEY]    --using the key to value for hash table to store data2






feature -- feature(s) required by ITERABLE
	-- TODO:
	-- See test_iterable_repository and test_iteration_cursor in EXAMPLE_REPOSITORY_TESTS.
	-- As soon as you make the current class iterable,
	-- define the necessary feature(s) here.


	new_cursor: ITERATION_CURSOR[TUPLE[DATA1, DATA2, KEY]]
		do
			create {TUPLE_ITERATION_CURSOR[KEY, DATA1, DATA2]}
			Result.make(data_items_1, data_items_2, keys)
		end
		--define the new cursor for testing the tuple iteration






feature -- alternative iteration cursor
	-- TODO:
	-- See test_another_cursor in EXAMPLE_REPOSITORY_TESTS.
	-- A feature 'another_cursor' is expected to be defined here.

	another_cursor: ITERATION_CURSOR[DATA_SET[DATA1, DATA2, KEY]]
	do
		create {DATA_SET_ITERATION_CURSOR[DATA1, DATA2, KEY]}
		Result.make(data_items_1, data_items_2, keys)
	end
	--define another new cursor for testing the data set iteration









feature -- Constructor
	make
			-- Initialize an empty repository.
		do
			-- TODO:
			create keys.make                   --create a empty linked list
			create data_items_1.make_empty      --create a empty array
			create data_items_2.make (20)       --create a hashtable for size 20
			keys.compare_objects
			data_items_1.compare_objects        --ensure using equal instead of = for compare address(reference)
			data_items_2.compare_objects



		ensure
			empty_repository: -- TODO: make sure no tuple in repository
				keys.is_empty and data_items_1.is_empty and data_items_2.is_empty

			-- Do not modify the following three postconditions.
			object_equality_for_keys:
				keys.object_comparison
			object_equality_for_data_items_1:
				data_items_1.object_comparison
			object_equality_for_data_items_2:
				data_items_2.object_comparison
		end








feature -- Commands

	check_in (d1: DATA1; d2: DATA2; k: KEY)
			-- Insert a new data set into current repository.
		require
			non_existing_key: -- TODO:
				not exists(k)

		do
			-- TODO: insert(add) a tuple in repository
			keys.force (k)
			data_items_1.force (d1, keys.count)
			data_items_2.put (d2, k)



		ensure
			repository_count_incremented: -- TODO:
				count = old count + 1


			data_set_added: -- TODO:
				-- Hint: At least a data set in the current repository
				-- has its key 'k', data item 1 'd1', and data item 2 'd2'.
				across 1 |..| count
					 is i
				some
					keys[i] ~ k and data_items_1[i] ~ d1 and data_items_2[k] ~ d2  --key to value for hashtable
				end



			others_unchanged: -- TODO:
				-- Hint: Each data set in the current repository,
				-- if not the same as (`k`, `d1`, `d2`), must also exist in the old repository.
				across  1 |..| (count - 1)
 					 is i
				all
				    keys[i] ~ (old keys.deep_twin)[i] and data_items_1[i] ~ (old data_items_1.deep_twin)[i]
				    and data_items_2[keys[i]] ~ (old data_items_2.deep_twin)[keys[i]]
				end
		end












	check_out (k: KEY)
			-- Delete a data set with key `k` from current repository.
		require
			existing_key: -- TODO:
				exists(k)


	    local i,j : INTEGER
		do
			-- TODO:
			data_items_2.remove (k)


			from
				keys.start --move cursor to the first position in the linklist
			until
				keys.after  --utill the last position
			loop
				if
					keys.item ~ k  --find the key
				then

					j := keys.index
					keys.remove
				end

				keys.forth  --move to the next key in the hash table
			end

			from
				i := j  --from index of key
			until
				i >= keys.count + 1
			loop
				data_items_1.force (data_items_1[i+1], i) --all element shift left by one position
				i := i + 1  --count
			end
			data_items_1.remove_tail (1)  --remove the last one





		ensure
			repository_count_decremented: -- TODO:
				count = old count - 1



			key_removed: -- TODO:
				(not keys.has (k)) and (not data_items_2.has (k))
--				and
--				across  1 |..| count
--					 is j
--				all
--				     not data_items_1[j] ~ k
--				end



			others_unchanged:
				-- Hint: Each data set in the old repository,
				-- if not with key `k`, must also exist in the curent repository.

			   	across (old keys) is key all not (key/~k) or keys.has (key) end
		end      --make sure k has been delete and all key is in the linked list










feature -- Queries



	count: INTEGER
			-- Number of data sets in repository.
		do
			-- TODO:
			result := keys.count --the element in the linked list

		ensure
			correct_result: -- TODO:
				result = data_items_1.count and result = data_items_2.count
		end







	exists (k: KEY): BOOLEAN
			-- Does key 'k' exist in the repository?
		do
			-- TODO: check if k exist in the linked list
			result := keys.has (k)

		ensure
			correct_result: -- TODO:
				result = data_items_2.has (k)

		end









	matching_keys (d1: DATA1; d2: DATA2): ITERABLE[KEY]
			-- Keys that are associated with data items 'd1' and 'd2'.

			local
				temp: ARRAY[KEY] --array of keys
		do
			-- TODO:
			create temp.make_empty  --create an empty array

			across current is t
			loop
				if t.item(1)~d1 and t.item(2)~d2 then
					check attached {KEY} t.item(3) as key then temp.force (key, temp.count+1) end
				end
			end
			result:= temp  --put the correct key in the temp



		ensure
			result_contains_correct_keys_only: -- TODO:
				-- Hint: Each key in Result has its associated data items 'd1' and 'd2'.
				across  result
					 is i
				all
				    (data_items_1[keys.index_of (i, 1)] ~ d1 and data_items_2[i] ~ d2)
				end  --go to the first occurence of key in the array, and check if they have the same d1 and d2




			correct_keys_are_in_result: -- TODO:
				-- Hint: Each data set with data items 'd1' and 'd2' has its key included in Result.
				-- Notice that Result is ITERABLE and does not support the feature 'has',
				-- Use the appropriate across expression instead.
				across  1 |..| count
					 is i
				all
				    (data_items_1[i] ~ d1 and data_items_2[keys[i]] ~ d2) implies
				    across	result
				    	 is key
				    some
				    	key ~ keys[i]

				    end
				end
		end








invariant
	unique_keys: -- TODO:
		-- Hint: No two keys are equal to each other.
		across  1 |..| count
			 is i
		all
			across  1 |..| count
				 is j
			all
				i /= j implies keys[i] /~ keys[j]

			end

		end



	-- Do not modify the following class invariants.
	implementation_contraint:
		data_items_1.lower = 1



	consistent_keys_data_items_counts:
		keys.count = data_items_1.count
		and
		keys.count = data_items_2.count



	consistent_keys:
		across
			keys is k
		all
			data_items_2.has (k)
		end



	consistent_imp_adt_counts:
		keys.count = count
end
