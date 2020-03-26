/**
 * Redirect to page from database ID.
 * Go to `https://yugipedia.com/wiki/Special:BlankPage?database_id=XXXX`,
 * where `XXXX` is the card's database ID.
 * @author Becasita
 * @contact [[User:Becasita]]
 */
( function _gadgetRedirectFromDatabaseId( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var config = mw.config.get( [
		'wgPageName',
		'wgServer',
		'wgArticlePath'
	] );

	var $textContainer = $( '#mw-content-text' );

	var api;

	function queryAskApi( id ) {
		return api.get( {
			action: 'ask',
			query: [ '[[Database ID::', ']]' ].join( id ),
			api_version: 3
		} );
	}

	function getCardFromDbId( response ) {
		return Object.keys( response.query.results[ 0 ] )[ 0 ];
	}

	function redirectPage( page ) {
		var url = [
			config.wgServer,
			config.wgArticlePath.replace( '$1', page )
		].join( '' );

		$textContainer.text( 'Redirecting to "' + page + '"...'  );

		window.location.replace( url );
	}

	function noPageFor( id ) {
		return function( err ) {
			$textContainer.text( 'No page found for database ID: ' + id  );

			console.warn(
				'[Gadget]', '[RedirectFromDatabaseId]',
				'No page found for database ID:', id,
				'\nOriginal error:', err
			);
		};
	}

	function init() {
		api = new mw.Api();

		var dbId = window.location.search.substring( 1 )
			.split( '&' ).find( function( e ) {
				return e.match( /^database_id/ );
			} )
			.split( '=' )[ 1 ]
		;

		$textContainer.text( 'Getting card from database ID: ' + dbId );

		if ( dbId ) {
			queryAskApi( dbId )
				.then( getCardFromDbId )
				.then( redirectPage, noPageFor( dbId ) )
				[ 'catch' ]( function( err1, err2 ) {
					$textContainer.text( 'Error getting card from database ID' );

					console.warn(
						'[Gadget]', '[RedirectFromDatabaseId]',
						'Error getting card from database ID',
						err1, err2
					);
				} )
			;
		} else {
			$textContainer.text( 'No database ID provided.' );
		}
	}

	if (
		config.wgPageName === 'Special:BlankPage'
		&&
		window.location.search.match( /\?database_id/ )
	) {
		mw.hook( 'wikipage.content' ).add( function() {
			mw.loader.using( 'mediawiki.api' ).then( init );
		} );
	}

	console.log( '[Gadget] RedirectFromDatabaseId last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
