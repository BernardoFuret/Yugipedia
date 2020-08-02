-- <pre>
local normalize = {
	['tcg'] = 'tcg', ['trading'] = 'tcg',

	['EN']  = 'tcg',
	['NA']  = 'tcg', ['EU'] = 'tcg',
	['AU']  = 'tcg', ['OC'] = 'tcg',
	['FR']  = 'tcg', ['FC'] = 'tcg',
	['DE']  = 'tcg',
	['IT']  = 'tcg',
	['PT']  = 'tcg',
	['SP']  = 'tcg',

	['ocg'] = 'ocg', ['official'] = 'ocg',

	['JP']  = 'ocg', ['JA'] = 'ocg',
	['AE']  = 'ocg',
	['SC']  = 'ocg', ['TC'] = 'ocg',
	['KR']  = 'ocg',
}

local main = {
	['tcg'] = { abbr = 'TCG', full = 'Yu-Gi-Oh! Trading Card Game'  },
	['ocg'] = { abbr = 'OCG', full = 'Yu-Gi-Oh! Official Card Game' },
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
