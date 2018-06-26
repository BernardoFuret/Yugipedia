/**
 * Null edit button.
 * @author Becasita
 * @contact [[User talk:Becasita]]
 */
( function _nullEditButton( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var $content = $( '#bodyContent' );

	var $button = $( '<li>', {
		id: 'ca-null',
		html: $( '<a>', {
			href: '#',
			title: 'Null edit this page',
			text: 'Null edit'
		} )
	} );

	var disabledClass = 'is-disabled';

	var $spinner = $( '<span>', {
		id: 'null-edit-spinner',
		'class': 'smw-overlay-spinner large inline'
	} );

	// Add button:
	if ( $( '#ca-view' ).hasClass( 'selected' ) ) {
		$( '#p-cactions' )
			.removeClass( 'emptyPortlet' )
			.find( '.menu' )
				.find( 'ul' )
					.append( $button );
	}

	// Click event:
	$button.click( function( e ) {
		e.preventDefault();

		var notifyOptions = {
			setType: function( type ) {
				this.type = type;
				return this;
			},
			title: 'Null edit',
			tag: 'null_edit',
			autoHide: !mw.config.get( 'debug' )
		};

		var notifyOptions = function( type ) {
			//return type && (options.type = type), options;
			return {
				title: 'Null edit',
				tag: 'null_edit',
				type: type,
				autoHide: !mw.config.get( 'debug' )
			}
		};
		
		mw.notify( 'Null editing...', notifyOptions( 'progress' ) );

		$content
			.addClass( disabledClass )
			.parent()
				.prepend( $spinner );			

		new mw.Api()
			.post( {
				action: 'edit',
				title: mw.config.get( 'wgPageName' ),
				token: mw.user.tokens.get( 'editToken' ),
				summary: 'Something bad happened! This was supposed to be a null edit!',
				prependtext: ''
			} )
			.done( function() {
				$content.load( window.location.href + ' #bodyContent > *', function( response, status, jqXHR ) {
					if ( jqXHR.status !== 200 ) {
						throw new Error( 'Error loading content after successful null edit!' );
					}

					// Cleanup page appearance:
					$content.removeClass( disabledClass );
					$spinner.remove();
					mw.notify( 'Null edit success!', notifyOptions( 'success' ) );
				} );
			} )
			.fail( function() {
				// Cleanup page appearance:
				$content.removeClass( disabledClass );
				$spinner.remove();
				mw.notify( 'Null edit fail!', notifyOptions( 'fail' ) );
				mw.log( arguments ); // TODO
			} )
			.always( function() {
				mw.log( '[Gadget] NullEditButton - Null edit concluded.' );
			} );
	} );

	// Log:
	console.log( '[Gadget] NullEditButton last updated at', LAST_LOG );
	
} )( window, window.jQuery, window.mediaWiki, window.console );