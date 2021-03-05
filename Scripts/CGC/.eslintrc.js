module.exports = {

	env: {
		es2021: true,
		node: true,
	},

	extends: 'eslint:recommended',

	parserOptions: {
		ecmaVersion: 12,
	},

	rules: {
		'no-duplicate-imports': 'error',

		'prefer-const': 'error',

		eqeqeq: [ 'error', 'smart' ],

		'object-shorthand': [ 'error', 'always' ],

		'prefer-spread': 'error',
		'prefer-rest-params': 'error',

		'comma-dangle': [ 'error', 'always-multiline' ],
		semi: [ 'error', 'always' ],
		'no-extra-semi': [ 'error' ],

		quotes: [ 'error', 'single', { avoidEscape: true } ],
		'quote-props': [ 'error', 'as-needed' ],

		indent: [ 'error', 'tab', { SwitchCase: 1, ignoreComments: true } ],
		'no-trailing-spaces': 'error',
		'no-irregular-whitespace': 'error',
		'no-multi-spaces': [ 'error', { ignoreEOLComments: true } ],
		'space-in-parens': [ 'error', 'always' ],
		'computed-property-spacing': [ 'error', 'always' ],
		'object-curly-spacing': [ 'error', 'always' ],
		'array-bracket-spacing': [ 'error', 'always' ],
		'space-before-function-paren': [
			'error',
			{
				anonymous: 'always',
				named: 'never',
			},
		],
		'no-multiple-empty-lines': [ 'error', { max: 1, maxEOF: 1 } ],
		'eol-last': [ 'error', 'always' ],
	},

};
