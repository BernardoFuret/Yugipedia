/**
 * Links missing files on galleries to the Special:Upload page.
 * @author Becasita
 * @contact [[User talk:Becasita]]
 */
( function _gadgetLinkMissingGalleryFilesToUpload( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	function linkEmptyGalleries( $content ) {
		$content.find( '.thumb' ).each( function() {
			var $thisThumb = $( this );

			if ( !$thisThumb.children().length ) {
				var missingFileName = $thisThumb.text();
				
				$thisThumb.text( '' ).append(
					$( '<a>', {
						'class': 'noFile',
						href: '/index.php?title=Special:Upload&wpDestFile=' + missingFileName,
						text: missingFileName
					} )
				);
			}
		} );

		mw.hook( 'ext.gadget.LinkMissingGalleryFilesToUpload' ).fire( $content );
	}

	mw.hook( 'wikipage.content' ).add( linkEmptyGalleries );

	console.log( '[Gadget] LinkMissingGalleryFilesToUpload last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
