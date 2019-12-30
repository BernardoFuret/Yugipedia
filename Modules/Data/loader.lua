-- <pre>
return function( namespace )
	-- TODO: only works for 1 level. Adjust if necessary.
	local thisModulePath = 'Module:Data'
		.. ( namespace
			and ( '/namespaces/' .. namespace )
			or ''
		)
		.. '/'

	local endpoints = mw.loadData( thisModulePath .. 'endpoints' )

	return setmetatable( {}, {
		__index = function( self, key ) -- only if it doesn't contain the key
			local subModuleName = endpoints[ key ]

			if not subModuleName then
				-- Let it explode on the calling code, just like it would
				-- if all of the functions were explicitly declared.
				return nil
			else
				rawset( self, key, require( thisModulePath .. subModuleName ) )

				return rawget( self, key )
			end
		end,

		__call = function( self, moduleName )
			return require( thisModulePath .. 'static/' .. moduleName .. '/data' ).main;
		end,
	} )
end
-- </pre>
