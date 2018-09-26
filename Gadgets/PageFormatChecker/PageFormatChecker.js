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

	var $textBox = $( '#wpTextbox1' );

	// <pre>
	var PageFormatChecker = {
		PRELOADS: {
			'Generic': '* ',

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
				'<gallery heights="175px">',
				'Image.png  | Japanese',
				'Image.png  | International',
				'</gallery>',
				'|}',
			].join( '\n' ),
		},

		config: function() {
			this.config = $.extend(
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
		},

		checkSubmit: function( preload ) {
			$( '#wpSave, #wpPreview' ).mousedown( function() {
				$textBox.val( $textBox.val()
					.replace( /{{Navigation2}}/i, '{{Navigation|mode=nonGame}}' )
					.replace( /{{Navigation3}}/i, '{{Navigation|mode=otherGame}}' )
				);
			} );

			$( 'form[name=editform]' ).submit( function(e) {
				if ( // Kinda dirty...
					$textBox.val().replace( /{{Navigation.*?}}/i, '' ).trim()
					===
					preload.replace( /{{Navigation.*?}}/i, '' ).trim()
				) {
					window.alert( 'You have not made any changes to the page.' );

					return false;
				}
			} );
		},

		checkTalkHeader: function() {
			return (
				// Any talk page:
				PageFormatChecker.config.wgNamespaceNumber % 2
				&&
				// Except user talk pages:
				PageFormatChecker.config.wgNamespaceNumber !== 3
				&&
				// Except when editing sections:
				!PageFormatChecker.config.section
				&&
				// Except when already submitting: 
				PageFormatChecker.config.action !== 'submit'
			);
		},

		/**
		 * Add Template:Talkheader if it's not there. Fix it if it is.
		 */
		addTalkheader: function() {
			var vText = $textBox.val().replace( /{{[Tt]alkheader/, '{{Talk header' );
			if ( !vText.match( '{{Talk header' ) && !vText.match( '{{Delete' ) ) {
				$textBox.val( '{{Talk header}}\n\n' + vText );
			} else {
				$textBox.val( vText );
			}
		},

		checkNavigation: function() {
			var trimmedCanonicalNamespace = PageFormatChecker.config.wgCanonicalNamespace
				.replace( 'Card_', '' )
			;
			var namespaces = [
				'Gallery',
				'Errata',
				'Tips',
				'Appearances',
				'Trivia',
				'Lores',
				'Artworks',
				'Names',
				'Sets'
			];

			return (
				(
					// For Card_Rulings namespace, except "group rulings" pages:
					(
						trimmedCanonicalNamespace === 'Rulings'
						&&
						!~$textBox.val().indexOf( '[[Category:Group Rulings' )
					)
					||
					// For Card_$$ namespace, where $$ belongs to `namespaces`:
					~namespaces.indexOf( trimmedCanonicalNamespace )
				)
				&&
				(
					// Except when editing sections:
					!PageFormatChecker.config.section
					&&
					// Except when already submitting: 
					PageFormatChecker.config.action !== 'submit'
				)
			);
		},

		/**
		 * Add Template:Navigation if it's not there. Fix it if it is.
		 */
		addNavigation: function() {
			var vText = $textBox.val()
				.replace( '{{navigation', '{{Navigation' )
				.replace( '{{Navigation2}', '{{Navigation|mode=nonGame}' )
			;

			if ( !vText.match('{{Navigation' ) && !vText.match( '{{Delete' ) ) {
				$textBox.val( '{{Navigation}}\n\n' + vText );
			} else {
				$textBox.val( vText );
			}
		},

		checkPreloads: function() {
			var $editId = $( '#ca-edit' );

			return (
				PageFormatChecker.config.redlink
				||
				(
					$editId.hasClass( 'selected' )
					&&
					$editId.text() === 'Create'
				)
			);
		},

		getPreload: function() {
			var wgCanonicalNamespace = PageFormatChecker.config.wgCanonicalNamespace;

			switch ( wgCanonicalNamespace ) {
				case 'Card_Tips':
				case 'Card_Trivia':
				case 'Card_Names':
					return PageFormatChecker.PRELOADS[ 'Generic' ];
				case 'Card_Gallery':
				case 'Card_Appearances':
				case 'Card_Errata':
				case 'Card_Artworks':
					return PageFormatChecker.PRELOADS[ wgCanonicalNamespace ];
			}

			return null;
		},

		/**
		 * Add a preload, depending on the namespace, during page creation.
		 */
		addPreload: function() {
			var text = PageFormatChecker.getPreload();

			if ( text ) {
				text = '{{Navigation}}\n\n' + text;
				$textBox.val( text );

				PageFormatChecker.checkSubmit( text );
			}
		},

		/**
		 * Add missing preload to [[MediaWiki:Createbox-exists]].
		 * Using js since there doesn't seem to be a "getURL" option in the wikia magic words.
		 * TODO: check if stil needed.
		 */
		fixPreload: function() {
			/*if (mAction === 'create' && $('[name="preload"]').val() === '') {
				$('[name="preload"]').val(mw.util.getParamValue('preload'));
			}*/
		},

		init: function() {
			mw.loader.using( 'mediawiki.util' ).then( function() {
				PageFormatChecker.config(); // Inits config.

				if ( PageFormatChecker.checkTalkHeader() ) {
					PageFormatChecker.addTalkheader();
				}

				if ( PageFormatChecker.checkNavigation() ) {
					PageFormatChecker.addNavigation();
				}

				if ( PageFormatChecker.checkPreloads() ) {
					PageFormatChecker.addPreload();
				}

				//PageFormatChecker.fixPreload(); // TODO: Check later.
			} );
		}

	};

	mw.hook( 'wikipage.editform' ).add( PageFormatChecker.init );
	// </pre>

	console.log( '[Gadget] PageFormatChecker last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );