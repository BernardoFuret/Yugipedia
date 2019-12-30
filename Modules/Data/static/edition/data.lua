-- <pre>
local normalize = {
	['1e'] = '1e', ['1'] = '1e', ['first']     = '1e', ['1st'] = '1e',
	['ue'] = 'ue', ['u'] = 'ue', ['unlimited'] = 'ue',
	['le'] = 'le', ['l'] = 'le', ['limited']   = 'le',
	['dt'] = 'dt',            ['duelterminal'] = 'dt',
}

local main = {
	['1e'] = { abbr = '1E', full = '1st Edition'       },
	['ue'] = { abbr = 'UE', full = 'Unlimited Edition' },
	['le'] = { abbr = 'LE', full = 'Limited Edition'   },
	['dt'] = { abbr = 'DT', full = 'Duel Terminal'     },
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
