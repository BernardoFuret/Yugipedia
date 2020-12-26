-- <pre>
local normalize = {
	-- Shorts:
	['toei'] = 'toei', -- TODO: TOEI = Yu-Gi-Oh! (Toei anime) and Yu-Gi-Oh! The Movie
	['dm']   = 'dm', ['duelmonsters'] = 'dm',
	['gx']   = 'gx',
	['5d']   = '5d', ['5ds']    = '5d',
	['zx']   = 'zx', ['zexal']  = 'zx',
	['av']   = 'av', ['arcv']   = 'av',
	['vr']   = 'vr', ['vrains'] = 'vr',
	['sv']   = 'sv', ['sevens'] = 'sv',

	-- Movies:
	['mov']  = 'mov',  ['pyramidoflight'] = 'mov', ['moviepyramidoflight'] = 'mov',  ['pol']  = 'mov',
	['mov2'] = 'mov2', ['3dbondsbeyondtime'] = 'mov2', ['bondsbeyondtime'] = 'mov2', ['bbt']  = 'mov2',
	['mov3'] = 'mov3', ['darksideofdimensions'] = 'mov3',                            ['dsod'] = 'mov3',
}

local main = {
	-- Shorts:
	['toei'] = {
		abbr  = 'Toei',
		page  = 'Yu-Gi-Oh! (Toei anime)',
		label = 'Yu-Gi-Oh! (Toei)',
	},
	['dm'] = {
		abbr  = 'DM',
		page  = 'Yu-Gi-Oh! (anime)',
		label = 'Yu-Gi-Oh!',
	},
	['gx'] = {
		abbr  = 'GX',
		page  = 'Yu-Gi-Oh! GX',
		label = 'Yu-Gi-Oh! GX',
	},
	['5d'] = {
		abbr  = '5D',
		page  = "Yu-Gi-Oh! 5D's",
		label = "Yu-Gi-Oh! 5D's",
	},
	['zx'] = {
		abbr  = 'ZX',
		page  = 'Yu-Gi-Oh! ZEXAL',
		label = 'Yu-Gi-Oh! ZEXAL',
	},
	['av'] = {
		abbr  = 'AV',
		page  = 'Yu-Gi-Oh! ARC-V',
		label = 'Yu-Gi-Oh! ARC-V',
	},
	['vr'] = {
		abbr  = 'VR',
		page  = 'Yu-Gi-Oh! VRAINS',
		label = 'Yu-Gi-Oh! VRAINS',
	},
	['sv'] = {
		abbr  = 'SV',
		page  = 'Yu-Gi-Oh! SEVENS',
		label = 'Yu-Gi-Oh! SEVENS',
	},

	-- Movies:
	['mov'] = {
		abbr  = 'MOV',
		page  = 'Yu-Gi-Oh! The Movie: Pyramid of Light',
		label = 'Yu-Gi-Oh! The Movie: Pyramid of Light',
	},
	['mov2'] = {
		abbr  = 'MOV2',
		page  = 'Yu-Gi-Oh! 3D Bonds Beyond Time',
		label = 'Yu-Gi-Oh! 3D Bonds Beyond Time',
	},
	['mov3'] = {
		abbr  = 'MOV3',
		page  = 'Yu-Gi-Oh! The Dark Side of Dimensions',
		label = 'Yu-Gi-Oh! The Dark Side of Dimensions',
	},
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
