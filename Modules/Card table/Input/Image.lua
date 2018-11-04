-- <pre>
--[=[Doc
@module
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local Image = {};
Image.__index = Image;
Image.__class = Image;

function Image:setMain( filename )
	self._data._main = filename;

	return self;
end

function Image:setDefault( filename )
	self._data._default = filename;

	return self;
end

function Image:setId( id )
	self._data._id = id;

	return self;
end

function Image:Header()
	return self._data._header or ( function()
		self._data._header = require( 'Module:Card table/Input/Container' )();
		return self._data._header;
	end )();
end

function Image:Footer()
	return self._data._footer or ( function()
		self._data._footer = require( 'Module:Card table/Input/Container' )();
		return self._data._footer;
	end )();
end

function Container:getMain()
	return self._data._main;
end

function Container:getDefault()
	return self._data._default;
end

function Container:getId()
	return self._data._id;
end

return function()
	local data = {
		_data = {},
	};

	return setmetatable( data, Image );
end
-- </pre>