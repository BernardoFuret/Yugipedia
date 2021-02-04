// https://www.npmjs.com/package/export-to-csv

const { promises: fsp } = require( 'fs' );

const path = require( 'path' );

const { ExportToCsv } = require( 'export-to-csv' );

const fetch = require( 'node-fetch' );

const headers = {
	'User-Agent': 'Becasita - Scraping for Dan (see Discord Yugipedia#Systems)',
};

const sleep = ms => new Promise( r => setTimeout( r, ms ) );

function makeApiLink( query ) {
	return `https://yugipedia.com/api.php?${ Object.entries( query ).reduce( ( acc, [ key, value ] ) => {
		if ( value ) {
			acc.push( `${key}=${encodeURIComponent( value )}` );
		}
		
		return acc;
	}, [] ).join( '&' ) }`;
}

function getCategoryMembers( cmcontinue ) {
	return fetch( makeApiLink( {
		action: 'query',
		list: 'categorymembers',
		cmtitle: 'Category:TCG cards',
		cmlimit: 'max',
		format: 'json',
		cmcontinue: cmcontinue,
	} ), { headers } ).then( r => r.json() );
}

function makeSMWQuery( title ) {
	return `[[${title}]]|?Card type|?English name=Name|?ATK string=ATK|?DEF string=DEF|?Stars|?Link Rating|?Attribute|?Types|?Lore|?Pendulum Effect|?TCG Advanced Format Status=Status|?TCG Speed Duel status=Speed Duel status|?Password|?Database ID|?Property|?Character`;
}

function getSMWData( title ) {
	return fetch( makeApiLink( {
		action: 'ask',
		query: makeSMWQuery( title ),
		format: 'json',
	} ), { headers } ).then( r => r.json() );
}

function cleanText( text ) {
	return ( text || '' )
		.replace( "''", '' )
		.replace( /< *br *\/? *>/gm, '\n' )
		.replace( /\[\[(.*?)(?:\|(.*?))?\]\]/gm, ( m, $1, $2 ) => $2 || $1 )
	;
}
	/*
?English name=Name
?ATK
?DEF
?Stars
?Link Rating
?Attribute
?Types
?Lore
?Pendulum Effect
?TCG Advanced Format Status=Status
?TCG Speed Duel status=Speed Duel status
?Password
?Database ID
	 */

/* ST
?English name=Name
?Property
?Lore
?TCG Advanced Format Status=Status
?TCG Speed Duel status=Speed Duel status
?Password
?Database ID

 */

/* Skill
?English name=Name
?Character
?Types
?Lore
?TCG Speed Duel status=Speed Duel status
 */
const MONSTERS = [];

const SPELL_TRAPS = [];

const SKILLS = [];

function toCsv( data, name, headers ) {
	const filename = path.join( 'csv', `${name}.csv` );

	const csvExporter = new ExportToCsv( {
		filename: filename,
	} );

	const csv = csvExporter
		.generateCsv( [
			headers,
			...data.map( Object.values ),
		], true )
		.replace( /,undefined/g, ',')
	;

	return fsp.writeFile( filename, csv )
		.catch( console.error.bind( console, `Error writing ${filename}:` ) )
	;
}

async function generateCSVFiles() {
	await fsp.mkdir( 'csv', { recursive: true } );

	const monstersToCsv = toCsv( MONSTERS, 'monsters', [
		'Name',
		'ATK',
		'DEF',
		'Stars',
		'Link Rating',
		'Attribute',
		'Types',
		'Lore',
		'Pendulum Effect',
		'Status',
		'Speed Duel status',
		'Password',
		'Database ID',
	] );

	const spelltrapsToCsv = toCsv( SPELL_TRAPS, 'spelltraps', [
		'Name',
		'Type',
		'Property',
		'Lore',
		'Status',
		'Speed Duel status',
		'Password',
		'Database ID',
	] );

	const skillsToCsv = toCsv( SKILLS, 'skills', [
		'Name',
		'Character',
		'Types',
		'Lore',
		'Speed Duel status',
	] );

	await Promise.all( [ monstersToCsv, spelltrapsToCsv, skillsToCsv ] );
}

const defaultHandler = d => console.log(
	'No handler for',
	( d[ 'Card type' ][ 0 ] ||  {} ).fulltext,
);

function makeHandlerFor( type ) {
	return data => {
		SPELL_TRAPS.push( {
			Name: data.Name[ 0 ],
			Type: type,
			Property: data.Property[ 0 ],
			Lore: cleanText( data.Lore[ 0 ] ),
			Status: ( data.Status[ 0 ] || {} ).fulltext,
			'Speed Duel status': data[ 'Speed Duel status' ][ 0 ],
			Password: data.Password[ 0 ],
			'Database ID': data[ 'Database ID' ][ 0 ],
		} );
	};
}

const handlers = {
	'Monster Card': data => {
		MONSTERS.push( {
			Name: data.Name[ 0 ],
			ATK: data.ATK[ 0 ],
			DEF: data.DEF[ 0 ],
			Stars: data.Stars[ 0 ],
			'Link Rating': data[ 'Link Rating' ][ 0 ],
			Attribute: ( data.Attribute[ 0 ] || {} ).fulltext,
			Types: data.Types[ 0 ],
			Lore: cleanText( data.Lore[ 0 ] ),
			'Pendulum Effect': cleanText( data[ 'Pendulum Effect' ][ 0 ] ),
			Status: ( data.Status[ 0 ] || {} ).fulltext,
			'Speed Duel status': data[ 'Speed Duel status' ][ 0 ],
			Password: data.Password[ 0 ],
			'Database ID': data[ 'Database ID' ][ 0 ],
		} );
	},

	'Spell Card': makeHandlerFor( 'Spell Card' ),

	'Trap Card': makeHandlerFor( 'Trap Card' ),

	'Skill Card': data => {
		SKILLS.push( {
			Name: data.Name[ 0 ],
			Character: ( data.Character[ 0 ] || {} ).fulltext,
			Types: data.Types[ 0 ],
			Lore: cleanText( data.Lore[ 0 ] ),
			'Speed Duel status': data[ 'Speed Duel status' ][ 0 ],
		} );
	},
};

( async () => {
	let continueToken = null;

	do {
		const cmResponse = await getCategoryMembers( continueToken );

		// Update the continue token:
		continueToken = ( cmResponse.continue || {} ).cmcontinue;

		const members = cmResponse.query.categorymembers;

		for ( const { title } of members ) {
			console.log( 'Processing', title );

			try {
				const smwData = await getSMWData( title );
				
				const smwCardData = smwData.query.results[ title ].printouts;

				const cardType = ( smwCardData[ 'Card type' ][ 0 ] || {} ).fulltext;

				( handlers[ cardType ] || defaultHandler )( smwCardData );
			} catch ( e ) {
				console.error( 'Error processing', title, e );
			}

			await sleep( 250 );
		}
	} while ( continueToken );

	await generateCSVFiles();
} )();

process.on( 'SIGINT', async () => {
	try {
		await generateCSVFiles();
	} catch ( e ) {
		console.error( 'ERROR:', e );
	} finally {
		process.exit();
	}
} );
