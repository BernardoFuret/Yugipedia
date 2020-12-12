/**
 * Alerts the user they need to sign.
 * Original idea by User:Falzar.
 * Completely re-desgined by Becasita.
 * @author Falzar, Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetSigChecker( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var SIG = '~~\~~';

	var config = mw.config.get( [
		'wgNamespaceNumber',
		'wgPageName'
	] );

	var $textBox = $( '#wpTextbox1' );

	function mustSign() {
		return (
			(
				// Forum page:
				config.wgNamespaceNumber === 110
				||
				// Any talk page:
				config.wgNamespaceNumber % 2
			)
			&&
			!(
				/\/archive|(\?|&)undo(after)?=/gi.test( window.location.href )
				||
				config.wgPageName === 'Forum:Reasons_why_cards_are_Forbidden/Limited'
			)
		);
	}

	function validate( initialContent ) {
		var state = {
			content: initialContent,
			alerts: 0
		};

		return function onMousedown( event ) {
			return !!( // Go through if:
				// Too many alerts skipped:
				state.alerts++ > 2
				||
				// Minor edit:
				$( '#wpMinoredit' ).is( ':checked' )
				||
				// Archiving or moving something:
				/(archiv|mov)(e|ing)/i.test( $( '#wpSummary' ).val() )
				||
				// Page for deletion:
				/\{\{\s*[Dd]elete/.test( $textBox.val() )
				||
				// Whitespace and/or capitalization changes:
				(
					state.content.replace( /\s/g, '' ).toLowerCase()
					===
					$textBox.val().replace( /\s/g, '' ).toLowerCase()
				)
				||
				// Strip any escaped four tildes (by nowiki or HTML comments).
				// And check if we still match four tildes.
				// (this is a hack; avoid parsing HTML with RegExp!)
				// If true, then the user signed:
				new RegExp( SIG, 'g' ).test(
					$textBox.val().replace(
						/<now\iki>[\s\S]*?~~\~~[\s\S]*?<\/nowiki>|<!--[\s\S]*?~~\~~[\s\S]*?-->/g,
						''
					)
				)
				||
				// User was notified about signing but dismissed:
				// ("OK" is "I will sign"; "Cancel" is for "dismiss".)
				!window.confirm(
					'Please sign your posts by adding 4 tildes (' + SIG + ') to the end of your posts.'
				)
			); // Else keep current page.
		};
	} 

	function init() {
		// This should ensure it only captures the content
		// after it has been updated by other gadgets.
		queueMicrotask( function() {
			var initialContent = $textBox.val();
			
			if ( mustSign() ) {
				$( '#wpSave, #wpPreview, #wpDiff, .wikiEditor-ui-tabs > *' )
					.mousedown( validate( initialContent ) )
				;
			}
		} );
	}

	mw.hook( 'wikipage.editform' ).add( init );

	console.log( '[Gadget] SigChecker last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
