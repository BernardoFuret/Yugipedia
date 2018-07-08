/**
 * Top user contributions link.
 * @author Becasita
 * @contact [[User talk:Becasita]]
 */
( function _topUserContributionsLink( $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var config = mw.config.get( [
		'wgNamespaceNumber',
		'wgPageName'
	] );

	// Either copy the existing button or create one from scratch:
	var $button = ( $( '#t-contributions' ).length
		? (
			$( '#t-contributions' ).clone()
				.attr( 'id', 'ca-contribs' )
				.find( 'a' )
					.wrap( '<span>' )
					.text( 'Contributions' )
				.end()
		)
		: (
			$( '<li>', {
				id: 'ca-contribs',
				'class': 'collapsible',
				html: $( '<span>', {
					html: $( '<a>', {
						title: 'A list of contributions by this user',
						href: '/wiki/Special:Contributions/' + config.wgPageName.split( /:/ ).slice( 1 ).join( ':' ).split( /\// )[ 0 ],
						text: 'Contributions'
					} )
				} )
			} )
		)
	);

	if ( config.wgNamespaceNumber === 2 || config.wgNamespaceNumber === 3 ) {
		$( '#left-navigation' )
			.find( '#p-namespaces' )
				.children( 'ul' )
					.append( $button );
	}

	// Log:
	console.log( '[Gadget] TopUserContributionsLink last updated at', LAST_LOG );

} )( window.jQuery, window.mediaWiki, window.console );
