const main = require( './src' );

main()
	.catch( e => console.error( 'Unexpected error', e ) )
	.finally( () => {
		return fsp.writeFile( 'dump.json', JSON.stringify( cardsData ) )
			.catch( e => console.error( 'Error writing:', e ) )
		;
	} )
;

process.on( 'SIGINT', async () => {
	try {
		await fsp.writeFile( 'dump.json', JSON.stringify( cardsData ) )
			.catch( e => console.error( 'Error writing:', e ) )
		;
	} catch ( e ) {
		console.error( 'ERROR:', e );
	} finally {
		process.exit();
	}
} );
