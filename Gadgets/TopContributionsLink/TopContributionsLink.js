/**
 * Adds a link to the user contributions, at the top of the page.
 * @author Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetTopContributionsLink( $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var TopContributionsLink = {
		config: mw.config.get( [
			'wgNamespaceNumber',
			'wgTitle'
		] ),

		getButton: function() {
			return $( '#t-contributions' ).clone()
				.attr( 'id', 'ca-contribs' )
				.find( 'a' )
					.wrap( '<span>' )
					.text( 'Contributions' )
				.end()
			;
		},

		newButton: function() {
			return $( '<li>', {
				id: 'ca-contribs',
				'class': 'collapsible',
				html: $( '<span>', {
					html: $( '<a>', {
						href: mw.util.getUrl(
							'Special:Contributions/' + TopContributionsLink.config.wgTitle.split( /\// )[ 0 ]
						),
						title: 'A list of contributions by this user',
						text: 'Contributions'
					} )
				} )
			} );
		},

		init: function() {
			if ( ~[ 2, 3 ].indexOf( TopContributionsLink.config.wgNamespaceNumber ) ) {
				$( '#left-navigation' )
					.find( '#p-namespaces' )
						.children( 'ul' )
							.append(
								TopContributionsLink[ $( '#t-contributions' ).length
									? 'getButton'
									: 'newButton'
								]()
							)
				;
			}
		}
	};

	$( TopContributionsLink.init );

	console.log( '[Gadget] TopContributionsLink last updated at', LAST_LOG );

} )( window.jQuery, window.mediaWiki, window.console );
