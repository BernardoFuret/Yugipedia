-- <pre>
--[=[Doc
@module IndexedCounter
@description An index mapping keys to numeric values.
]=]

local IndexedCounter = {}
IndexedCounter.__index = IndexedCounter
IndexedCounter.__class = IndexedCounter

local StorageMetatable = {
	__index = function()
		return 0
	end,
}

StorageMetatable.__class = StorageMetatable

local Storage = setmetatable( StorageMetatable, {
	__call = function( self )
		assert(
			self == StorageMetatable,
			'Cannot apply Storage constructor except to itself'
		)

		return setmetatable( {}, StorageMetatable )
	end
} )

function IndexedCounter.new()
	local data = {
		_data = Storage()
	}

	return setmetatable( data, IndexedCounter )
end


function IndexedCounter:increment( key, value )
	self._data[ key ] = self._data[ key ] + value
end

function IndexedCounter:get( key )
	return self._data[ key ]
end

function IndexedCounter:each()
	return pairs( self._data )
end

return setmetatable( IndexedCounter, {
	__call = function( self )
		assert(
			self == IndexedCounter,
			'Cannot apply IndexedCounter constructor except to itself'
		)

		return IndexedCounter.new()
	end
} )
