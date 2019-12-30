-- <pre>
--[=[Doc
@module Data/getName
@description Get the localized name of a card, set or character.
@author [[User:Becasita]]
@contact [[User talk:Becasita]]
]=]

--[[Doc
@description Gets the localized name of a card, set or character.
@parameter {string} pagename Name of the page (not a card name).
@parameter {Language} language
@return {string} Localized name.
]]
return function( pagename, language )
	local askResult = mw.smw.ask{
		table.concat{ '[[', pagename, ']]' },
		table.concat{ '?', language.full, ' name=' },
		limit     = 1,
		mainlabel = '-'
	}

	return ( askResult and askResult[ 1 ] or {} )[ 1 ]
end
-- </pre>
