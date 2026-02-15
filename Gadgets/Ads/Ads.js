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

	mw.loader.using('mediawiki.util').then(function () {
		if (!mw.util.getParamValue('action')) {
			updateSideBarHeight();
		}
	});

	function setContentAds() {
		if (!mw.user.isAnon()) {
			return;
		}

		document.querySelectorAll('h2 > .mw-headline').forEach(function (element, index) {
			var parentH2 = element.closest('h2');

			if (!parentH2) {
				return;
			}

			var adPlacementId = 'content-banner-' + index.toString();

			var adPlacement = document.createElement('div');

			adPlacement.id = adPlacementId;

			parentH2.insertAdjacentElement('beforebegin', adPlacement);

			window.nitroAds.createAd(adPlacementId, {
				sizes: [
					['728', '90'],
					['320', '50']
				],
				report: {
					enabled: true,
					icon: true,
					wording: 'Report Ad',
					position: 'top-right'
				}
			});
		});
	}

	mw.hook('wikipage.content').add(setContentAds);

	console.log('[Gadget] Ads last updated at', LAST_LOG);
})();
