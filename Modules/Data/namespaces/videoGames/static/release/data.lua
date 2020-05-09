-- <pre>
local normalize = {
	['nc'] = 'nc', ['noncard'] = 'nc',
	['ca'] = 'ca', ['cardart'] = 'ca', ['art'] = 'ca',
	['artwork'] = 'artwork',
}

local main = {
	['nc']      = { abbr = 'NC',      full = 'Non-card'     },
	['ca']      = { abbr = 'CA',      full = 'Card artwork' },
	['artwork'] = { abbr = 'artwork', full = 'Card artwork' },
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
