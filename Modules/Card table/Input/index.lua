-- <pre>
--[=[Doc
@module Card table/Args
@description Object allowing easy creation, construction and manipulation
of the input received by the card table interface.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local Args = {};
Args.__index = Args;
Args.__class = Args;

function Args:Classes()
	return self._metadata._classes or ( function()
		self._metadata._classes = require( 'Module:Card table/Args/Sequence' )();
		return self._metadata._classes;
	end )();
end

function Args:Header()
	return self._metadata._header or ( function()
		self._metadata._header = require( 'Module:Card table/Args/Container' )();
		return self._metadata._header;
	end )();
end

function Args:Caption()
	return self._metadata._caption or ( function()
		self._metadata._caption = require( 'Module:Card table/Args/Container' )();
		return self._metadata._caption;
	end )();
end

function Args:Image()
	return self._metadata._caption or ( function()
		self._metadata._caption = require( 'Module:Card table/Args/Image' )();
		return self._metadata._caption;
	end )();
end

function Args:Rows()
	return self._metadata._rows or ( function()
		self._metadata._rows = require( 'Module:Card table/Args/Mixed' )();
		return self._metadata._rows;
	end )();
end

function Args:Footer()
	return self._metadata._footer or ( function()
		self._metadata._footer = require( 'Module:Card table/Args/Container' )();
		return self._metadata._footer;
	end )();
end

function Args:Sections()
	return self._metadata._sections or ( function()
		self._metadata._sections = require( 'Module:Card table/Args/Mixed' )();
		return self._metadata._sections;
	end )();
end

--[=[Doc
@exports The constructor for the `Args` object.
]=]
return function()
	local data = {
		_metadata = {},
	};

	return setmetatable( data, Args );
end
-- </pre>