/**
 * Page format checker.
 * Original idea by User:Falzar.
 * Adapted to gadget by Becasita.
 * @author Falzar, Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetPageFormatChecker( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var config;

	var hasOwn = Object.prototype.hasOwnProperty;

	var $textBox = $( '#wpTextbox1' );

	// <pre>
	var PRELOADS = {
		'Card_Tips': '* ',

		'Card_Trivia': '* ',

		'Card_Gallery': [
			'{{Card gallery|region=EN|',
			'number; set; rarity; edition :: release // option::value',
			'}}',
			'',
			'{{Card gallery|region=JP|type=anime|',
			'series',
			'}}',
		].join( '\n' ),

		'Card_Errata': [
			'{{Errata table',
			'| lore0  = ',
			'| image0 = ',
			'| cap0   = [[Card Number]]<br />[[Set Name]]',
			'',
			'| lore1  = ',
			'| image1 = ',
			'| cap1   = [[Card Number]]<br />[[Set Name]]',
			'}}',
		].join( '\n' ),

		'Card_Appearances': [
			'* In [[Yu-Gi-Oh! VRAINS - Episode 000|episode 000]],',
			'[[character name]] plays this card',
			'against [[opponent name]].\n',
		].join( ' ' ),

		'Card_Artworks': [
			'* ',
			'',
			'{{ArtworkHeader|lang=jp}}',
			'<gallery heights="275px" widths="275px">',
			'Image.png  | Japanese',
			'Image.png  | International',
			'</gallery>',
			'|}',
		].join( '\n' ),

		'Set_Card_Galleries': [
			'{{Set page header}}',
			'',
			'{{Set gallery|',
			'number; name; rarity // option::value',
			'}}',
		].join( '\n' ),

		'Set_Card_Lists': [
			'{{Set page header}}',
			'',
			'{{Set list|region=|',
			'number; name; rarity // option::value',
			'}}',
		].join( '\n' ),
	};

	function cleanToCheck( text ) {
		return text.replace( /\s+/g, '' ).replace( /{{Navigation.*?}}/gi, '' );
	}

	function onSubmitCheck( preloadText ) {
		return function( e ) {
			if (
				cleanToCheck( $textBox.val() )
				===
				cleanToCheck( preloadText )
			) {
				window.alert( 'You have not made any changes to the page.' );

				return false;
			}
		};
	}

	/**
	 * Checks if a page is eligible for {{Talk header}}.
	 */
	function isTalkHeaderPage() {
		return (
			// Any talk page:
			config.wgNamespaceNumber % 2
			&&
			// Except user talk pages:
			config.wgNamespaceNumber !== 3
			&&
			// Except when editing sections:
			!config.section
			&&
			// Except when already submitting: 
			config.action !== 'submit'
		);
	}

	/**
	 * Adds {{Talk header}} if it isn't there. Fixes it if it is (assues it is
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

	/**
	 * Checks if a page is eligible for a preload.
	 */
	function isPreloadPage() {
		var $editId = $( '#ca-edit' );
		var isRedlink = config.redlink;
		var isCreating = (
			$editId.hasClass( 'selected' )
			&&
			$editId.text() === 'Create'
		);
		var hasNoContent = !$textBox.val().trim();

		return (
			hasOwn.call( PRELOADS, config.wgCanonicalNamespace )
			&&
			( isRedlink || isCreating )
			&&
			hasNoContent
		);
	}

	/**
	 * Adds the respective preload to the page.
	 */
	function handlePreload() {
		var newText = PRELOADS[ config.wgCanonicalNamespace ];

		$textBox.val( newText );

		$( 'form[name=editform]' ).submit( onSubmitCheck( newText ) );
	}

	/**
	 * Checks if the page is eligible for {{Navigation}}.
	 */
	function isNavigationPage() {
		var isNavigationNamespace = ~[
			'Card_Gallery',
			'Card_Rulings',
			'Card_Errata',
			'Card_Tips',
			'Card_Appearances',
			'Card_Trivia',
			'Card_Lores',
			'Card_Artworks',
		].indexOf( config.wgCanonicalNamespace );

		var isGroupRulingsPage = ~$textBox.val().indexOf( '[[Category:Group Rulings' );

		return (
			isNavigationNamespace
			&&
			!isGroupRulingsPage
			&&
			!config.section
			&&
			config.action !== 'submit'
		);
	}

	/**
	 * Adds {{Navigation}} if it isn't there. Fixes it if it is.
	 */
	function handleNavigation() {
		var pageText = $textBox.val()
			.replace( /^[ \t]*{{\s*Navigation2\s*}}/mi, '{{Navigation|mode=nonGame}}' )
			.replace( /^[ \t]*{{\s*Navigation3}\s*}/mi, '{{Navigation|mode=otherGame}}' )
		;

		if ( !/{{\s*Delete/.test( pageText ) && !/^[ \t]*{{Navigation/m.test( pageText ) ) {
			$textBox.val( '{{Navigation}}\n\n' + pageText );
		} else {
			$textBox.val( pageText );
		}
	}

	function init() {
		mw.loader.using( 'mediawiki.util' ).then( function() {
			config = $.extend(
				mw.config.get( [
					'wgCanonicalNamespace',
					'wgNamespaceNumber',
				] ),
				{
					action: mw.util.getParamValue( 'action' ),
					section: mw.util.getParamValue( 'section' ),
					redlink: mw.util.getParamValue( 'redlink' ),
				}
			);

			if ( isTalkHeaderPage() ) {
				handleTalkHeader();
			}

			if ( isPreloadPage() ) {
				handlePreload();
			}

			if ( isNavigationPage() ) {
				handleNavigation();
			}

			$( '#wpSave, #wpPreview' ).mousedown( function() {
				if ( isNavigationPage() ) {
					handleNavigation();
				}
			} );
		} );
	}

	mw.hook( 'wikipage.editform' ).add( init );
	// </pre>

	console.log( '[Gadget] PageFormatChecker last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );