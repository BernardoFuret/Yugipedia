-- <pre>
--[=[Doc
@module Card table/SMW
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local SMW = {};
SMW.__index = SMW;
SMW.__class = SMW;

function SMW:set( property, value )
	self._metadata[ property ] = value;

	return self;
end

function SMW:get( property )
	return self._metadata[ property ];
end

--[=[Doc
@exports The constructor for the `SMW` object.
]=]
return function()
	local data = {
		_metadata = {},
	};

	return setmetatable( data, SMW );
end
-- </pre>