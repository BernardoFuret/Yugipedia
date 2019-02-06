-- <pre>
--[=[Doc
@module
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]


local Container = {};
Container.__index = Container;
Container.__class = Container;

function Container:setLabel( label )
	self._data._label = label;

	return self;
end

function Container:setContent( content )
	self._data._content = content;

	return self;
end

function Container:setId( id )
	self._data._id = id;

	return self;
end

function Container:getLabel()
	return self._data._label;
end

function Container:getContent()
	return self._data._content;
end

function Container:getId()
	return self._data._id;
end

return function()
	local data = {
		_data = {},
	};

	return setmetatable( data, Container );
end
-- </pre>