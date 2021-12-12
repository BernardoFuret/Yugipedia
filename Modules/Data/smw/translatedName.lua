-- <pre>
--[=[Doc
@module Data/getTranslatedName
@description Get the translated name of a card, set or character.
]=]

local DATA = require( 'Module:Data' )

--[[Doc
@description Gets the translated name of a card, set or character.
@parameter {string} pagename Name of the page (not a card name).
@parameter {Language} language
@return {string} Translated name.
]]
return function( pagename, language )
	if ( language.index == 'en' ) then
		return DATA.getName( pagename, language )
	end


	local askResult = mw.smw.ask{
		table.concat{ '[[', pagename, ']]' },
		table.concat{ '?Translated ', language.full, ' name=' },
		limit     = 1,
		mainlabel = '-'
	}

	return ( askResult and askResult[ 1 ] or {} )[ 1 ]
end
-- </pre>
