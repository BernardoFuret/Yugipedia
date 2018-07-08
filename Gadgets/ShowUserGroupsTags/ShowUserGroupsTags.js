/**
 * Displays the user groups on the main user and main user talk pages.
 * @author Becasita
 * @contact [[User talk:Becasita]]
 */
( function _showUserGroupsTags( $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	// Get config vars:
	var config = mw.config.get( [
		'wgNamespaceNumber',
		'wgPageName'
	] );

	// Check if on the "User" or "User talk" namespace:
	if ( config.wgNamespaceNumber === 2 || config.wgNamespaceNumber === 3 ) {

		// Make an api call for user groups:
		mw.loader.using( 'mediawiki.api' ).done( function() {
			new mw.Api()
				.get( {
					action: 'query',
					list: 'users',
					ususers: config.wgPageName.replace( /^user((_| )talk)?:/im, '' ),
					usprop: 'groups'
				} )
				.done( function( data ) {
					// Valid groups to display:
					var validGroups = {
						bureaucrat: 'BCRAT',
						sysop: 'ADMIN'
					};

					try {
						// Iterate over all groups:
						data.query.users[ 0 ].groups.forEach( function( group, index ) {
							// Check if it's worth showing a tag for this group:
							var validGroup = validGroups[ group ];

							if ( validGroup ) {
								$( '#firstHeading' ).append(
									$( '<span>', {
										id: 'user-group-tag-' + validGroup,
										'class': 'user-group-tag',
										text: validGroup
									} )
								);
							}
						} );
					} catch ( e ) {
						console.warn( 'Caught error @_showUserGroupsTags():', e );
					}
				} )
				.fail( console.error )
			;
		} );

	}

	// Log:
	console.log( '[Gadget] ShowUserGroupsTags last updated at', LAST_LOG );

} )( window.jQuery, window.mediaWiki, window.console );
