-- <pre>
return {
	region = {
		required = true,
	},

	rarities = {
		default = '',
	},

	[ 'print' ] = {
		allowEmpty = true,
	},

	qty = {
		allowEmpty = true,
	},

	description = {},

	[ '$description' ] = {},

	options = {
		default = '',
	},

	columns = {},

	[ '$columns' ] = {},

	[ 1 ] = {
		required = true,
--		options = {
--			[ 'printed-name' ] = {},
--			[ 'description' ] = {
--				allowEmpty = true,
--			},
--		}
	},
}
-- </pre>
