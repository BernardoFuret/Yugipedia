-- <pre>
--[=[Doc
@module Card table
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

--[[Doc
@function apply
@description Applies `fn` and handles debug.
@parameter {boolean} dbg Boolean flag indicating debug.
@parameter {function} fn Render function to apply.
@return {string} Decorated application of `fn`.
]]
local function apply( dbg, fn )
	return dbg
		and table.concat{ '<pre>', fn(), '</pre>' }
		or fn()
	;
end

local Renderer = {};

Renderer.__index = Renderer;
Renderer.__class = Renderer;

function Renderer:debug()
	self._metadata._debug = true;

	return self;
end

function Renderer:toWikitext()
	return apply( self._metadata._debug, function()
		self._metadata._debug = false;

		return require( 'Module:Card table/Renderer/ToWikitext' )(
			self._metadata._cardTable
		);
	end );
end

--[[function Renderer:toJSON()
	return apply( self._metadata._debug, function()
		self._metadata._debug = false;

		return require( 'Module:Card table/Renderer/ToJSON' )(
			self._metadata._cardTable
		);
	end );
end--]]

--[=[Doc
@exports The constructor for the `Renderer` object.
]=]
return function( ct )
	local data = {
		_metadata = {
			_cardTable = ct,
		},
	};

	return setmetatable( data, Renderer );
end
-- </pre>