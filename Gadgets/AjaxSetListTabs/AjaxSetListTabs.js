/**
 * Dynamically load set lists on the set pages.
 * Idea by Deltaneos.
 * @author Becasita
 * @contact [[User:Becasita]]
 */
( function _gadgetAjaxSetListTabs( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var pagename = mw.config.get( 'wgPageName' );

	var api;

	function loadList( page ) {
		return api.get( {
			action: 'parse',
			title: pagename,
			text: [ '{{:', '}}' ].join( page ),
		} );
	}

	function parseData( data ) {
		return $.parseHTML( data.parse.text[ '*' ] );
	}

	function displayList( $el, resultHtml ) {
		var setList = $( resultHtml ).html();

		$el.html( setList );
	}

	function logException( e1, e2, e3 ) {
		console.warn( '[Gadget]', '[AjaxSetListTabs]', 'Error loading list -', e1, e2, e3 );
	}

	function loadLists() {
		$( '.set-list-ajax-tab' ).each( function( i, el ) {
			var $el = $( el );

			loadList( $el.data( 'page' ) )
				.then( parseData )
				.then( displayList.bind( this, $el ) )
				.catch( logException )
			;
		} );
	}

	function init() {
		api = new mw.Api();

		loadLists();
	}

	mw.hook( 'wikipage.content' ).add( function() {
		mw.loader.using( 'mediawiki.api' ).then( init );
	} );

	console.log( '[Gadget] AjaxSetListTabs last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
