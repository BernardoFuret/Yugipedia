// <pre>
/**
 * Add {{Talk header}} to non-user talk pages.
 * Original idea by User:Falzar as a page format checker.
 * Adapted to gadget by Becasita.
 * @author Falzar, Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetAddTalkHeader( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var config = mw.config.get( [
		'wgNamespaceNumber'
	] );

	var $textBox = $( '#wpTextbox1' );

	/**
	 * Checks if a page is eligible for {{Talk header}}.
	 */
	function checkIsEligibleTalkPage() {
		var sectionQueryParam = mw.util.getParamValue( 'section' );

		var actionQueryParam = mw.util.getParamValue( 'action' );

		return (
			// Any talk page:
			config.wgNamespaceNumber % 2
			&&
			// Except user talk pages:
			config.wgNamespaceNumber !== 3
			&&
			// Except when editing sections:
			!sectionQueryParam
			&&
			// Except when already submitting: 
			actionQueryParam !== 'submit'
		);
	}

	/**
	 * Adds {{Talk header}} if it isn't there. Fixes it if it is (assumes it is
	 * at the top of the page, not only because it should, but because there can
	 * be cases where it is wrapped inside `pre` tags or so. This is to avoid
	 * creating a scanner just for this task).
	 */
	function handleTalkHeader() {
		var pageText = $textBox.val().replace( /^[ \t]*{{\s*talk[ \t]*header/gmi, '{{Talk header' );

		if ( !/{{\s*Delete/.test( pageText ) && !/^[ \t]*{{Talk header/m.test( pageText ) ) {
			$textBox.val( '{{Talk header}}\n\n' + pageText );
		} else {
			$textBox.val( pageText );
		}
	}

	function init() {
		mw.loader.using( 'mediawiki.util' ).then( function() {
			if ( checkIsEligibleTalkPage() ) {
				handleTalkHeader();
			}
		} );
	}

	mw.hook( 'wikipage.editform' ).add( init );

	console.log( '[Gadget] AddTalkHeader last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
// </pre>
