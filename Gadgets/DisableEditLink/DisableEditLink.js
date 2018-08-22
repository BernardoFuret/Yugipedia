/**
 * Disable page edit link (archive).
 * Only for "Forum", "User" and any talk page namesapces.
 *
 * Disables the edit tab/button on discussion pages to stop
 * people bumping old forum threads or editing archive pages.
 * Page can still be edited by going via the edit tab
 * on the history etc, or by typing the edit address manually.
 *
 * Original idea by User:Spang, from Uncyclopedia.
 * Completely re-desgined by Becasita.
 * @author Spang, Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetDisableEditLink( $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var DisableEditLink = {
		config: mw.config.get( [
			'wgNamespaceNumber',
			'wgUserGroups'
		] ),

		$button: $( '#ca-edit' ).find( 'a' ),

		archive: function() {
			DisableEditLink.$button
				.html( 'Archived' )
			;

			// For admins, apply only the above changes. For regular users:
			if ( !~DisableEditLink.config.wgUserGroups.indexOf( 'sysop' ) ) {
				DisableEditLink.$button
					.removeAttr( 'href' )
					.removeAttr( 'title' )
					.addClass( 'archived-edit-link' )
				;
			}

			// Also remove the small `[edit]` on MW titles:
			$( '.mw-editsection' ).remove();
		},

		isArchivablePage: function() {
			return (
				// For "Forum" and "User" namespaces:
				~[ 110, 2 ].indexOf( DisableEditLink.config.wgNamespaceNumber )
				||
				// For any talk page:
				DisableEditLink.config.wgNamespaceNumber % 2
			);
		},

		init: function() {
			if (
				// Indeed to be archived:
				$( '#archived-edit-link' ).length
				&&
				// Archivable page:
				DisableEditLink.isArchivablePage()
			) {
				DisableEditLink.archive();
			}
		}
	};

	$( DisableEditLink.init );

	console.log( '[Gadget] DisableEditLink last updated at', LAST_LOG );

} )( window.jQuery, window.mediaWiki, window.console );