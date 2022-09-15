-- <pre>
local normalize = {
	['dm'] = 'dm', ['manga'] = 'dm', ['duelmonsters'] = 'dm',
	['r']  = 'r',
	['gx'] = 'gx',
	['5d'] = '5d', ['5ds']   = '5d',
	['zx'] = 'zx', ['zexal'] = 'zx',
	['dz'] = 'dz', ['dteam'] = 'dz', ['dteamzexal']  = 'dz',
	['av'] = 'av', ['arcv']  = 'av',
	['dy'] = 'dy',                   ['duelistyuya'] = 'dy',
--	['vr']   = 'vr', ['vrains'] = 'vr',
	['os'] = 'os', ['ocg']   = 'os', ['structures'] = 'os',
	['sv'] = 'sv',
	['lp'] = 'lp',
	['gr'] = 'gr',
}

local main = {
	['dm'] = {
		abbr  = 'DM',
		page  = 'Yu-Gi-Oh! (manga)',
		label = 'Yu-Gi-Oh!',
	},
	['r'] = {
		abbr  = 'R',
		page  = 'Yu-Gi-Oh! R',
		label = 'Yu-Gi-Oh! R',
	},
	['gx'] = {
		abbr  = 'GX',
		page  = 'Yu-Gi-Oh! GX (manga)',
		label = 'Yu-Gi-Oh! GX',
	},
	['5d'] = {
		abbr  = '5D',
		page  = "Yu-Gi-Oh! 5D's (manga)",
		label = "Yu-Gi-Oh! 5D's",
	},
	['zx'] = {
		abbr  = 'ZX',
		page  = 'Yu-Gi-Oh! ZEXAL (manga)',
		label = 'Yu-Gi-Oh! ZEXAL',
	},
	['dz'] = {
		abbr  = 'DZ',
		page  = 'Yu-Gi-Oh! D Team ZEXAL',
		label = 'Yu-Gi-Oh! D Team ZEXAL',
	},
	['av'] = {
		abbr  = 'AV',
		page  = 'Yu-Gi-Oh! ARC-V (manga)',
		label = 'Yu-Gi-Oh! ARC-V',
	},
	['dy'] = {
		abbr  = 'DY',
		page  = 'Yu-Gi-Oh! ARC-V The Strongest Duelist Yuya!!',
		label = 'Yu-Gi-Oh! ARC-V The Strongest Duelist Yuya!!',
	},
	['os'] = {
		abbr  = 'OS',
		page  = 'Yu-Gi-Oh! OCG Structures',
		label = 'Yu-Gi-Oh! OCG Structures',
	},
	['sv'] = {
		abbr  = 'SV',
		page  = 'Yu-Gi-Oh! SEVENS Luke! Explosive Supremacy Legend!!',
		label = 'Yu-Gi-Oh! SEVENS Luke! Explosive Supremacy Legend!!',
	},
	['lp'] = {
		abbr  = 'LP',
		page  = 'Yu-Gi-Oh! Rush Duel LP',
		label = 'Yu-Gi-Oh! Rush Duel LP',
	},
	['gr'] = {
		abbr  = 'GR',
		page  = 'Yu-Gi-Oh! GO RUSH!! (manga)',
		label = 'Yu-Gi-Oh! GO RUSH!!',
	},
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
