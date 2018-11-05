/**
 * Null edit button.
 * @author Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetNullEditButton( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var $content = $( '#bodyContent' );

	function notify( message, type ) {
		return mw.notify( message, {
			title: 'Null edit',
			tag: 'null_edit',
			type: type,
			autoHide: !mw.config.get( 'debug' )
		} );
	}

	var NullEditButton = {
		config: $.extend( mw.config.get( [ 'wgPageName' ] ), {
			token: mw.user.tokens.get( 'editToken' )
		} ),

		disabledClass: 'is-disabled',

		$button: $( '<li>', {
			id: 'ca-null',
			html: $( '<a>', {
				href: '#',
				title: 'Null edit this page',
				text: 'Null edit'
			} ),
			click: function( e ) {
				e.preventDefault();

				// Wait fot the notifiy module to load:
				mw.loader.using( 'mediawiki.notify' ).then( function() {
					notify( 'Waiting for mediawiki.api module to load.', 'fail' );
				} );
			}
		} ),

		$spinner: $( '<span>', {
			id: 'null-edit-spinner',
			'class': 'smw-overlay-spinner large inline'
		} ),

		loadContent: function() {
			$content.load( window.location.href + ' #bodyContent > *', function( response, status, jqXHR ) {
				if ( jqXHR.status !== 200 ) {
					throw new Error( 'Error loading content after successful null edit!' );
				}

				// Cleanup page appearance:
				$content.removeClass( NullEditButton.disabledClass );
				NullEditButton.$spinner.remove();
				mw.hook( 'wikipage.content' ).fire( $content );
				notify( 'Null edit success!', 'success' );
			} );
		},

		fail: function() {
			// Cleanup page appearance:
			$content.removeClass( NullEditButton.disabledClass );
			NullEditButton.$spinner.remove();
			notify( 'Null edit fail!', 'fail' );
			mw.log( '[Gadget] NullEditButton - Null edit fail.', arguments );
		},

		nullEdit: function( e ) {
			e.preventDefault();

			notify( 'Null editing...', 'progress' );

			$content
				.addClass( NullEditButton.disabledClass )
				.parent()
					.prepend( NullEditButton.$spinner )
			;

			new mw.Api()
				.post( {
					action: 'edit',
					title: NullEditButton.config.wgPageName,
					token: NullEditButton.config.token,
					summary: 'Something bad happened! This was supposed to be a null edit!',
					prependtext: ''
				} )
				.done( NullEditButton.loadContent )
				.fail( NullEditButton.fail )
			;
		},

		init: function() {
			if ( $( '#ca-view' ).hasClass( 'selected' ) ) {
				$( '#p-cactions' )
					.removeClass( 'emptyPortlet' )
					.find( '.menu' )
						.find( 'ul' )
							.append( NullEditButton.$button )
				;

				// Wait for the mw API module to load, just to be sure nothing breaks:
				mw.loader.using( 'mediawiki.api' ).done( function() {
					mw.log( '[Gadget] NullEditButton - mediawiki.api loaded.' );
					NullEditButton.$button
						.off( 'click' ) // Remove fallback click.
						.click( NullEditButton.nullEdit )
					;
				} );
			}
		}
	};

	$( NullEditButton.init );

	console.log( '[Gadget] NullEditButton last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
