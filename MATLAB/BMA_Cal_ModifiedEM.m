function [ Weight ] = BMA_Cal_ModifiedEM( hn, esn, precip, An0, An1, Bn0, Bn1, Dn0, Dn1, Tn0, Tn1, pd_hn0, pd_hn1, pd_sn0, pd_sn1, Th )

n = size( hn, 2 ) - 1;
[ PDF, CDF, L0 ] = Likelihood_HUP( hn, esn, precip, An0, An1, Bn0, Bn1, Dn0, Dn1, Tn0, Tn1, pd_hn0, pd_hn1, pd_sn0, pd_sn1, Th );
index_n0 = precip( :, 1 ) <= Th;
index_n1 = precip( :, 1 ) > Th;
for j = 0:1
    eval( sprintf( 'temp1 = index_n%d;', j ) );
    for i = 1:n
        leadtime = [ 'LT', num2str( i ) ];
        temp2 = L0.( leadtime )( temp1, : );
        [ LLT.( [ 'P', num2str( j ) ] )( i, : ), Weight.( [ 'P', num2str( j ) ] )( i, : ) ] = ModifiedEM( temp2 );
        temp2 = [  ];
    end 
    temp1 = [  ];
end 

end % end function [ Weight ] = BMA_Cal_ModifiedEM( hn, esn, precip, An0, An1, Bn0, Bn1, Dn0, Dn1, Tn0, Tn1, pd_hn0, pd_hn1, pd_sn0, pd_sn1, Th )

%%

function [ PDF, CDF, L0 ] = Likelihood_HUP( hn, esn, precip, An0, An1, Bn0, Bn1, Dn0, Dn1, Tn0, Tn1, pd_hn0, pd_hn1, pd_sn0, pd_sn1, Th )

n = size( hn, 2 ) - 1;
m = numel( fieldnames( esn ) );
for k = 1:m
    member = [ 'M', num2str( k ) ];
    for j = 1:n
        for i = 1:length( hn )
            h0 = hn( i, 1 );
            hh = hn( i, j + 1 );
            ss = esn.( member )( i, j );
            p0 = precip( i, 1 );
            if p0 <= Th
                CDF.( member )( i, j ) = normcdf( ( norminv( cdf( pd_hn0( j + 1, : ), hh ) ) ...
                 - An0.( member )( j, 1 ) * norminv( cdf( pd_sn0.( member )( j, : ), ss ) ) ...
                 - Dn0.( member )( j, 1 ) * norminv( cdf( pd_hn0( 1, : ), h0 ) ) - Bn0.( member )( j, 1 ) ) ...
                 / Tn0.( member )( j, 1 ) );
                PDF.( member )( i, j ) = ( pdf( pd_hn0( j + 1, : ), hh ) * normpdf( norminv( CDF.( member )( i, j ) ) ) ) ...
                 / ( Tn0.( member )( j, 1 ) * normpdf( norminv( cdf( pd_hn0( j + 1, : ), hh ) ) ) );
            else 
                CDF.( member )( i, j ) = normcdf( ( norminv( cdf( pd_hn1( j + 1, : ), hh ) ) ...
                 - An1.( member )( j, 1 ) * norminv( cdf( pd_sn1.( member )( j, : ), ss ) ) ...
                 - Dn1.( member )( j, 1 ) * norminv( cdf( pd_hn1( 1, : ), h0 ) ) - Bn1.( member )( j, 1 ) ) ...
                 / Tn1.( member )( j, 1 ) );
                PDF.( member )( i, j ) = ( pdf( pd_hn1( j + 1, : ), hh ) * normpdf( norminv( CDF.( member )( i, j ) ) ) ) ...
                 / ( Tn1.( member )( j, 1 ) * normpdf( norminv( cdf( pd_hn1( j + 1, : ), hh ) ) ) );
            end 
        end 
    end 
end 
for j = 1:n
    leadtime = [ 'LT', num2str( j ) ];
    for k = 1:m
        member = [ 'M', num2str( k ) ];
        L0.( leadtime )( :, k ) = PDF.( member )( :, j );
    end 
end

end % end function  [ PDF, CDF, L0 ] = Likelihood_HUP( hn, esn, precip, An0, An1, Bn0, Bn1, Dn0, Dn1, Tn0, Tn1, pd_hn0, pd_hn1, pd_sn0, pd_sn1, Th )

%%

function [ LLTAll, Weight ] = ModifiedEM( L0 )

m = size( L0, 2 );
n = size( L0, 1 );
T = 0.0000001;
w( 1:m ) = 1 / m;
L0( L0 == 0 ) = 0.0000000001;
L1 = L0 .* w;
L2 = sum( L1, 2 );
LogL = log( L2 );
LLT = sum( LogL );
LLT2 = LLT + 1;
tt = 0;
while abs( LLT - LLT2 ) > T
    LLT2 = LLT;
    tt = tt + 1;
    wtemp = w;
    z = bsxfun( @rdivide, L1, L2 );
    w = sum( z ) / n;
    cond1 = find( w == 0 );
    if isempty( cond1 ) == 0
        w = wtemp;
    break 
    end 
    L1 = L0 .* w;
    L2 = sum( L1, 2 );
    LogL = log( L2 );
    LLT = sum( LogL );
    if tt == 10000
        w = wtemp;
    break 
    end 
end 
Weight( 1, : ) = w;
LLTAll( 1, : ) = LLT;

end % end function [ LLTAll, Weight ] = ModifiedEM( L0 )

% P2M software author QQ: 1205892765, for learning and communication purposes only, please comply with local laws!
