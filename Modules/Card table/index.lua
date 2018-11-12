-- <pre>
--[=[Doc
@module Card table
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local CardTable = {
	render = require( 'Module:Card table/Render' ),
};

CardTable.__index = CardTable;
CardTable.__class = CardTable;

function CardTable:Args()
	return self._args or ( function()
		self._metadata._args = require( 'Module:Card table/Args' )();
		return self._metadata._args;
	end )();
end

function CardTable:SMW()
	return self._smw or ( function()
		self._metadata._smw = require( 'Module:Card table/SMW' )();
		return self._metadata._smw;
	end )();
end

--[=[Doc
@exports The constructor for the `CardTable` object.
]=]
return function()
	local data = {
		_metadata = {},
	};

	return setmetatable( data, CardTable );
end
-- </pre>