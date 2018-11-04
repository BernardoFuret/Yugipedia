-- <pre>
--[=[Doc
@module Card table/Input
@description Object allowing easy creation, construction and manipulation
of the input received by the card table interface.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local Input = {};
Input.__index = Input;
Input.__class = Input;

function Input:Classes()
	return self._metadata._classes or ( function()
		self._metadata._classes = require( 'Module:Card table/Input/Sequence' )();
		return self._metadata._classes;
	end )();
end

function Input:Header()
	return self._metadata._header or ( function()
		self._metadata._header = require( 'Module:Card table/Input/Container' )();
		return self._metadata._header;
	end )();
end

function Input:Caption()
	return self._metadata._caption or ( function()
		self._metadata._caption = require( 'Module:Card table/Input/Container' )();
		return self._metadata._caption;
	end )();
end

function Input:Image()
	return self._metadata._caption or ( function()
		self._metadata._caption = require( 'Module:Card table/Input/Image' )();
		return self._metadata._caption;
	end )();
end

function Input:Rows()
	return self._metadata._rows or ( function()
		self._metadata._rows = require( 'Module:Card table/Input/Mixed' )();
		return self._metadata._rows;
	end )();
end

function Input:Footer()
	return self._metadata._footer or ( function()
		self._metadata._footer = require( 'Module:Card table/Input/Container' )();
		return self._metadata._footer;
	end )();
end

function Input:Sections()
	return self._metadata._sections or ( function()
		self._metadata._sections = require( 'Module:Card table/Input/Mixed' )();
		return self._metadata._sections;
	end )();
end

--[=[Doc
@exports The constructor for the `???`.
]=]
return function()
	local data = {
		_metadata = {},
	};

	return setmetatable( data, Input );
end
-- </pre>