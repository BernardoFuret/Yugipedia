-- <pre>
return setmetatable( {}, {
	__index = function( self, templateName )
		local loadedModule = require( 'Module:Card collection/modules/' .. templateName )

		return function( frame )
			return loadedModule:parse( frame, frame:getParent().args )
		end
	end,

	--[[__call = function( self, moduleName )
		return require( 'Module:Card collection/modules/' .. moduleName ) -- TODO: verify this if this module is to be used internally.
	end,]]
} )
-- </pre>
