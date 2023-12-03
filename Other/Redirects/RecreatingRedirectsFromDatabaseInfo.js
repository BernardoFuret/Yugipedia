/* global TEXT */
/**
 * (browser)
 */
(async (window, $, mw, console) => {
	'use strict';

	const __errors = [];

	const __tracking = [];

	let processedPages = 0;

	const api = await mw.loader.using('mediawiki.api').then(() => new mw.Api());

	const sleep = (ms) => new Promise((r) => window.setTimeout(r, ms));

	const quote = (pagename) => `"${pagename.replace('"', '\\"')}"`;

	const processLine = (line) => {
		const [lineId, sourcePagename, targetPagename] = line.split('\t');

		return {
			lineId,
			sourcePagename: sourcePagename.replace(/_/g, ' '),
			targetPagename: targetPagename.replace(/_/g, ' '),
		};
	};

	const getTemplateFromSourcePagename = (sourcePagename) => {
		switch (true) {
			case /^\d{8}$/.test(sourcePagename): {
				return 'R from password';
			}
			case /^\d{4,5}$/.test(sourcePagename): {
				return 'R from database ID';
			}
			case /^(?:RD\/)?[\dA-Z]{2,4}-(?:[A-Z]{1,4})?(?:\d{1,4}|TKN)$/.test(sourcePagename): {
				// ^[\d\-A-Z\/]{5,13}$
				return 'R from card number';
			}
			default: {
				return null;
			}
		}
	};

	const redirect = (sourcePagename, targetPagename, template) => {
		const templateString = template ? ` {{${template}}}` : '';

		return api.postWithToken('csrf', {
			action: 'edit',
			title: sourcePagename,
			createonly: true,
			text: `#REDIRECT [[${targetPagename}]]${templateString}`,
			summary: 'Recreating redirects: Redirected page to [[' + targetPagename + ']].',
			bot: true,
		});
	};

	const getPageInfo = (pagename) => {
		return api.get({
			action: 'query',
			prop: 'info',
			format: 'json',
			formatversion: 2,
			titles: pagename,
		});
	};

	window.DEBUG = true;

	const START_TIME = window.performance.now();

	const LIST = TEXT.split('\n');

	try {
		for (const line of LIST) {
			if (window.STOP_SCRIPT) {
				throw new Error(`Halt! (${line})`);
			}

			if (!line) {
				continue;
			}

			const { lineId, sourcePagename, targetPagename } = processLine(line);

			processedPages++;

			console.log(
				`[${processedPages}]`,
				`[${new Date().toISOString().replace('T', ', ')}]`,
				lineId,
				'Redirecting from',
				quote(sourcePagename),
				'to',
				quote(targetPagename),
			);

			if (!sourcePagename) {
				console.warn('\tWarning: No sourcePagename');

				__errors.push({
					data: { lineId, sourcePagename, targetPagename, line },
					type: '01-no-sourcePagename',
				});

				continue;
			}

			if (!targetPagename) {
				console.warn('\tWarning: No targetPagename');

				__errors.push({
					data: { lineId, sourcePagename, targetPagename, line },
					type: '02-no-targetPagename',
				});

				continue;
			}

			const template = getTemplateFromSourcePagename(sourcePagename);

			try {
				const data = await redirect(sourcePagename, targetPagename, template);

				console.log(
					`\tCreated redirect from ${quote(sourcePagename)} to ${quote(targetPagename)}`,
					$('<a>', {
						target: '_blank',
						href: `https://yugipedia.com/index.php?diff=${data.edit.newrevid}`,
						text: data.edit.newrevid,
					}).prop('outerHTML'),
				);
			} catch (e) {
				if (e === 'articleexists') {
					try {
						const sourcePageInfo = await getPageInfo(sourcePagename).then(
							(res) => res.query.pages[0],
						);

						if (!sourcePageInfo.redirect) {
							console.warn(
								'\tWarning: Page',
								$('<a>', {
									target: '_blank',
									href: `https://yugipedia.com/wiki/${encodeURIComponent(sourcePagename)}`,
									text: quote(sourcePagename),
								}).prop('outerHTML'),
								'exists and should be a redirect, but it is not.',
							);

							__errors.push({
								data: { lineId, sourcePagename, targetPagename, sourcePageInfo, line },
								type: 'RR-page-exists-and-should-be-redirect-but-is-not',
							});

							__tracking.push({ lineId, sourcePagename, targetPagename, sourcePageInfo, line });
						}
					} catch (ee) {
						console.warn(`\tWarning: Error checking info for page ${quote(sourcePagename)}:`, ee);

						__errors.push({
							data: { lineId, sourcePagename, targetPagename, line, e: ee },
							type: 'PI-while-checking-page-info',
						});
					}
				}

				console.warn(`\tWarning: Error creating ${quote(sourcePagename)}:`, e);

				__errors.push({
					data: { lineId, sourcePagename, targetPagename, line, e },
					type: e === 'articleexists' ? '99-article-exists' :  '00-while-creating-redirect',
				});
			}

			await sleep(window.SCRIPT_LATENCY || 1000);
		}
	} catch (err) {
		console.error('Error: Something wrong happened:', err.message, err);

		__errors.push({ data: err, type: 'XX-unknown' });
	}

	const END_TIME = window.performance.now();

	window[`__errors$${Date.now().toString(36)}`] = __errors;

	window[`__tracking$${Date.now().toString(36)}`] = __tracking;

	window.DEBUG = true;

	console.log(window.STOP_SCRIPT ? 'Stopped!' : 'All done!');

	console.log('Took', END_TIME - START_TIME);

	console.log('Processed', processedPages, 'pages');

	if (__tracking.length) {
		console.log('Tracking:', __tracking);

		const blob = new Blob([JSON.stringify(__tracking)], { type: 'application/json' });

		const aElem = window.document.createElement('a');

		aElem.href = window.URL.createObjectURL(blob);

		aElem.download = 'RR-redirects-tracking';

		document.body.appendChild(aElem);

		aElem.click();

		document.body.removeChild(aElem);
	}

	window.console.log('>>> Non-99 __errors:', __errors.filter((e) => !e.type.match('99')));
})(
	window,
	window.jQuery,
	window.mediaWiki,
	((window, $) => {
		'use strict';

		const win = window.open();

		const doWrite = (args, color = 'black') =>
			window.DEBUG &&
			win.document.write(
				$('<pre>', {
					html: args
						.map((arg) => (typeof arg !== 'string' ? JSON.stringify(arg, null, '  ') : arg))
						.join(' '),
				})
					.css('color', color)
					.prop('outerHTML'),
			);

		return {
			log: (...args) => doWrite(args),

			warn: (...args) => doWrite(args, 'darkorange'),

			error: (...args) => doWrite(args, 'red'),
		};
	})(window, window.jQuery),
).catch(window.console.error);
