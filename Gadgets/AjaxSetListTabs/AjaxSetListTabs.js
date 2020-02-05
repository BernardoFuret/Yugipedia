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

	function getListData( setListPage ) {
		return api.get( {
			action: 'parse',
			title: pagename,
			text: [ '{{:', '}}' ].join( setListPage )
		} );
	}

	function parseData( data ) {
		return $( $.parseHTML( data.parse.text[ '*' ] ) ).html();
	}

	function SetListLoader( $container ) {
		this.$container = $container;
		this.defaultContent = $container.html();
		this.setListPage = $container.data( 'page' );
		this.remainingTimeoutTries = 2;
	}

	SetListLoader.prototype.makeError = function() {
		var self = this;

		var $errorContainer = $( '<div>', {
			'class': 'set-list-ajax-tab__error'
		} );

		var $pageLink = $( '<a>', {
			href: '/wiki/'.concat( this.setListPage ),
			text: this.setListPage
		} );

		var $tryAgainLink = $( '<a>', {
			href: '#',
			text: 'try again',
			click: function( e ) {
				e.preventDefault();

				self.$container.html( self.defaultContent );

				return self.load();
			}
		} );

		var $refreshLink = $( '<a>', {
			href: '#',
			text: 'refresh this page',
			click: function( e ) {
				e.preventDefault();

				window.location.reload();
			}
		} );

		return $errorContainer
			.append( 'Could not load ' )
			.append( $pageLink )
			.append( '. Please ' )
			.append( $tryAgainLink )
			.append( ' or ' )
			.append( $refreshLink )
			.append( '.' )
		;
	};

	SetListLoader.prototype.getHtml = function() {
		var self = this;

		return getListData( this.setListPage )
			.then( parseData )
			[ 'catch' ]( function( err1, err2 ) {
				console.warn(
					'[Gadget]', '[AjaxSetListTabs]',
					'Error loading', self.setListPage,
					'-', err1, err2
				);

				if ( err2.textStatus === 'timeout' && self.remainingTimeoutTries-- ) {
					return new Promise( function( resolve ) {
						window.setTimeout( resolve, Math.random() * 1000 );
					} )
						.then( self.getHtml.bind( self ) )
					;
				}

				return self.makeError();
			} )
		;
	};

	SetListLoader.prototype.display = function( html ) {
		this.$container.html( html );
	};

	SetListLoader.prototype.load = function() {
		this.getHtml()
			.then( this.display.bind( this ) )
		;
	};

	function loadLists() {
		$( '.set-list-ajax-tab' ).each( function( i, el ) {
			var $el = $( el );

			new SetListLoader( $el ).load();
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
