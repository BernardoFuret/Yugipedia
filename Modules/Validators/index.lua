-- <pre>
local endpoints = mw.loadData( 'Module:Validators/Endpoints' )

return setmetatable( {}, {
	__index = function( self, key )
		local subModuleName = endpoints[ key ]

		if not subModuleName then
			-- Let it explode on the calling code, just like it would
			-- if all of the functions were explicitly declared.
			return nil
		else
			rawset( self, key, require( subModuleName ) )

			return rawget( self, key )
		end
	end,
} )
-- </pre>
