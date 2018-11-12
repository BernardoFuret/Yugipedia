-- <pre>
--[=[Doc
@module
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

--[[Doc
@class Sequence
@description Stores a sequence of items and provides an easy
interface to deal with them.
]]
local Sequence = {};
Sequence.__index = Sequence;
Sequence.__class = Sequence;

--[[Doc
@method Sequence add
@description Adds an item to the sequence.
@parameter {*} item The item to add to the sequence.
@returns {Sequence} `self`
]]
function Sequence:add( item )
	table.insert( self._data, item );

	return self;
end

--[[Doc
@method Sequence get
@description Retrieves an item of the sequence.
@parameter {*} index The index of the item to retrieve If the index is
not a number or convertible to number, then a list of all items is returned.
@returns {*|table} Item at position `index` or a list of all items.
]]
function Sequence:get( index ) -- TODO: accept index or callback
	if not tonumber( index ) then
		return self._data; -- TODO: getAll()
	end

	return self._data[ index ];
end

-- TODO: search for something and insert after it
--function Sequence:insertAfter( search ) insertBefore find
	-- body
--end

--[[Doc
@method Sequence values
@description Returns an iterator that yields
one element and its index at a time.
@return {function} Iterator function returning
the current item and its index.
--]]
function Sequence:values()
	local index = 0;
	local length = #self._data;

	return function()
		index = index + 1;

		if index <= length then
			return self._data[ index ], index;
		end
	end
end

--[[Doc
@exports The `Sequence` constructor.
]]
return function()
	local data = {
		_data = {},
	};

	return setmetatable( data, Sequence );
end
-- </pre>