-- <pre>
return require( 'Module:Card collection/Parser' )( 'Set list' )

--[==[Test
p:test{
	[ 1 ] = [=[
		YZ01-JP001; Kachi Kochi Dragon; ; Reprint; 2
		YZ02-JP001; Number 50: Blackship of Corn; ; Reprint // @Volume::2
		YZ03-JP001; Number 22: Zombiestein; ; ; Not a numeric quantity // @Volume::3
		YZ04-JP001; Number 47: Nightmare Shark; UR, SR // @Volume::4
		YZ05-JP001; Number 72: Shogi Rook // description::Bold, Italics; @Volume::5
		YZ06-JP001; Number 52: Diamond Crab King // @Volume::6
		YZ07-JP001; Number 23: Lancelot, Dark Knight of the Underworld // @Volume::7
		YZ08-JP001; Number S39: Utopia the Lightning // printed-name::Super Shiny Utopia; @Volume::8; description::And sooner as UTOPIA
		YZ09-JP001; Gagaga Head; ; ; 2 // @Volume::9
		YZ??-JP???; Gagaga Body // description:: ; @Some notes::Here, the description is inputted as empty, preventing the default description and interpolation.
		YZ01-JP001;  // @Volume:: ; @Some notes::Here, the Volume is inputted as empty, preventing the default volume and interpolation.
		YZ01-JP001; ; ; ; 2 // @Some notes::No name, default rarities, default print, but quantity.
		          ; ; ; Reprint; 2 // @Some notes::No name, but still using printed-name.; printed-name::Some name
		          ; Gagaga Neck; ; Reprint // printed-name::; @Some notes::Empty printed-name
		SS04-ENA04; Winged Dragon, Guardian of the Fortress #1;; Speed Duel Debut // @Some notes::Test names with hash
	]=],
	[ 'region' ]   = 'JP',
	[ 'rarities' ] = 'UR',
	[ 'print' ]    = 'New',
	[ 'qty' ]      = '1',
	[ 'columns' ]  = '$Volume::[[Yu-Gi-Oh! ZEXAL Volume $1 promotional card|Volume $1]]; Volume::[[Yu-Gi-Oh! ZEXAL Volume 1 promotional card|Volume 1 (default)]]; Some notes;',
	[ 'description' ]  = 'Default desc', 
	[ '$description' ] = 'Bold: <b>$1</b>; Italics: <i>$2</i>',
}
--]==]
-- </pre>
