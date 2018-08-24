/**
 * Alerts the user they need to sign.
 * Original idea by User:Falzar.
 * Completely re-desgined by Becasita.
 * @author Falzar, Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetSigChecker( window, document, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var SigChecker = {
		SIG: '~~\~~',

		config: mw.config.get( [
			'wgNamespaceNumber',
			'wgPageName'
		] ),

		$textBox: $( '#wpTextbox1' ),

		state: {
			alerts: 0,
			initialText: ''
		},

		mustSign: function() {
			return (
				(
					// Forum page:
					SigChecker.config.wgNamespaceNumber === 110
					||
					// Any talk page:
					SigChecker.config.wgNamespaceNumber % 2
				)
				&&
				!(
					mw.util.getParamValue( 'undo' )
					||
					/\/archive/gi.test( document.URL )
					||
					SigChecker.config.wgPageName === 'Forum:Reasons_why_cards_are_Forbidden/Limited'
				)
			);
		},

		saveState: function() {
			SigChecker.state.initialText = SigChecker.$textBox.val();
		},

		check: function() {
			if (
				// Minor edit:
				$( '#wpMinoredit' ).is( ':checked' )
				||
				// Archiving or moving something:
				/(archiv|mov)(e|ing)/i.test( $( '#wpSummary' ).val() )
				||
				// Page for deletion:
				/\{\{\s*[Dd]elete/.test( SigChecker.$textBox.val() )
				||
				// Whitespace and/or capitalization changes:
				(
					SigChecker.state.initialText.replace( /\s/g, '' ).toLowerCase()
					===
					SigChecker.$textBox.val().replace( /\s/g, '' ).toLowerCase()
				)
				||
				// Strip any escaped four tildes (by nowiki or HTML comments).
				// And check if we still match four tildes.
				// If true, then the user signed:
				new RegExp( SigChecker.SIG, 'g' ).test(
					SigChecker.$textBox.val().replace(
						/<\nowiki>[\s\S]*?~~\~~[\s\S]*?<\/nowiki>|<!--[\s\S]*?~~\~~[\s\S]*?-->/g,
						''
					)
				)
				||
				// Too many alerts skipped:
				SigChecker.state.alerts++ > 2
			) {
				return; // Go through.
			}

			// Else, alert the user they need to sign:
			// (false, because if the user clicks "OK",
			// then it's as if they want to sign. So, "OK" means
			// they want to get back (cancel, not confirm)).
			if (
				window.confirm(
					'Please sign your posts by adding 4 tildes (' + SigChecker.SIG + ') to the end of your posts.'
				)
			) {
				return; // Keep current page
			}

			$( this ).click(); // Go through (trigger click event);
		},

		init: function() {
			mw.loader.using( 'mediawiki.util' ).then( function() {
				if ( SigChecker.mustSign() ) {
					SigChecker.saveState();
					$( '#wpSave, #wpPreview, #wpDiff, .wikiEditor-ui-tabs > *' )
						.mousedown( SigChecker.check )
					;
				}
			} );
		}
	};

	mw.hook( 'wikipage.editform' ).add( SigChecker.init );

	console.log( '[Gadget] SigChecker last updated at', LAST_LOG );

} )( window, window.document, window.jQuery, window.mediaWiki, window.console );
