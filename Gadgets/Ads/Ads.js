(function _gadgetAds() {
	"use strict";

	var LAST_LOG = '~~~~~';

	function updateSideBarHeight() {
		/**
		 * To make the MW Panel ad sticky.
		 * Set the height of the panel to fill the total height of the document.
		 * The rest is handled via CSS.
		 * Deprecates [[MediaWiki:Gadget-StickyMwPanelAd.js]]
		 */
		document.getElementById('mw-panel').style.height = document.documentElement.scrollHeight + 'px';
	}

	mw.loader.using( 'mediawiki.util' ).then(function () {
		if (!mw.util.getParamValue('action')) {
			updateSideBarHeight();
		}
	});

	console.log('[Gadget] Ads last updated at', LAST_LOG);
})();
