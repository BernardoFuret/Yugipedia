-- <pre>
-- TODO: allow passing handlers here (problem: define self and data access)
return {
	region = {
		required = true,
		default = 'EN',
	},

	header = {},

	rarities = {
		default = '',
	},

	print = {
		allowEmpty = true,
	},

	qty = {},

	description = {},

	[ '$description' ] = {},

	options = {
		default = '',
--		handler = require( 'Module:CardCollection/handlers' ).utils.parseOptions,
	},

	columns = {},

	[ 1 ] = {
		required = true,
		default = '',
--		options = {
--			[ 'printed-name' ] = {},
--			[ 'description' ] = {
--				allowEmpty = true,
--			},
--		}
	},
}
-- </pre>
