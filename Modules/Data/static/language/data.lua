-- <pre>
local normalize = {
	['EN'] = 'en',
	['NA'] = 'en', ['EU'] = 'en',
	['AU'] = 'en', ['OC'] = 'en',
	['FR'] = 'fr', ['FC'] = 'fr',
	['DE'] = 'de',
	['IT'] = 'it',
	['PT'] = 'pt',
	['SP'] = 'es',
	['JP'] = 'ja', ['JA'] = 'ja',
	['AE'] = 'en',
	['TC'] = 'zh',
	['KR'] = 'ko',
}

local main = {
	['en'] = { index = 'en', full = 'English'    },
	['fr'] = { index = 'fr', full = 'French'     },
	['de'] = { index = 'de', full = 'German'     },
	['it'] = { index = 'it', full = 'Italian'    },
	['pt'] = { index = 'pt', full = 'Portuguese' },
	['es'] = { index = 'es', full = 'Spanish'    },
	['ja'] = { index = 'ja', full = 'Japanese'   },
	['zh'] = { index = 'zh', full = 'Chinese'    },
	['ko'] = { index = 'ko', full = 'Korean'     },
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
