const axios = require( 'axios' );

const { editions, rarities } = require( '../../constants' );

const api = require( '../../api' );

const { parseContent, regexEscape } = require( '../../helpers' );

const setsCache = {};

const galleryCache = {};

function getLangIndex( { index } ) {
	if ( index === 'SP' ) {
		return 'es';
	}

	if ( [ 'EN', 'NA', 'EU', 'AU', 'AE' ].includes( index ) ) {
		return 'en';
	}

	if ( index === 'FC' ) {
		return 'fr';
	}

	return index.toLowerCase();
}

async function computeSetInfo( region, title ) {
	if ( !setsCache[ title ] ) {
		const content = await api.getRawContent( title );

		setsCache[ title ] = await parseContent(
			content,
			require( '..' ).set, // TODO: resolve circular dependency (this module calls .. which calls ../common which calls this one)
			{ title },
		);
	}

	const setData = setsCache[ title ];

	const langIndex = getLangIndex( region );

	return {
		name: setData[ `${langIndex}_name` ] || setData.en_name || title,
		date: setData[ `${region.index.toLowerCase()}_release_date` ],
		editions: editions
			.map( edition => (
				setData[ `${edition.abbr.toLowerCase()}_galleries` ].includes( region.index )
				&&
				edition.full
			) )
			.filter( Boolean )
		,
	};
}

function getFromCollection( collection, raw ) {
	return collection.find(
		item => Object.values( item ).map( v => v.toLowerCase() ).includes( raw.toLowerCase() ),
	) || {};
}

function getFileParts( file ) {
	const parts = file.split( '.' )[ 0 ].split( '-' );

	if ( !parts[ 4 ] ) {
		// E.g.: DecodeTalker-ST17-EN-OP.png
		return console.warn( 'File with too few parts:', file );
	}

	if ( parts.length > 7 ) {
		return console.warn( 'File with too many parts:', file );
	}

	if ( /-(CT|OP|GC)(-|\.)/g.test( file ) ) {
		return console.warn( 'File with release:', file );
	}

	const isReplica = parts[ 5 ] === 'RP';

	return {
		rarityRaw: parts[ 3 ],
		editionRaw: parts[ 4 ],
		tag: parts[ isReplica ? 6 : 5 ],
		isReplica,
	};
}

function parseImageFile( file, description ) {
	const parts = getFileParts( file );

	if ( !parts ) {
		return;
	}

	const { rarityRaw, editionRaw, tag, isReplica } = parts;

	const rarity = getFromCollection( rarities, rarityRaw );

	if ( !rarity ) {
		return console.warn( 'Missing rarity', rarityRaw, 'for file', file );
	}

	const edition = getFromCollection( editions, editionRaw );

	if ( !edition ) {
		return console.warn( 'Missing edition', editionRaw, 'for file', file );
	}

	return {
		file,
		link: `https://yugipedia.com/wiki/Special:FilePath/${file}`,
		edition: edition.full,
		rarity: rarity.full,
		...( tag && { tag } ),
		...( description && { description } ),
		...( isReplica && { replica: true } ),
	};
}

function makeImageFile( title, setAbbr, region, rarity, edition, tag, extension = 'png', replica = '' ) {
	return `${[
		title.split( /\s*\(/ )[ 0 ].replace( /[ ,.:'"&!@%=?[\]<>\\/-]/g, '' ),
		setAbbr,
		region.index,
		rarity.abbr,
		edition.abbr,
		replica,
		tag,
	].filter( v => v ).join( '-' )}.${extension.toLowerCase()}`;
}

function parseImageNewEntry( entry, title, region ) {
	const [ rest, ...optionsRaw ] = entry.trim().split( /\s*\/\/\s*/ );

	const { file: fileOption, extension, description } = optionsRaw.join( '//' ).split( /\s*;\s*/ )
		.reduce( ( all, optionsEntry ) => {
			const [ optionName, ...optionValue ] = optionsEntry.split( /\s*::\s*/ );

			return {
				...all,
				[ optionName ]: optionValue.join( '::' ),
			};
		}, {} )
	;

	if ( fileOption ) {
		return parseImageFile( fileOption, description );
	}

	const [ values, release ] = rest.split( /\s*::\s*/ );

	if ( release && ( release !== 'RP' ) ) {
		return console.warn( 'Entry with release:', release, entry );
	}

	const [ number, , rarityRaw, editionRaw, tag ] = values.split( /\s*;\s*/ );

	const [ setAbbr ] = number.split( '-' );

	const rarity = getFromCollection( rarities, rarityRaw );

	if ( !rarity ) {
		return console.warn( 'Missing rarity', rarityRaw, 'for entry', entry, 'for card', title );
	}

	const edition = getFromCollection( editions, editionRaw );

	if ( !edition ) {
		return console.warn( 'Missing edition', editionRaw, 'for entry', entry, 'for card', title );
	}

	const file = makeImageFile( title, setAbbr, region, rarity, edition, tag, extension, release );

	return {
		file,
		link: `https://yugipedia.com/wiki/Special:FilePath/${file}`,
		edition: edition.full,
		rarity: rarity.full,
		...( tag && { tag } ),
		...( description && { description } ),
		...( release && { replica: true } ),
	};
}

function parseImageEntry( entry, title, region ) {
	return ( ( /\|/.test( entry ) && !entry.match( '::' ) )
		? parseImageFile( entry.split( /\s*\|\s*/ )[ 0 ] )
		: parseImageNewEntry( entry, title, region )
	);
}

async function validateImage( image ) {
	return image && axios.get( image.link )
		.then( () => image )
		.catch( () => false )
	;
}

async function getImages( title, region, cardNumber ) {
	if ( !galleryCache[ title ] ) {
		galleryCache[ title ] = await api.getRawContent( `Card Gallery:${title}` );
	}

	const content = galleryCache[ title ];

	const regex = new RegExp( `^\\s*(.*?${regexEscape( cardNumber )}.*?)\\s*?$`, 'gm' );

	const images = [];

	content.replace( regex, async ( m, entry ) => { // hack
		try {
			const image = parseImageEntry( entry, title, region );

			images.push( validateImage( image ) );
		} catch ( error ) {
			console.error( 'Unexpected error while parsing image entry', entry, error );
		}
	} );

	return Promise.all( images ).then( imgs => imgs.filter( i => i ) );
}

const parseParts = async ( region, title, [ cardNumber, setName, rarities ] ) => ( {
	cardNumber,
	...await computeSetInfo( region, setName ),
	rarities: rarities.split( /\s*,\s*/ ),
	images: await getImages( title, region, cardNumber ).catch( e => {
		console.warn( 'Error processing images for', title, e );

		return [];
	} ),
} );

const makeEntriesParser = ( region, title ) => async entry => parseParts( region, title, entry.split( /\s*;\s*/ ) ).catch( e => {
	console.warn( 'Error processing set info for card', title, 'region', region, 'and entry', entry, e );

	return {};
} );

module.exports = region => {
	return async ( rawValue, { title } ) => {
		return rawValue
			? Promise.all( rawValue.split( '\n' ).map( makeEntriesParser( region, title ) ) )
			: []
		;
	};
};
