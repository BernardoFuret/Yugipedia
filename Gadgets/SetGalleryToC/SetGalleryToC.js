/**
 * Create a ToC for set galleries (using [[Module:Card collection/modules/Set gallery]]).
 * @author Becasita
 * @contact [[User:Becasita]]
 * TODO: CSS may be unified with version from Card gallery ToC gadget.
 */
( function _gadgetSetGalleryToC( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	function newToc() {
		return $( '<ul>', {
			'class': 'set-gallery__toc__list'
		} );
	}

	function getHeaderLevel( headerTag ) {
		var match = /H(?<level>\d)/.exec( headerTag );

		return ( match && match.groups && Number( match.groups.level ) ) || null;
	}

	function generateToC( $content ) {
		var $tocPlaceholder = $content.find( '.set-gallery__toc' );

		var $contentSectionsTitles = $content.find( '.mw-headline, .mw-heading > :header' );

		if ( $contentSectionsTitles.length >= 3 ) { // TODO: make configurable per user?
			var $tocContainer = $( '<div>', {
				'class': 'toc hlist set-gallery__toc__container'
			} ).appendTo( $tocPlaceholder );

			var $initialTocList = newToc().appendTo( $tocContainer );

			var tocsStack = [ $initialTocList ];

			var headersStack = [];

			$contentSectionsTitles.each( function( index, element ) {
				var $currentSectionTitle = $( element );

				var currentSectionTitleId = $currentSectionTitle.attr( 'id' );

				var currentSectionTitleHtml = $currentSectionTitle.html();

				var $currentSectionHeader = $currentSectionTitle.is( ':header' )
					? $currentSectionTitle
					: $currentSectionTitle.parent( ':header' );

				var currentSectionHeaderTag = $currentSectionHeader.prop( 'tagName' );

				var previousSectionHeaderTag = headersStack[ 0 ];

				if ( previousSectionHeaderTag == null ) {
					headersStack.unshift( currentSectionHeaderTag );
				} else {
					var previousSectionHeaderLevel = previousSectionHeaderTag && getHeaderLevel( previousSectionHeaderTag );

					var currentSectionHeaderLevel = getHeaderLevel( currentSectionHeaderTag );

					if ( previousSectionHeaderLevel != null && currentSectionHeaderLevel !== null ) {
						if ( currentSectionHeaderLevel > previousSectionHeaderLevel ) {
							var wrappers = tocsStack[ 0 ].map( function( index, element ) {
								return $( element ).children().last();
							} );

							tocsStack.unshift( newToc().appendTo( wrappers ) );

							headersStack.unshift( currentSectionHeaderTag );
						}

						if ( currentSectionHeaderLevel < previousSectionHeaderLevel ) {
							tocsStack.shift();

							headersStack.shift( currentSectionHeaderTag );
						}
					}
				}

				var $toc = tocsStack[ 0 ];

				$toc.append( function() {
					var $previousSectionHeader = $( this )
						.parents( '.set-gallery' )
						.prevAll( '.mw-heading, :header' )
						.first();

					if ( !$previousSectionHeader.is( ':header' ) ) {
						$previousSectionHeader = $previousSectionHeader.find( ':header' ).first();
					}

					var $previousSectionTitle = $previousSectionHeader.find( '.mw-headline' ).first();

					if ( !$previousSectionTitle.length ) {
						$previousSectionTitle = $previousSectionHeader;
					}

					var tocSectionTitleId = $previousSectionTitle.attr( 'id' );

					return $( '<li>', {
						'class': 'set-gallery__toc__entry',
						html: $( tocSectionTitleId === currentSectionTitleId ? '<strong>' : '<a>', {
							href: '#' + currentSectionTitleId,
							html: currentSectionTitleHtml
						} )
					} );
				} );
			} );
		} else {
			$tocPlaceholder.remove();
		}
	}

	mw.hook( 'wikipage.content' ).add( generateToC );

	console.log( '[Gadget] SetGalleryToC last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
