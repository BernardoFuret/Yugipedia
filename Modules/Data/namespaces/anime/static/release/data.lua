-- <pre>
local normalize = {
	['nc'] = 'nc', ['noncard'] = 'nc',
	['ca'] = 'ca', ['cardart'] = 'ca', ['art'] = 'ca',
}

local main = {
	['nc'] = { abbr = 'NC', full = 'Non-card' },
	['ca'] = { abbr = 'CA', full = 'Card art' },
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
