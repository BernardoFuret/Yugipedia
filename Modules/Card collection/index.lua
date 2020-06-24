-- <pre>
return setmetatable( {}, {
	__index = function( self, templateName )
		local loadedModule = require( 'Module:Card collection/modules/' .. templateName )

		rawset( self, templateName, loadedModule )

		return rawget( self, templateName )
	end,

	__call = function( self, templateName )
		return self[ templateName ]
	end,
} )
-- </pre>
