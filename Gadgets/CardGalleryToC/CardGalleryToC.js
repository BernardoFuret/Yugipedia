/**
 * Create a ToC for card galleries (using [[Module:Card gallery]]).
 * @author Becasita
 * @contact [[User:Becasita]]
 */
( function _gadgetCardGalleryToC( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	function generateToC( $content ) {
		var $toc = $content.find( '.card-gallery__toc' ).find( 'ul' );

		$content.find( '.mw-headline' ).each( function( index, element ) {
			var $sectionTitle = $( element );

			$toc.append( function() {
				var sectionTitleText = $( this ).parent().parent().find( 'h2' ).text();

				return $( '<li>', {
					'class': 'card-gallery__toc__entry',
					html: $( sectionTitleText === $sectionTitle.text() ? '<strong>' : '<a>', {
						href: '#' + $sectionTitle.attr( 'id' ),
						html: $sectionTitle.html()
					} )
				} );
			} );
		} );
	}

	mw.hook( 'wikipage.content' ).add( generateToC );

	console.log( '[Gadget] CardGalleryToC last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
