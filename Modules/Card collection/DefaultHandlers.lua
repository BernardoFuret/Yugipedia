-- <pre>
--[=[Doc
@module Card collection/DefaultHandlers
@description 
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

local DefaultHandlers = {}

--[[Doc
@function DefaultHandlers new
@description 
@return 
]]
function DefaultHandlers:new( name, reporter, frame )
	local data = {
		name = name,
		reporter = reporter,
		frame = frame,
		utils = require( 'Module:Card collection/Utils' )( name, reporter, frame ), -- TODO: add require( 'Module:Card collection/Utils' ) to the metatable?
	}

	return setmetatable( data, {
		__index = self,
	} )
end

--[[Doc
@method DefaultHandlers initData
@description 
@return 
]]
function DefaultHandlers:initData( globalData )
	return globalData
end

--[[Doc
@method DefaultHandlers initStructure
@description 
@return HTML (`mw.html`) instance.
]]
function DefaultHandlers:initStructure( globalData )
	return mw.html.create( 'div' )
end

--[[Doc
@method DefaultHandlers handleRow
@description Parses the row content
@return 
]]
function DefaultHandlers:handleRow( row, globalData )
	local rowString = ( 'Non-empty line: %d »» %s' )
		:format( row.lineno, row.raw )

	return mw.html.create( 'p' ):wikitext( rowString )
end

--[[Doc
@method DefaultHandlers finalize
@description Applied after the rows have been parsed.
Used to supply extra containers to be added to the
main wrapper.
@return Multiple values that will be appended to the
main wrapper (including the main structure).
]]
function DefaultHandlers:finalize( mainStructure, globalData )
	return tostring( mainStructure )
end

--[[Doc
@exports The `DefaultHandlers` class.
]]
return DefaultHandlers
-- </pre>
