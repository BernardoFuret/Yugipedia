-- <pre>
return {
	region = {
		required = true,
		default = 'EN',
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
