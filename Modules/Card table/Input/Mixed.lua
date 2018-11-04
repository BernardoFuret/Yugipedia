-- <pre>
--[=[Doc
@module
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

-- Use Containers as the items.
local Container = require( 'Module:Card table/Input/Container' );

-- Use the behavior of Sequence instance.
local seq = require( 'Module:Card table/Input/Sequence' )();

--[[Doc
@class Mixed
@description Makes use of the `Sequence` behavior to store
`Container`s.
]]
local Mixed = {};
Mixed.__index = Mixed;
Mixed.__class = Mixed;

--[[Doc
@method Mixed Add
]]
function Mixed:Add()
	local d = Container();
	seq.add( self, d );

	return d;
end

--[[Doc
@method Mixed Get
]]
function Mixed:Get( index )
	return seq.get( self, index ) or Container();
end

--[[Doc
@exports The `Mixed` constructor.
]]
return function()
	local data = {
		_data = {},
	};

	return setmetatable( data, Mixed );
end
-- </pre>