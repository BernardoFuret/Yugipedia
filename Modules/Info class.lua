-- <pre>
--[=[Doc
@module Info class
@description Creates an object to store module info.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

--[[Doc
@class InfoClass
@description Stores and provides an interface to manage module info.
@exportable
]]
local InfoClass = {};
InfoClass.__index = InfoClass;
InfoClass.__class = InfoClass;

--[[Doc
@function InfoClass new
@description Initializes an instance of `InfoClass`.
@return {InfoClass} New instance of `InfoClass`.
]]
function InfoClass.new( title )
	local data = {
		_title      = title or '',
		_categories = {},
		_errors     = {},
	};

	return setmetatable( data, InfoClass );
end

--[[Doc
@method InfoClass setTitle
@description Changes the instance title.
@parameter {string|nil} title The new title. If `nil`, the empty string is used.
@return {InfoClass} `self`
]]
function InfoClass:setTitle( title )
	self._title = title or '';

	return self;
end

--[[Doc
@method InfoClass getCategories
@description Get the stored categories.
@return {table} Table, as an array, of all of the stored categories.
]]
function InfoClass:getCategories()
	return self._categories;
end

--[[Doc
@method InfoClass getErrors
@description Get the stored errors.
@return {table} Table, as an array, of all of the stored errors.
]]
function InfoClass:getErrors()
	return self._errors;
end

--[[Doc
@method InfoClass category
@description Stores a new category.
@parameter {string} category The category name
(no need to prefix the `Category` namespace).
@return {InfoClass} `self`
]]
function InfoClass:category( category )
	table.insert( self._categories, category );

	return self;
end

--[[Doc
@method InfoClass error
@description Stores a new error.
@parameter {string} message The error message.
@parameter {*} default A default return a value.
@return {*|InfoClass} `default` or `self`.
]]
function InfoClass:error( message, default )
	self._errors.exists = true;
	table.insert( self._errors, message );

	return default or self;
end

--[[Doc
@method InfoClass dumpCategories
]]
function InfoClass:dumpCategories( callback )
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
@method InfoClass dumpErrors
]]
function InfoClass:dumpErrors( callback )
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
@exports The `InfoClass` class constructor (`new`).
@see [[#InfoClass.new]]
]=]
return {
	['new'] = InfoClass.new,
}
-- </pre>