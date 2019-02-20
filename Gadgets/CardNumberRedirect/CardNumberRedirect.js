/**
 * Redirects card numbers to their respective pages.
 * @author [[User:Becasita]]
 */
( function _gadgetCardNumberRedirect( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~'; // <pre>

	var config = mw.config.get( [
		'wgNamespaceNumber',
		'wgPageName'
	] );

	var api;

	function requestContent() {
		return api.get( {
			action: 'query',
			redirects: true,
			prop: 'revisions',
			rvprop: 'content',
			format: 'json',
			formatversion: 2,
			titles: config.wgPageName
		} );
	}

	function getRedirectMap( data ) {
		var content = ( function() {
			try {
				return data.query.pages[ 0 ].revisions[ 0 ].content;
			} catch ( e ) {
				console.warn( '[Gadget][CardNumberRedirect] - Could not fetch content.' );

				throw e;
			}
		} )();

		var regex = /^[ \t]*([\d\-\w]{5,10})[ \t]*;[ \t]*(.*?)(;|\/\/|$)/gm;

		var redirectsMap = {};

		content.replace( regex, function( match, $1, $2 ) {
			redirectsMap[ $1.trim() ] = $2.trim();
		} );

		return redirectsMap;
	}

	function redirect( number, name ) {
		return api
			.postWithToken( 'csrf', {
				action: 'edit',
				title: number,
				createonly: true,
				text: '#REDIRECT [[' + name + ']] {{R from card number}}',
				summary: 'Creating redirects: Redirected page to [[' + name + ']].',
				bot: true,
			} )
			.done( function() {
				console.log( '[Gadget][CardNumberRedirect] - redirected', number, 'to', name );
			} )
			.fail(
				console.error.bind(
					console,
					'[Gadget][CardNumberRedirect] - Error creating redirect to',
					name
				)
			)
		;
	}

	function redirectAll( data ) {
		var redirectMap = getRedirectMap( data );

		var chain = Promise.resolve();

		for ( var cardNumber in redirectMap ) {
			if ( redirectMap.hasOwnProperty( cardNumber ) ) {
				( function( number, name ) {
					chain = chain.then( function() {
						return new Promise( function( resolve ) {
							return redirect( number, name ).always( resolve );
						} );
					} );

					chain = chain.then( function() {
						return new Promise( function( resolve ) {
							return setTimeout( function() {
								resolve();
							}, window.CARD_NUMBER_REDIRECT_DELAY || 500 );
						} );
					} );
				} )( cardNumber, redirectMap[ cardNumber ] );
			}
		}


		chain.then( function() {
			console.log( '[Gadget][CardNumberRedirect] - All done!' );

			return mw.notify( 'All done!', {
				title: 'Card number redirect',
				tag: 'card_number_redirect',
			} );
		} );
	}

	function onRedirectCardNumbersClick( e ) {
		e.preventDefault();

		requestContent()
			.done( redirectAll )
			.fail(
				console.error.bind(
					console,
					'[Gadget][CardNumberRedirect] - Error:'
				)
			)
		;
	}

	function init() {
		if ( config.wgNamespaceNumber === 3006 ) {
			var $button = $( '<li>', {
				id: 'ca-redirect',
				'class': 'collapsible',
				html: $( '<a>', {
					href: '#',
					title: 'Create card number redirects.',
					text: 'Redirect'
				} ),
				click: function( e ) {
					e.preventDefault();

					console.error( '[Gadget][CardNumberRedirect] - Waiting for mediawiki.api module to load.' );
				},
			} );

			$( '#p-cactions' )
				.removeClass( 'emptyPortlet' )
				.find( '.menu' )
					.find( 'ul' )
						.append( $button )
			;

			mw.loader.using( [ 'mediawiki.api', 'mediawiki.notify' ] ).done( function() {
				api = new mw.Api();

				$button
					.off( 'click' ) // Remove fallback click.
					.click( onRedirectCardNumbersClick )
				;
			} );
		}
	}

	$( init ); // </pre>

	console.log( '[Gadget] CardNumberRedirect last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
