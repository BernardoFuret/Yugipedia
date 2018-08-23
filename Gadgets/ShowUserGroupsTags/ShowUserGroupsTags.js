/**
 * Displays the user groups on the main user and main user talk pages.
 * @author Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetShowUserGroupsTags( $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var ShowUserGroupsTags = {
		GROUPS: {
			blocked: 'Blocked',
			bot: 'Bot',
			bureaucrat: 'Bcrat',
			mover: 'Mover',
			//sysadmin: '',
			sysop: 'Admin'
		},

		config: mw.config.get( [
			'wgNamespaceNumber',
			'wgTitle'
		] ),

		$container: $( '<div>', {
			id: 'user-group-tags'
		} ),

		addTag: function( group ) {
			ShowUserGroupsTags.$container.append(
				$( '<span>', {
					id: 'user-group-tag__' + group,
					'class': 'user-group-tag',
					text: ShowUserGroupsTags.GROUPS[ group ]
				} )
			);
		},

		addTags: function( data ) {
			( data.query.users[ 0 ].groups || [] ).forEach( function( group ) {
				if ( ShowUserGroupsTags.GROUPS[ group ] ) {
					ShowUserGroupsTags.addTag( group );
				}
			} );

			if ( data.query.users[ 0 ].blockexpiry ) {
				ShowUserGroupsTags.addTag( 'blocked' );
			}
		},

		fail: function() {
			mw.log( '[Gadget] ShowUserGroupsTags - Failed to get user groups.', arguments );
		},

		execute: function() {
			new mw.Api()
				.get( {
					action: 'query',
					list: 'users',
					ususers: ShowUserGroupsTags.config.wgTitle,
					usprop: [
						'groups',
						'blockinfo'
					].join( '|' )
				} )
				.done( ShowUserGroupsTags.addTags )
				.fail( ShowUserGroupsTags.fail )
			;
		},

		init: function() {
			if ( ~[ 2, 3 ].indexOf( ShowUserGroupsTags.config.wgNamespaceNumber ) ) {
				$( '#firstHeading' ).append( ShowUserGroupsTags.$container );

				mw.loader.using( 'mediawiki.api' ).done( ShowUserGroupsTags.execute );
			}
		}
	};

	$( ShowUserGroupsTags.init );

	console.log( '[Gadget] ShowUserGroupsTags last updated at', LAST_LOG );

} )( window.jQuery, window.mediaWiki, window.console );
