-- <pre>
-- @description Creates objects to store module info.
-- @author [[User:Becasita]]
-- @contact [[User talk:Becasita]]

-- Define class:
local InfoClass = {};
InfoClass.__index = InfoClass;

-- @description Initialize the instance of the InfoClass.
function InfoClass.new( title )
	local data = {
		_title      = title or '',
		_categories = {},
		_errors     = {},
	};

	return setmetatable( data, InfoClass );
end

-- @description Returns its gathered categories.
function InfoClass:getCategories()
	return self._categories;
end

-- @description Returns its gathered errors.
function InfoClass:getErrors()
	return self._errors;
end

-- @description Store associated category.
function InfoClass:category( category )
	table.insert( self._categories, category );
	return self;
end

-- @description Store error message.
function InfoClass:error( message, default )
	self._errors.exists = true;
	table.insert( self._errors, message );

	return default or self;
end

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

function InfoClass:dumpErrors( callback )
	callback = callback or function( err, index )
		return ('%d - %s'):format( index, err );
	end;
	local errors = {};
	for index, err in ipairs( self._errors ) do
		table.insert( errors, callback( err, index ) );
	end
	return table.concat( errors, '\n' );
end

-- @export Instatiation method.
return {
	['new'] = InfoClass.new,
}
-- </pre>