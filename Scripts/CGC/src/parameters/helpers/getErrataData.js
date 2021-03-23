const api = require( '../../api' );

const { removeWikitextMarkup } = require( '../../helpers' );

const hasOwnProp = Object.prototype.hasOwnProperty;

const cache = {};

async function getContent( title ) {
	if ( !hasOwnProp.call( cache, title ) ) {
		cache[ title ] = await api.getRawContent( title ).catch( () => '' );
	}

	return cache[ title ];
}

function getErrataForLanguage( content, language ) {
	const languageRegex = ( language.index === 'en'
		? '(?!\\|[ \\t]*lang=\\w+[ \\t]*)'
		: `\\|[ \\t]*lang=${language.index}[ \\t]*`
	);

	const regex = new RegExp(
		`{{[ \\t]*Errata table[ \\t]*${languageRegex}([\\s\\S]*?)\\}\\}[ \\t]*$`,
		'gmi',
	);

	return ( regex.exec( content ) || {} )[ 1 ];
}

function parseCaption( raw, { index } ) {
	const parts = removeWikitextMarkup( raw ).split( /\n+/ );

	if ( /database link/i.test( parts[ 0 ] ) ) {
		const [ , dbId ] = parts[ 0 ].split( /\s*\|\s*/ );

		return {
			notes: `From official database: https://www.db.yugioh-card.com/yugiohdb/card_search.action?ope=2&cid=${dbId}&request_locale=${index}`,
		};
	}

	if ( parts.length < 2 ) {
		return {
			notes: parts[ 0 ],
		};
	}

	return {
		set: parts[ 1 ],
		notes: parts.slice( 2, parts.length ).join( ' /// ' ),
	};
}

function parseErrata( content, language ) {
	const captionRegex = /^[ \t]*\|[ \t]*cap(\d+)[ \t]*=(?:[ \t]*\n?(.*?)\s*)$/gims;

	const errata = {};

	content.replace( captionRegex, ( m, order, captionRaw ) => { // hack
		const parametersRegex = new RegExp(
			`^[ \\t]*\\|[ \\t]*(name|lore|card_type)${order}[ \\t]*=(?:[ \\t]*\\n?(.*?)\\s*)$`,
			'gims',
		);

		const { set = '???', notes } = parseCaption( captionRaw, language );

		content.replace( parametersRegex, ( m, parameter, value ) => { // hack
			if ( !hasOwnProp.call( errata, parameter ) ) {
				errata[ parameter ] = [];
			}

			let data = removeWikitextMarkup( value );

			if ( parameter === 'card_type' ) {
				data = data.replace( /^\s*\[\s*/, '' ).replace( /\s*\]\s*$/, '' );
			}

			errata[ parameter ][ order ] = {
				data,
				since: set,
				...( notes && { notes } ),
			};
		} );
	} );

	return Object.entries( errata )
		.reduce( ( allErrata, [ parameter, values ] ) => ( {
			...allErrata,
			[ parameter ]: values.filter( v => v ),
		} ), {} )
	;
}

module.exports = async ( language, title ) => {
	const errataPageContent = await getContent( `Card Errata:${title}` );

	const languageErrataContent = getErrataForLanguage( errataPageContent, language );

	if ( !languageErrataContent ) {
		return;
	}

	return parseErrata( languageErrataContent, language );
};

/*
handle database.
handle three entries in caption
handle refs in caption
handle pendulum effects
handle '''Pendulum Effect:'''
handle card type (remove [ ])

https://yugipedia.com/index.php?title=Card_Errata%3ASummoned_Skull&action=raw

https://yugipedia.com/index.php?title=Card_Errata%3ACipher_Soldier&action=raw

https://yugipedia.com/index.php?title=Card_Errata%3AMan-Eater_Bug&action=raw

https://yugipedia.com/index.php?title=Card_Errata%3AQliphort_Monolith&action=raw

https://yugipedia.com/index.php?title=Card_Errata%3AHarpie_Lady_Sisters&action=raw

https://yugipedia.com/index.php?title=Card_Errata%3ADarkness_Approaches&action=raw

https://yugipedia.com/index.php?title=Card_Errata%3APerformapal_Pendulum_Sorcerer&action=raw
 */
