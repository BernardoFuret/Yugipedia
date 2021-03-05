function validate( A, N, F ) {
	const n = Number( N );

	if ( isNaN( n ) || n < 1 || !Number.isInteger( n ) ) {
		throw TypeError( `${N} must be an integer Number greater than 0!` );
	}

	if ( !Array.isArray( A ) ) {
		throw TypeError( `${A} must be an array!` );
	}

	if ( typeof F !== 'function' ) {
		throw TypeError( `${F} must be a function!` );
	}
}

module.exports = async function concurrentIteration( array, n, cb ) {
	validate( array, n, cb );

	const length = array.length;

	const iterate = async ( chainId, index, accumulator ) => {
		return index < length
			? Promise.resolve()
				.then( () => cb( array[ index ], { index, chainId } ) )
				.then( r => iterate( chainId, index + n, [ ...accumulator, r ] ) )
			: accumulator
		;
	};

	return Promise.allSettled( [ ...Array( n ) ].map( ( e, i ) => iterate( i, i, [] ) ) );
};
