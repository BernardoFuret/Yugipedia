/**
 * Display last revision info at the top of the page
 */
(function _gadgetDisplayLastRevisionInfo(window, $, mw, console) {
	'use strict';

	var LAST_LOG = '~~~~~';

	var config = mw.config.get(['wgPageName', 'wgNamespaceNumber']);

	var api;

	function createTooltip($children, $content) {
		var $tooltipWrapper = $('<div>', {
			class: 'gadget-display-last-revision-info__content--tooltip',
		});

		var $tooltipContent = $('<div>', {
			class: 'gadget-display-last-revision-info__content--tooltip__content',
			html: $content,
		});

		return $tooltipWrapper.append($children).append($tooltipContent);
	}

	function fetchPageLastRevision() {
		return api
			.get({
				titles: config.wgPageName,
				action: 'query',
				prop: 'revisions',
				rvprop: 'ids|user|timestamp|parsedcomment|flags',
				redirects: false,
				format: 'json',
				formatversion: 2,
			})
			.then(function (response) {
				return response.query.pages[0].revisions[0];
			});
	}

	/** @typedef {{
	 *   revid: string
	 *   minor?: string
	 *   user: string
	 *   timestamp: string
	 *   parsedcomment: string
	 * }} TRevisionData
	 */
	/**
	 * @param  {TRevisionData} revisionData
	 */
	function updateUi(revisionData) {
		var $bodyContent = $('#bodyContent');

		var $outerContainer = $('<div>', {
			class: 'gadget-display-last-revision-info',
		});

		$bodyContent.prepend($outerContainer);

		var $userPageLink = $('<a>', {
			target: '_blank',
			href: '/wiki/User:' + encodeURIComponent(revisionData.user),
			text: revisionData.user,
		});

		var $diffLink = $('<a>', {
			target: '_blank',
			href: '/index.php?diff=' + revisionData.revid,
			text: revisionData.revid,
		});

		// If it's a minor edit, `minor` is present
		var isMinorEdit = 'minor' in revisionData;

		var $minorIndicator = $('<sup>', {
			class: 'gadget-display-last-revision-info__content__indicator',
			html: $('<abbr>', {
				title: 'Minor edit',
				text: 'M',
			}),
		});

		var $innerContainer = $('<div>', {
			class: 'gadget-display-last-revision-info__content',
			html:
				'Last edited at ' +
				revisionData.timestamp +
				' by ' +
				$userPageLink.prop('outerHTML') +
				' (' +
				$diffLink.prop('outerHTML') +
				')' +
				(isMinorEdit ? $minorIndicator.prop('outerHTML') : ''),
		});

		var $tooltip = createTooltip($innerContainer, revisionData.parsedcomment);

		$outerContainer.append($('#siteSub')).append($tooltip);
	}

	function handleError(error) {
		console.error('[Gadget] DisplayLastRevisionInfo error:', error);
	}

	function init() {
		if (config.wgNamespaceNumber > -1) {
			mw.loader.using('mediawiki.api').done(function () {
				api = new mw.Api();

				fetchPageLastRevision().then(updateUi).catch(handleError);
			});
		}
	}

	$(init);

	console.log('[Gadget] DisplayLastRevisionInfo last updated at', LAST_LOG);
})(window, window.jQuery, window.mediaWiki, window.console);
