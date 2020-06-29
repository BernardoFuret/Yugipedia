-- <pre>
return {
	region = {
		required = true,
		default = 'EN',
	},

	header = {},

	rarities = {
		default = '',
	},

	[ 'print' ] = {
		allowEmpty = true,
	},

	qty = {},

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
