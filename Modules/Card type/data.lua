--  Data for [[Module:Card type]].
--  Contains three tables:
--  --  For FAQ card types;
--  --  For abilities;
--  --  For monster card types;
local FAQtypes = {
    ['character']      = 'Character Card',
    ['command']        = 'Command Card',
    ['counter']        = 'Counter',    --  Not really an FAQ card type, but works here.
    ['non-game']       = 'Non-game card',
    ['skill']          = 'Skill Card',
    ['strategy']       = 'Strategy Card',
    ['ticket']         = 'Ticket Card',
    ['tip']            = 'Tip Card',
	['card checklist'] = 'Card Checklist',
};

local abilities = {
    ['flip']    = 'Flip',
    ['gemini']  = 'Gemini',
    ['spirit']  = 'Spirit',
    ['toon']    = 'Toon',
    ['union']   = 'Union' 
};

local monsterCardTypes = {
    ['fusion']      = 'Fusion',
    ['link']        = 'Link',
    ['ritual']      = 'Ritual',
    ['synchro']     = 'Synchro',
    ['xyz']         = 'Xyz',
    ['maximum']     = 'Maximum'
};

return {
    ['FAQtypes']         = FAQtypes,
    ['abilities']        = abilities,
    ['monsterCardTypes'] = monsterCardTypes
}
