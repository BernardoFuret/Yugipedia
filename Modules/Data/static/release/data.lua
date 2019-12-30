-- <pre>
local normalize = {
	['op'] = 'op', ['proxy']   = 'op',
	['gc'] = 'gc', ['giant']   = 'gc',
	['ct'] = 'ct', ['topper']  = 'ct',
	['rp'] = 'rp', ['replica'] = 'rp',
}

local main = {
	['op'] = { abbr = 'OP', full = 'Official Proxy' },
	['gc'] = { abbr = 'GC', full = 'Giant Card'     },
	['ct'] = { abbr = 'CT', full = 'Case Topper'    },
	['rp'] = { abbr = 'RP', full = 'Replica'        },
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
