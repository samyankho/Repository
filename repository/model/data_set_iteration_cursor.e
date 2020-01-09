note
	description: "Summary description for {DATASET_ITERATION_CURSOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DATA_SET_ITERATION_CURSOR[V1, V2, K -> HASHABLE]
	-- client of DATADET_ITERATION_CURSOR may instantiate v1, v2 or k to any hashtable,


inherit
	ITERATION_CURSOR[DATA_SET[V1, V2, K]]
	--inherit ITERATION_CURSOR for dataset


create
	make


feature  --declare the variable
	keys: LINKED_LIST[K]
	data_items_1: ARRAY[V1]
	data_items_2: HASH_TABLE[V2,K]
	i: INTEGER  --counter


feature   -- create item
	make(v1: ARRAY[v1]; v2: HASH_TABLE[V2,K]; k: LINKED_LIST[K])
	do
		data_items_1 := v1
		data_items_2 := v2
		keys := k
		i := 1
	end






feature  -- access to the data

	item: DATA_SET[V1, V2, K]  --the data store at current cursor position

	do
		check  attached {V2}  data_items_2[keys[i]] as v2 then
			create result.make (data_items_1[i], v2, keys[i])

		 end
	end





feature --move to next position

    forth  --move the cursor to the next position

    do
    	i := i + 1
    end





feature  -- report if it is the last item

	after: BOOLEAN  -- keep iterate till the last one

	    do
	    	result:= i > data_items_1.count
	    end





end
