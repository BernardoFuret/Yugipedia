/**
 * Add preload templates to certain red links, by namespace.
 */
( function _gadgetSetupRedLinksPreloadTemplates( window, $, mw, console ) {
	"use strict";

	var LAST_LOG = '~~~~~';

	var config = mw.config.get( [
		'wgNamespaceIds',
		'wgFormattedNamespaces'
	] );

	var namespaceIdToPreloadTemplateMapper = {
		// Set Card Lists
		3006: 'Template:Set list/preload',
		// Set Card Galleries
		3024: 'Template:Set gallery/preload'
	};

	function inferTitleNamespace( title ) {
		var match = /^(.+?):/.exec( title );

		return ( match && match[ 1 ] ) || '';
	}

	function computeInternalLinkUrl( href ) {
		return new URL( href, window.location.origin );
	}

	function checkLinkHasPreloadParam( linkUrl ) {
		return linkUrl.searchParams.has( 'preload' );
	}

	function getNamespacePreloadTemplate( localizedNamespace ) {
		var formattedNamespaceEntry = Object.entries( config.wgFormattedNamespaces )
			.find( function ( entry ) {
				var namespaceLocalizedName = entry[ 1 ];

				return localizedNamespace === namespaceLocalizedName;
			} );

		if (!formattedNamespaceEntry) {
			return;
		}

		var namespaceId = formattedNamespaceEntry[ 0 ];

		return namespaceIdToPreloadTemplateMapper[ namespaceId ];
	}

	function computeUrlInternalLink( url ) {
		var urlOriginTrimRegex = new RegExp( '^' + url.origin );

		return url.href.replace( urlOriginTrimRegex, '' );
	}

	function updateRedLinks( $content ) {
		$content.find( 'a.new' ).each( function( _index, element ) {
			var elementUrl = computeInternalLinkUrl( element.href );

			if ( checkLinkHasPreloadParam( elementUrl ) ) {
				return;
			}

			var titleNamespace = inferTitleNamespace( element.title );

			var namespacePreloadTemplate = getNamespacePreloadTemplate( titleNamespace );

			if ( namespacePreloadTemplate ) {
				elementUrl.searchParams.append( 'preload', namespacePreloadTemplate );

				element.href = computeUrlInternalLink( elementUrl );
			}
		} );
	}

	mw.hook( 'wikipage.content' ).add( updateRedLinks );

	console.log( '[Gadget] SetupRedLinksPreloadTemplates last updated at', LAST_LOG );

} )( window, window.jQuery, window.mediaWiki, window.console );
