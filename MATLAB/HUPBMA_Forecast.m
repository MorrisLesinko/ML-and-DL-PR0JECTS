function [ BMAHUPR ] = HUPBMA_Forecast( An0, An1, Bn0, Bn1, Dn0, Dn1, Tn0, Tn1, pd_hn0, pd_hn1, pd_sn0, pd_sn1, w, hn, esn, precip, prc, Th )

t = size( hn, 1 );
M = 10000;
n = size( hn, 2 ) - 1;
m = numel( fieldnames( esn ) );
hxn = 1:0.1:800;
W0 = cumsum( w.P0, 2 );
W1 = cumsum( w.P1, 2 );
for i = 1:t
    p0 = precip( i, : );
    h0 = hn( i, 1 );
    for ii = 1:n
        fprintf( '>>>>> date = %d ----> leadtime = %d  \n', i, ii );
        leadtime = [ 'LT', num2str( ii ) ];
        for mm = 1:m
        member = [ 'M', num2str( mm ) ];
        sn2 = esn.( member )( i, ii );
            if p0 <= Th
                CDF.( member ).( leadtime )( i, : ) = normcdf( ( norminv( cdf( pd_hn0( ii + 1, : ), hxn ) ) ...
                 - An0.( member )( ii, 1 ) * norminv( cdf( pd_sn0.( member )( ii, : ), sn2 ) ) ...
                 - Dn0.( member )( ii, 1 ) * norminv( cdf( pd_hn0( 1, : ), h0 ) ) - Bn0.( member )( ii, 1 ) ) ...
                 / Tn0.( member )( ii, 1 ) );
            else 
                CDF.( member ).( leadtime )( i, : ) = normcdf( ( norminv( cdf( pd_hn1( ii + 1, : ), hxn ) ) ...
                 - An1.( member )( ii, 1 ) * norminv( cdf( pd_sn1.( member )( ii, : ), sn2 ) ) ...
                 - Dn1.( member )( ii, 1 ) * norminv( cdf( pd_hn1( 1, : ), h0 ) ) - Bn1.( member )( ii, 1 ) ) ...
                 / Tn1.( member )( ii, 1 ) );
            end 
        end 
        for j = 1:M
            Rand1 = rand;
            if p0 <= Th
                kk1 = find( W0( ii, : ) >= Rand1 );
            else 
                kk1 = find( W1( ii, : ) >= Rand1 );
            end 
            k1.( leadtime )( i, j ) = kk1( 1 );
            MS = [ 'M', num2str( k1.( leadtime )( i, j ) ) ];
            Rand2 = rand;
            kk2 = find( CDF.( MS ).( leadtime )( i, : ) >= Rand2 );
            if isempty( kk2 ) == 1
                kk2 = size( CDF.( MS ).( leadtime )( i, : ), 2 );
            end 
            k2.( leadtime )( i, j ) = kk2( 1 );
            BMAHUPR.( leadtime ).Ens( i, j ) = hxn( k2.( leadtime )( i, j ) );
        end 
    end 
end 

for ii = 1:n
    leadtime = [ 'LT', num2str( ii ) ];
    BMAHUPR.( leadtime ).Mean( :, 1 ) = mean( BMAHUPR.( leadtime ).Ens, 2 );
    BMAHUPR.( leadtime ).Median( :, 1 ) = median( BMAHUPR.( leadtime ).Ens, 2 );
    for i = 1:t
        [ Cdist( :, 1 ), Cdist( :, 2 ) ] = ecdf( BMAHUPR.( leadtime ).Ens( i, : ) );
        Cdist( 1, 2 ) = 0;
        bb1 = find( Cdist( :, 1 ) >= ( 1 - prc ) / 2, 1 );
        bb2 = find( Cdist( :, 1 ) <= 1 - ( 1 - prc ) / 2, 1, 'last' );
        BMAHUPR.( leadtime ).Interval( i, 1 ) = Cdist( bb1( 1 ), 2 );
        BMAHUPR.( leadtime ).Interval( i, 2 ) = Cdist( bb2( end  ), 2 );
        Cdist = [  ];bb1 = [  ];bb2 = [  ];
    end 
end 

end % end function [ BMAHUPR ] = HUPBMA_Forecast( An0, An1, Bn0, Bn1, Dn0, Dn1, Tn0, Tn1, pd_hn0, pd_hn1, pd_sn0, pd_sn1, w, hn, esn, precip, prc, Th )

% P2M software author QQ: 1205892765, for learning and communication purposes only, please comply with local laws!
