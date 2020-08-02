-- <pre>
local normalize = {
	-- Worldwide English (EN):
	['en'] = 'en', ['ew'] = 'en', ['we'] = 'en', ['ww'] = 'en',
	['english'] = 'en', ['worldwide'] = 'en',
	['worldwideenglish'] = 'en', ['englishworldwide'] = 'en',

	-- North American English (NA):
	['na'] = 'na', ['american'] = 'na', ['americanenglish'] = 'na',

	-- European English (EU):
	['eu'] = 'eu', ['e'] = 'eu', ['european'] = 'eu', ['europeanenglish'] = 'eu',

	-- Australian/Oceanic English (AU/OC):
	['au'] = 'au', ['australian'] = 'au', ['australianenglish'] = 'au', ['a'] = 'au',  ['at'] = 'au',
	['oc'] = 'oc', ['oceanic']    = 'oc', ['oceanicenglish']    = 'oc',

	-- French (FR):
	['fr'] = 'fr', ['f'] = 'fr', ['french'] = 'fr',

	-- French Canadian (FC):
	['fc'] = 'fc', ['c'] = 'fc', ['canadian'] = 'fc', ['frenchcanadian'] = 'fc',

	-- German (DE):
	['de'] = 'de', ['g'] = 'de', ['german'] = 'de', ['d'] = 'de',

	-- Italian (IT):
	['it'] = 'it', ['i'] = 'it', ['italian'] = 'it',

	-- Portuguese (PT):
	['pt'] = 'pt', ['p'] = 'pt', ['portuguese'] = 'pt',

	-- Spanish (SP):
	['sp'] = 'sp', ['es'] = 'sp', ['s'] = 'sp', ['spanish'] = 'sp',

	-- Japanese (JP):
	['jp'] = 'jp', ['j'] = 'jp', ['jap'] = 'jp', ['japanese'] = 'jp',

	-- Japanese Asian (JA):
	['ja'] = 'ja', ['japaneseasian'] = 'ja', ['asianjapanese'] = 'ja',

	-- Asian English (AE):
	['ae'] = 'ae', ['asianenglish'] = 'ae', ['englishasian'] = 'ae',

	-- Simplified Chinese (SC):
	['sc'] = 'sc', ['simplifiedchinese'] = 'sc',

	-- Traditional Chinese (TC):
	['tc'] = 'tc', ['zh'] = 'tc', ['ch'] = 'tc', ['chinese'] = 'tc', ['traditionalchinese'] = 'tc',

	-- Korean (KR):
	['kr'] = 'kr', ['ko'] = 'kr', ['k'] = 'kr', ['korean'] = 'kr',
}

local main = {
	[ 'en' ] = { index = 'EN', full = 'Worldwide English'      },
	[ 'na' ] = { index = 'NA', full = 'North American English' },
	[ 'eu' ] = { index = 'EU', full = 'European English'       },
	[ 'au' ] = { index = 'AU', full = 'Australian English'     },
	[ 'oc' ] = { index = 'OC', full = 'Oceanic English'        },
	[ 'fr' ] = { index = 'FR', full = 'French'                 },
	[ 'fc' ] = { index = 'FC', full = 'French-Canadian'        },
	[ 'de' ] = { index = 'DE', full = 'German'                 },
	[ 'it' ] = { index = 'IT', full = 'Italian'                },
	[ 'pt' ] = { index = 'PT', full = 'Portuguese'             },
	[ 'sp' ] = { index = 'SP', full = 'Spanish'                },
	[ 'jp' ] = { index = 'JP', full = 'Japanese'               },
	[ 'ja' ] = { index = 'JA', full = 'Japanese-Asian'         },
	[ 'ae' ] = { index = 'AE', full = 'Asian-English'          },
	[ 'sc' ] = { index = 'SC', full = 'Simplified Chinese'     },
	[ 'tc' ] = { index = 'TC', full = 'Chinese'                },
	[ 'kr' ] = { index = 'KR', full = 'Korean'                 },
}

return {
	normalize = normalize,
	main = main,
}
-- </pre>
