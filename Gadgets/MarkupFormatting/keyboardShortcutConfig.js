/**
 * Add the following to your common.js to config the keyboard shortcut.
 */
mw.loader.using( 'ext.gadget.MarkupFormatting' ).then( function() {
	window.MARKUP_FORMATTING_ONKEYDOWN_SET( function( e ) {
		return /* Predicate indicating the keyboard pressed keys. */;
	} );
} );