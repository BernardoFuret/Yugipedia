-- <pre>
--[=[Doc
@module InfoWrapper
@description Creates an object to store module info.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

--[[Doc
@class InfoWrapper
@description Stores and provides an interface to manage module info.
@exportable
]]
local InfoWrapper = {};
InfoWrapper.__index = InfoWrapper;
InfoWrapper.__class = InfoWrapper;

--[[Doc
@function InfoWrapper new
@description Initializes an instance of `InfoWrapper`.
@return {InfoWrapper} New instance of `InfoWrapper`.
]]
function InfoWrapper.new( title )
	local data = {
		_categories = {},
		_errors     = {},
	};

	InfoWrapper.setTitle( data, title );

	return setmetatable( data, InfoWrapper );
end

--[[Doc
@method InfoWrapper setTitle
@description Changes the instance title.
@parameter {string|nil} title The new title. If `nil`, the empty string is used.
@return {InfoWrapper} `self`
]]
function InfoWrapper:setTitle( title )
	self._title = title and tostring( title ) or '';

	return self;
end

--[[Doc
@method InfoWrapper getCategories
@description Get the stored categories.
@return {table} Table, as an array, of all of the stored categories.
]]
function InfoWrapper:getCategories()
	return self._categories;
end

--[[Doc
@method InfoWrapper getErrors
@description Get the stored errors.
@return {table} Table, as an array, of all of the stored errors.
]]
function InfoWrapper:getErrors()
	return self._errors;
end

--[[Doc
@method InfoWrapper category
@description Stores a new category.
@parameter {string} category The category name
(no need to prefix the `Category` namespace).
@return {InfoWrapper} `self`
]]
function InfoWrapper:category( category )
	table.insert( self._categories, category );

	return self;
end

--[[Doc
@method InfoWrapper error
@description Stores a new error.
@parameter {string} message The error message.
@parameter {*} default A default return a value.
@return {*|InfoWrapper} `default` or `self`.
]]
function InfoWrapper:error( message, default )
	self._errors.exists = true;
	table.insert( self._errors, message );

	return default or self;
end

--[[Doc
@method InfoWrapper dumpCategories
]]
function InfoWrapper:dumpCategories( callback )
	callback = callback or function( cat, index )
		return cat;
	end;

	local categories = {
		self._errors.exists and ('[[Category:((%s)) transclusions to be checked]]'):format( self._title );
	};

	for index, cat in ipairs( self._categories ) do
		table.insert(
			categories,
			callback(
				('[[Category:%s]]'):format( cat ), -- TODO: sortkey
				index
			)
		);
	end

	return table.concat( categories );
end

--[[Doc
@method InfoWrapper dumpErrors
]]
function InfoWrapper:dumpErrors( callback )
	callback = callback or function( err, index )
		return ('%d - %s'):format( index, err );
	end;

	local errors = {};

	for index, err in ipairs( self._errors ) do
		table.insert( errors, callback( err, index ) );
	end

	return table.concat( errors, '\n' ); -- TODO: more flexible delimiter
end

--[=[Doc
@exports The `InfoWrapper` class constructor (`new`).
@see [[#InfoWrapper.new]]
]=]
return setmetatable( InfoWrapper, {
	__call = function( t, ... )
		assert(
			t == InfoWrapper,
			'Cannot apply InfoWrapper constructor except to itself'
		);

		return InfoWrapper.new( ... );
	end
} );
-- </pre>