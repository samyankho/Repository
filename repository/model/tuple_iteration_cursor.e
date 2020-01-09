note
	description: "Summary description for {TUPLE_ITERATION_CURSOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"


	-- Here the -> means constrained genericity:
	-- client of TUPLE_ITERATION_CURSOR may instantiate K to any class,
	-- as long as it is a descendant of HASHABLE (i.e., so it can be used as a key in hash table).
class
	TUPLE_ITERATION_CURSOR[K -> HASHABLE, V1, V2]

inherit
	ITERATION_CURSOR[TUPLE[V1, V2, K]]
	

create
	make



feature
	keys: LINKED_LIST[K]
	data_items_1: ARRAY[V1]
	data_items_2: HASH_TABLE[V2, K]
	i: INTEGER

feature
	make(v1:ARRAY[V1]; v2:HASH_TABLE[V2, K]; k:LINKED_LIST[K])
	do
		data_items_1:=v1
		data_items_2:=v2
		keys:=k
		i:=1
	end

feature -- Access

		item: TUPLE[V1, V2, K]
			-- Item at current cursor position.
		do
			check attached {V2} data_items_2[keys[i]] as v2 then
				Result := [data_items_1[i], v2, keys[i]]
			end

		end

feature -- Status report	

	after: BOOLEAN
			-- Are there no more items to iterate over?
		do
			Result:= i>data_items_1.count
		end

feature -- Cursor movement

	forth
			-- Move to next position.
		do
			i:=i+1
		end

end

