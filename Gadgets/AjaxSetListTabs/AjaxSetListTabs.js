/**
 * Dynamically load set lists on the set pages.
 * Idea by Deltaneos.
 * @author Becasita
 * @contact [[User:Becasita]]
 */
( function _gadgetAjaxSetListTabs( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	function getListData( setListPagePath ) {
		return $.ajax( {
			url: setListPagePath,
			dataType: 'html',
			timeout: 5000
		} );
	}

	function parseData( data ) {
		return $( '<div>' )
			.append( $.parseHTML( data ) )
			.find( '#mw-content-text .mw-parser-output' )
				.children()
					.remove( ':first' )
					.remove('.page-header')
						.end()
				.html()
		;
	}

	function SetListLoader( $container ) {
		this.$container = $container;
		this.defaultContent = $container.html();
		this.setListFullpagename = $container.data( 'page' );
		this.setListPagePath = [
			/wiki/,
			window.encodeURI( this.setListFullpagename )
		].join( '' );
	}

	SetListLoader.prototype.resetTimeoutTriesCounter = function() {
		this.remainingTimeoutTries = 2;
	};

	SetListLoader.prototype.makePageRedLink = function() {
		var href = [
			'/index.php?title=',
			window.encodeURI( this.setListFullpagename ),
			'&action=edit&redlink=1'
		].join( '' );

		var title = [
			this.setListFullpagename,
			'(page does not exist)'
		].join( ' ' );

		var redLink = $( '<a>', {
			href: href,
			'class': 'new',
			title: title,
			text: this.setListFullpagename
		} );

		return $( '<p>' ).append( redLink );
	};

	SetListLoader.prototype.makeError = function() {
		var self = this;

		var $errorContainer = $( '<div>', {
			'class': 'set-list-ajax-tab__error'
		} );

		var $pageLink = $( '<a>', {
			href: this.setListPagePath,
			text: this.setListFullpagename
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

		return getListData( this.setListPagePath )
			.then( parseData )
			[ 'catch' ]( function( jqXHR, textStatus, error ) {
				if ( jqXHR.status === 404 ) {
					return self.makePageRedLink();
				}

				if ( textStatus === 'timeout' && self.remainingTimeoutTries-- > 0 ) {
					return new Promise( function( resolve ) {
						window.setTimeout( resolve, Math.random() * 5000 );
					} )
						.then( self.getHtml.bind( self ) )
					;
				}

				console.warn(
					'[Gadget]', '[AjaxSetListTabs]',
					'Error loading', self.setListFullpagename,
					'-', jqXHR, textStatus, error
				);

				return self.makeError();
			} )
		;
	};

	SetListLoader.prototype.makeTableSortable = function() {
		// Adapted from /resources/src/mediawiki/page/ready.js
		// Because otherwise would fire at a similar time as the lists loading,
		// but the lists loading would always resolve later.

		var $sortable = this.$container.find( 'table.sortable' );

		if ( $sortable.length ) {
			mw.loader.using( 'jquery.tablesorter', function() {
				$sortable.tablesorter();
			} );
		}
	};

	SetListLoader.prototype.display = function( html ) {
		this.$container.html( html );

		this.makeTableSortable();
	};

	SetListLoader.prototype.load = function() {
		this.resetTimeoutTriesCounter();

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

	mw.hook( 'wikipage.content' ).add( loadLists );

	console.log( '[Gadget] AjaxSetListTabs last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
