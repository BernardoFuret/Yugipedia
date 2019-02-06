-- <pre>
--[=[Doc
@module Card table/Args/Image
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

function Image:setWidth( width )
	self._data._width = tonumber( width );

	return self;
end

function Image:setId( id )
	self._data._id = id;

	return self;
end

function Image:Header()
	return self._data._header or ( function()
		self._data._header = require( 'Module:Card table/Args/Container' )();
		return self._data._header;
	end )();
end

function Image:Footer()
	return self._data._footer or ( function()
		self._data._footer = require( 'Module:Card table/Args/Container' )();
		return self._data._footer;
	end )();
end

function Image:getMain()
	return self._data._main;
end

function Image:getDefault()
	return self._data._default;
end

function Image:getWidth()
	return self._data._width;
end

function Image:getId()
	return self._data._id;
end

return function()
	local data = {
		_data = {},
	};

	return setmetatable( data, Image );
end
-- </pre>