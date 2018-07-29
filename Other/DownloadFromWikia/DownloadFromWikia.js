"use strict";

const fetch = require( 'node-fetch' );
const fs    = require( 'fs' );

( async () => {

	const WIKIA_FILE_PATH = 'https://yugioh.wikia.com/wiki/Special:FilePath';

	const getText = async url => {
		const response = await fetch( url );
		return response.text();
	};

	const sleep = time => new Promise(
		resolve => setTimeout( resolve, time )
	);

	const download = file => fetch( `${ WIKIA_FILE_PATH }/${ file }` )
		.then( response => {
			return new Promise( ( resolve, reject ) => {
				const stream = fs.createWriteStream( `./files/${ file }` );
				response.body.pipe( stream );
				response.body.on( 'error', err => {
					reject( err );
				} );
				stream.on( 'finish', () => {
					resolve();
				} );
				stream.on( 'error', err => {
					reject( err );
				} );
			} );
		} )
		.then(
			() => console.log( `Downloaded ${ file }` )
		)
		.catch(
			err => console.warn( `ERROR ON FILE «${ file }»: ${ err }` )
		)
	;

	const filesThatShouldExist = (
		await getText( 'https://yugipedia.com/listOfFiles.txt' )
	).split( '\n' );

	const filesThatDoExist = (
		await getText( 'https://yugipedia.com/listOfFiles.2.txt' )
	).split( '\n' );

	const filesToDownload = filesThatShouldExist.filter(
		file => !filesThatDoExist.includes( file )
	);

	const length = filesToDownload.length;

	for ( let i = 0; i < length; i++ ) {
		await download( filesToDownload[ i ] );

		await sleep( 100 );
		//if ( i > 3 ) throw new Error( 'stop test' );
	}

	console.log( 'Done!' );

} )().catch( err => console.warn( err ) );