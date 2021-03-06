-- <pre>
--[=[Doc
@module Card table
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local InfoWrapper = require( 'Module:InfoWrapper' );

local CardTable = setmetatable( {}, InfoWrapper );

CardTable.__index = CardTable;
CardTable.__class = CardTable;

function CardTable:Args()
	return self._metadata._args or ( function()
		self._metadata._args = require( 'Module:Card table/Args' )();
		return self._metadata._args;
	end )();
end

function CardTable:SMW()
	return self._metadata._smw or ( function()
		self._metadata._smw = require( 'Module:Card table/SMW' )();
		return self._metadata._smw;
	end )();
end

function CardTable:Render()
	return self._metadata._renderer or ( function()
		self._metadata._renderer = require( 'Module:Card table/Renderer' )( self );
		return self._metadata._renderer;
	end )();
end

--[=[Doc
@exports The constructor for the `CardTable` object.
]=]
return function( title )
	local data = InfoWrapper( title );
	data._metadata = {};

	return setmetatable( data, CardTable );
end
-- </pre>