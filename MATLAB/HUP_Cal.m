function [ An0, An1, Bn0, Bn1, Dn0, Dn1, Tn0, Tn1, pd_hn0, pd_hn1, pd_sn0, pd_sn1 ] = HUP_Cal( hnc, esnc, obspc, Th, NQTT, ltn )
% 该程序考虑了是否与降雨问题，将样本分为两类进行HUP模型参数率定。
% hnc is hn.Cal; esnc is esn.Cal; obspc is obs.Cal; for calbration 
% Th for No precipitation or precipitation
% (1) ---识别预见期个数和预报模型数量--------------------------------------------------------------------------------------------------------------------------------------
n = size( hnc, 2 ) - 1; % hnc includes h0,h1,h2,......hN, n is leadtime number (N);
m = numel( fieldnames( esnc ) ); % model number----
% (2)----根据降雨阈值将实测流量和模型模拟的流量系列分为不同类样本，如无雨日、有雨日样本------------------------------------------------------------------------------------------
index_n0 = obspc( :, 1 ) <= Th; % No precipitation
index_n1 = obspc( :, 1 ) > Th; % with precipitation
hn0 = hnc( index_n0, : ); % observed flow samples with No precipitation
hn1 = hnc( index_n1, : );% observed flow samples with  precipitation
for k = 1:m
    member = [ 'M', num2str( k ) ]; % model name
    sn0.( member ) = esnc.( member )( index_n0, : );  % simulated flow samples with No precipitation
    sn1.( member ) = esnc.( member )( index_n1, : ); % simulated flow samples with  precipitation
end
%（3）----用于边际分布函数拟合的备选函数------------------------------------------------------------------------------------------------------------------------------------
testdists = { 'BirnbaumSaunders', 'Gamma', 'GeneralizedExtremeValue',  ...
'GeneralizedPareto', 'InverseGaussian', 'Kernel',  ...
'Loglogistic', 'Lognormal', 'Normal', 'Weibull' }';
%（4）----为h0,,h1,......,hn；不同模型M(k)不同预见期(j)的sn确定最优分布,分无雨和有雨样本-------------------------------------------------------------------------------------
for i = 0:1 % No Precipittaion(0) or Precipittaion (1)
    for j = 1:n + 1 % hn including h0, n leadtimeNumber
        eval( sprintf( 'temp1 = hn%d(:,j);', i ) ); % run hni(:,j),i.e.,hn0(:,2)
        [ swstat1, select1, ~ ] = msw_select_probDist( temp1, 0.05, 0, testdists );
        eval( sprintf( 'dist_h%d(1,j) = testdists(select1 == 1);', i ) ); %among functions in testdists, one with the 1 index in select is the best one,
        eval( sprintf( 'swstat_h%d(:,j) = swstat1;', i ) );    
            if j < n + 1 % leadtimes number=n-1
                for k = 1:m
                    member = [ 'M', num2str( k ) ]; % differn mode (Mk) and different leadtime j
                    eval( sprintf( 'temp2 = sn%d.(member)(:,j);', i ) ); % different model, jth leadtime
                    [ swstat2, select2, ~ ] = msw_select_probDist( temp2, 0.05, 0, testdists );
                    eval( sprintf( 'dist_s%d.(member)(1,j) = testdists(select2 == 1);', i ) );
                    eval( sprintf( 'swstat_s%d.(member)(:,j) = swstat2;', i ) );
                end 
            end 
    end 
end 
%（5）----采用最优分布去获得h0,,h1,......,hn、不同模型M(k)不同预见期(j)的sn的确定最优分布的句柄pd，分无雨和有雨样本-------------------------------------------------------------
for i = 1:n + 1
    pd_hn0( i, : ) = fitdist( hn0( :, i ), char( dist_h0( i ) ) ); % dist_h0 including the best function for each i, to obtain function object
    pd_hn1( i, : ) = fitdist( hn1( :, i ), char( dist_h1( i ) ) );
    if i < n + 1
        for k = 1:m
            member = [ 'M', num2str( k ) ];
            pd_sn0.( member )( i, : ) = fitdist( sn0.( member )( :, i ), char( dist_s0.( member )( i ) ) );            
            pd_sn1.( member )( i, : ) = fitdist( sn1.( member )( :, i ), char( dist_s1.( member )( i ) ) );        
        end 
    end 
end
%（6）----parametric function，根据最优分布去计算h0,,h1,......,hn、不同模型M(k)不同预见期(j)的sn对应的p值，为转化到正态空间，分无雨和有雨样本-----------------------------------
for i = 1:n + 1
    cdf_hn0( :, i ) = cdf( pd_hn0( i, : ), hn0( :, i ) );
    cdf_hn1( :, i ) = cdf( pd_hn1( i, : ), hn1( :, i ) );
    if i < n + 1
        for k = 1:m
            member = [ 'M', num2str( k ) ];
            cdf_sn0.( member )( :, i ) = cdf( pd_sn0.( member )( i, : ), sn0.( member )( :, i ) );
            cdf_sn1.( member )( :, i ) = cdf( pd_sn1.( member )( i, : ), sn1.( member )( :, i ) );
        end 
    end 
end 
%（7）----emperical function，根据ecdf去计算h0,,h1,......,hn、不同模型M(k)不同预见期(j)的sn对应的p值，为转化到正态空间，分无雨和有雨样本---------------------------------------
for i = 1:n + 1
    [ temp3, temp4 ] = ecdf( hn0( :, i ) );% 会比原样本多一行 0，在第一行
    temp3( 1, : ) = [  ];temp4( 1, : ) = [  ]; % 去掉第一行 
    for j = 1:size( hn0, 1 )
        cdf2_hn0( j, i ) = temp3( find( temp4 == hn0( j, i ) ) ); % 从temp4（从小到大排过序了，打乱了原样本）找到hn对应的下标，提取其p值，即为hn对应的ecdf值
    end 
    temp3 = [  ];temp4 = [  ]; % 该部分太耗时，可以改进。
end
for i = 1:n + 1
    [ temp3, temp4 ] = ecdf( hn1( :, i ) );temp3( 1, : ) = [  ];temp4( 1, : ) = [  ];
    for j = 1:size( hn1, 1 )
        cdf2_hn1( j, i ) = temp3(find( temp4 == hn1( j, i ) ) );    
    end 
    temp3 = [  ];temp4 = [  ];
end
for i = 1:n
    for k = 1:m
        member = [ 'M', num2str( k ) ];
        [ temp3, temp4 ] = ecdf( sn0.( member )( :, i ) );temp3( 1, : ) = [  ];temp4( 1, : ) = [  ];
            for j = 1:size( sn0.( member ), 1 )
                cdf2_sn0.( member )( j, i ) = temp3( find( temp4 == sn0.( member )( j, i ) ) );            
            end 
        temp3 = [  ];temp4 = [  ];
    end 
end 
for i = 1:n
    for k = 1:m
        member = [ 'M', num2str( k ) ];
        [ temp3, temp4 ] = ecdf( sn1.( member )( :, i ) );temp3( 1, : ) = [  ];temp4( 1, : ) = [  ];
        for j = 1:size( sn1.( member ), 1 )
            cdf2_sn1.( member )( j, i ) = temp3( find( temp4 == sn1.( member )( j, i ) ) );
        end 
        temp3 = [  ];temp4 = [  ];
    end 
end 
cdf2_hn0 = cdf2_hn0 .* ( size( cdf2_hn0, 1 ) / ( size( cdf2_hn0, 1 ) + 1 ) ); % 缩放下
cdf2_hn1 = cdf2_hn1 .* ( size( cdf2_hn1, 1 ) / ( size( cdf2_hn1, 1 ) + 1 ) );
for k = 1:m
    member = [ 'M', num2str( k ) ];
    cdf2_sn0.( member ) = cdf2_sn0.( member ) .* ( size( cdf2_sn0.( member ), 1 ) / ( size( cdf2_sn0.( member ), 1 ) + 1 ) );
    cdf2_sn1.( member ) = cdf2_sn1.( member ) .* ( size( cdf2_sn1.( member ), 1 ) / ( size( cdf2_sn1.( member ), 1 ) + 1 ) );
end 
%（8）----以上计算出non-parateric 和 parametric 两种分布时对应的p值，接下来转化到正态空间-------------------------------------------------------------------------------------------
switch NQTT
    case 0  %  parametric cdf 
        for i = 1:n + 1
            wn0( :, i ) = norminv( cdf_hn0( :, i ) );
            wn1( :, i ) = norminv( cdf_hn1( :, i ) );
            if i < n + 1
                for k = 1:m
                    member = [ 'M', num2str( k ) ];
                    xn0.( member )( :, i ) = norminv( cdf_sn0.( member )( :, i ) );
                    xn1.( member )( :, i ) = norminv( cdf_sn1.( member )( :, i ) );
                end 
            end 
        end 
    case 1 % Empirical non-parametric cdf
        for i = 1:n + 1
            wn0( :, i ) = norminv( cdf2_hn0( :, i ) );
            wn1( :, i ) = norminv( cdf2_hn1( :, i ) );
            if i < n + 1
                for k = 1:m
                    member = [ 'M', num2str( k ) ];
                    xn0.( member )( :, i ) = norminv( cdf2_sn0.( member )( :, i ) );
                    xn1.( member )( :, i ) = norminv( cdf2_sn1.( member )( :, i ) );
                end 
            end 
        end 
end
%（9）---计算参数c值，并根据相关系数阈值，低于该阈值时，不考虑相关性c=0，独立处理------------------------------------------------------------------------------------------
for i = 1:n
    if i < ltn
        cn0( i, 1 ) = regress( wn0( :, i + 1 ), wn0( :, i ) ); % w(n)=c*w(n-1)
        cn1( i, 1 ) = regress( wn1( :, i + 1 ), wn1( :, i ) );
    else 
        cn0( i, 1 ) = 0;
        cn1( i, 1 ) = 0;
    end 
end 
%（10）---计算其他参数----------------------------------------------------------------------------------------------------------------------------------------------
for k = 1:m
    member = [ 'M', num2str( k ) ];
    for i = 1:n
        if i < ltn
            badn0.( member )( :, i ) = regress( xn0.( member )( :, i ), [ ones( size( wn0( :, i + 1 ) ) ), wn0( :, i + 1 ), wn0( :, 1 ) ] );
            badn1.( member )( :, i ) = regress( xn1.( member )( :, i ), [ ones( size( wn1( :, i + 1 ) ) ), wn1( :, i + 1 ), wn1( :, 1 ) ] );
        else 
            badn0.( member )( 1:2, i ) = regress( xn0.( member )( :, i ), [ ones( size( wn0( :, i + 1 ) ) ), wn0( :, i + 1 ) ] );
            badn1.( member )( 1:2, i ) = regress( xn1.( member )( :, i ), [ ones( size( wn1( :, i + 1 ) ) ), wn1( :, i + 1 ) ] );
            badn0.( member )( 3, i ) = 0;
            badn1.( member )( 3, i ) = 0;
        end 
    end 
    badn0.( member ) = badn0.( member )';badn1.( member ) = badn1.( member )';
end 
for k = 1:m
    member = [ 'M', num2str( k ) ];
    for i = 1:n
        Exn0.( member )( :, i ) = badn0.( member )( i, 1 ) + badn0.( member )( i, 2 ) * wn0( :, i + 1 ) + badn0.( member )( i, 3 ) * wn0( :, 1 );
        Exn1.( member )( :, i ) = badn1.( member )( i, 1 ) + badn1.( member )( i, 2 ) * wn1( :, i + 1 ) + badn1.( member )( i, 3 ) * wn1( :, 1 );
    end 
end 
for k = 1:m
    member = [ 'M', num2str( k ) ];
    for i = 1:n
        sigman0_2.( member )( i, 1 ) = sum( ( xn0.( member )( :, i ) - Exn0.( member )( :, i ) ) .* ( xn0.( member )( :, i ) - Exn0.( member )( :, i ) ) ) / ( length( xn0.( member ) ) - 1 );
        sigman1_2.( member )( i, 1 ) = sum( ( xn1.( member )( :, i ) - Exn1.( member )( :, i ) ) .* ( xn1.( member )( :, i ) - Exn1.( member )( :, i ) ) ) / ( length( xn1.( member ) ) - 1 );
    end 
end 
for i = 1:n
    Cn0( i, 1 ) = prod( cn0( 1:i, 1 ) );
    Cn1( i, 1 ) = prod( cn1( 1:i, 1 ) );
end 
tn0_2 = 1 - Cn0 .* Cn0;
tn1_2 = 1 - Cn1 .* Cn1;
%（11）---计算HUP的参数----------------------------------------------------------------------------------------------------------------------------------------------
for k = 1:m
    member = [ 'M', num2str( k ) ];
    An0.( member ) = ( badn0.( member )( :, 2 ) .* tn0_2 ) ./ ( ( ( badn0.( member )( :, 2 ) .* badn0.( member )( :, 2 ) ) .* tn0_2 ) + sigman0_2.( member ) );
    An1.( member ) = ( badn1.( member )( :, 2 ) .* tn1_2 ) ./ ( ( ( badn1.( member )( :, 2 ) .* badn1.( member )( :, 2 ) ) .* tn1_2 ) + sigman1_2.( member ) );
    Bn0.( member ) = (  - badn0.( member )( :, 2 ) .* badn0.( member )( :, 1 ) .* tn0_2 ) ./ ( ( ( badn0.( member )( :, 2 ) .* badn0.( member )( :, 2 ) ) .* tn0_2 ) + sigman0_2.( member ) );
    Bn1.( member ) = (  - badn1.( member )( :, 2 ) .* badn1.( member )( :, 1 ) .* tn1_2 ) ./ ( ( ( badn1.( member )( :, 2 ) .* badn1.( member )( :, 2 ) ) .* tn1_2 ) + sigman1_2.( member ) );
    Dn0.( member ) = ( ( Cn0 .* sigman0_2.( member ) ) - ( badn0.( member )( :, 2 ) .* badn0.( member )( :, 3 ) .* tn0_2 ) ) ./ ( ( ( badn0.( member )( :, 2 ) .* badn0.( member )( :, 2 ) ) .* tn0_2 ) + sigman0_2.( member ) );
    Dn1.( member ) = ( ( Cn1 .* sigman1_2.( member ) ) - ( badn1.( member )( :, 2 ) .* badn1.( member )( :, 3 ) .* tn1_2 ) ) ./ ( ( ( badn1.( member )( :, 2 ) .* badn1.( member )( :, 2 ) ) .* tn1_2 ) + sigman1_2.( member ) );
    Tn0.( member ) = sqrt( ( tn0_2 .* sigman0_2.( member ) ) ./ ( ( ( badn0.( member )( :, 2 ) .* badn0.( member )( :, 2 ) ) .* tn0_2 ) + sigman0_2.( member ) ) );
    Tn1.( member ) = sqrt( ( tn1_2 .* sigman1_2.( member ) ) ./ ( ( ( badn1.( member )( :, 2 ) .* badn1.( member )( :, 2 ) ) .* tn1_2 ) + sigman1_2.( member ) ) );
end 

end % end function [ An0, An1, Bn0, Bn1, Dn0, Dn1, Tn0, Tn1, pd_hn0, pd_hn1, pd_sn0, pd_sn1 ] = HUP_Cal( hnc, esnc, obspc, Th, NQTT, ltn )

%% to selected the best function for series x with the alpha-significance from the testdists

function [ varargout ] = msw_select_probDist( x, alpha, plotFlag, testdists )
% plotFlag: if to plot, 0 or 1
if numel( x ) ~= length( x )
    error( 'X must be a vector' );
end 
[ r, c ] = size( x );
if c > r
    x = x';% N leadtimes N colums, 防止矩阵错误
end 
if ~isempty( alpha )
    if ~isscalar( alpha )
        error( ' Significance level ''Alpha'' must be a scalar.' );
    end 
    if ( alpha <= 0 || alpha >= 1 )
        error( ' Significance level ''Alpha'' must be between 0 and 1.' );
    end 
else 
    alpha = 0.05;
end 
if ~isempty( plotFlag )
    if ~isscalar( plotFlag )
        error( 'PlotFlag must be a 0 or 1 value' )
    end 
    if ( plotFlag ~= 0 && plotFlag ~= 1 )
        error( 'PlotFlag must be a 0 or 1 value' )
    end 
else 
    plotFlag = 0;% defauut
end
ndist = length( testdists );
for n = 1:ndist
    checkdist( testdists{ n } );
end 
swstat = zeros( ndist, 1 );% Shapiro-Wilk test, each cdf has corresponding swstat value
select = zeros( ndist, 1 );
alldist = struct( [  ] );
names = cell( 1 + ndist, 1 );
names{ 1 } = 'Obs';
for n = 1:ndist
    [ ~, alldist( n ).pValue, alldist( n ).swstat, alldist( n ).pd ] = mswtest( x, testdists{ n }, alpha );
    swstat( n ) = alldist( n ).swstat;
    alldist( n ).name = testdists{ n };
    names{ n + 1 } = [ alldist( n ).name, ': ', num2str( swstat( n ) ) ];
end 
best = find( swstat == max( swstat ) );
select( best ) = 1; % the best with 1, others is 0
bestdist = alldist( best );
varargout{ 1 } = swstat;
varargout{ 2 } = select;
varargout{ 3 } = bestdist;
varargout{ 4 } = alldist;
if plotFlag
    figure
    [ f_x, xx ] = ecdf( x );
    scatter( xx, f_x, 'xk', 'MarkerEdgeAlpha', 0.5 );
    hold on
    for n = 1:ndist
        plot( xx, cdf( alldist( n ).pd, xx ) )
    end     
    legend( names, 'Location', 'southeast' );
    set( gcf, 'Color', 'w' )
    xlabel( 'Values' )
    ylabel( 'Cumulative Probability' );
    title( [ 'MSW best fit: ', testdists{ best } ] );
    box on
    grid on    
end 
end % end function [ varargout ] = msw_select_probDist( x, alpha, plotFlag, testdists )

%% to check if the used function is listed in the funtion list

function checkdist( dname )

validnames = { 'Beta', 'Binomial', 'BirnbaumSaunders', 'Burr', 'Exponential',  ...
'ExtremeValue', 'Gamma', 'GeneralizedExtremeValue', 'GeneralizedPareto',  ...
'InverseGaussian', 'Kernel', 'Logistic', 'Loglogistic', 'Lognormal', 'Multinomial',  ...
'Nakagami', 'NegativeBinomial', 'Normal', 'Poisson', 'Rayleigh', 'Rician', 'tLocationScale',  ...
'Weibull' };
idx = zeros( length( validnames ), 1 );
for i = 1:length( validnames )
    idx( i ) = strcmpi( validnames{ i }, dname );
end 
if sum( idx ) == 0
    msg = [ 'The distribution ', dname, ' is not a valid selection' ];
    error( msg );
end 
end % end function checkdist( dname )

%% the function dist to fit the series x and if it is alpha-significant 

function [ h, p, s, pd ] = mswtest( x, dist, alpha )

narginchk( 2, 3 ) % input variable is between 2-3， or error
if numel( x ) ~= length( x )
    error( 'X must be a vector' );
end 
[ r, c ] = size( x );
if c > r
    x = x'; % N leadtimes N colums, 防止矩阵错误
   
end 
if ( nargin >= 3 ) && ~isempty( alpha )
    if ~isscalar( alpha ) % 是不是数字
        error( ' Significance level ''Alpha'' must be a scalar.' );
    end 
    if ( alpha <= 0 || alpha >= 1 )
        error( ' Significance level ''Alpha'' must be between 0 and 1.' );
    end 
else 
    alpha = 0.05;
end 
pd = fitdist( x, dist ); % matlab in-function，pd is object
p = cdf( pd, x ); % using pd to calculate the p of the values x
p_norm = norminv( p );
[ h, p, s ] = swtest( p_norm, alpha );

end % end function [ h, p, s, pd ] = mswtest( x, dist, alpha )

%% Shapiro-Wilk test for fitting significance

function [ H, pValue, W ] = swtest( x, alpha )

if numel( x ) == length( x )
    x = x( : );
else 
    error( ' Input sample ''X'' must be a vector.' );
end 
x = x( ~isnan( x ) );
if length( x ) < 3
    error( ' Sample vector ''X'' must have at least 3 valid observations.' );
end 
if length( x ) > 5000
    warning( 'Shapiro-Wilk test might be inaccurate due to large sample size ( > 5000).' );
end 
if ( nargin >= 2 ) && ~isempty( alpha )
    if ~isscalar( alpha )
        error( ' Significance level ''Alpha'' must be a scalar.' );
    end 
    if ( alpha <= 0 || alpha >= 1 )
        error( ' Significance level ''Alpha'' must be between 0 and 1.' );
    end 
else 
    alpha = 0.05;
end 
x = sort( x );
n = length( x );
mtilde = norminv( ( ( 1:n )' - 3 / 8 ) / ( n + 1 / 4 ) );
weights = zeros( n, 1 );
if kurtosis( x ) > 3 % 峰度值
    weights = 1 / sqrt( mtilde' * mtilde ) * mtilde;
    W = ( weights' * x ) ^ 2 / ( ( x - mean( x ) )' * ( x - mean( x ) ) );
    nu = log( n );
    u1 = log( nu ) - nu;
    u2 = log( nu ) + 2 / nu;
    mu =  - 1.2725 + ( 1.0521 * u1 );
    sigma = 1.0308 - ( 0.26758 * u2 );
    newSFstatistic = log( 1 - W );
    NormalSFstatistic = ( newSFstatistic - mu ) / sigma;
    pValue = 1 - normcdf( NormalSFstatistic, 0, 1 );
else 
    c = 1 / sqrt( mtilde' * mtilde ) * mtilde;
    u = 1 / sqrt( n );
    PolyCoef_1 = [  - 2.706056, 4.434685,  - 2.071190,  - 0.147981, 0.221157, c( n ) ];
    PolyCoef_2 = [  - 3.582633, 5.682633,  - 1.752461,  - 0.293762, 0.042981, c( n - 1 ) ];
    PolyCoef_3 = [  - 0.0006714, 0.0250540,  - 0.39978, 0.54400 ];
    PolyCoef_4 = [  - 0.0020322, 0.0627670,  - 0.77857, 1.38220 ];
    PolyCoef_5 = [ 0.00389150,  - 0.083751,  - 0.31082,  - 1.5861 ];
    PolyCoef_6 = [ 0.00303020,  - 0.082676,  - 0.48030 ];
    PolyCoef_7 = [ 0.459,  - 2.273 ];
    weights( n ) = polyval( PolyCoef_1, u );
    weights( 1 ) =  - weights( n );
    if n > 5
        weights( n - 1 ) = polyval( PolyCoef_2, u );
        weights( 2 ) =  - weights( n - 1 );    
        count = 3;
        phi = ( mtilde' * mtilde - 2 * mtilde( n ) ^ 2 - 2 * mtilde( n - 1 ) ^ 2 ) /  ...
        ( 1 - 2 * weights( n ) ^ 2 - 2 * weights( n - 1 ) ^ 2 );
    else 
        count = 2;
        phi = ( mtilde' * mtilde - 2 * mtilde( n ) ^ 2 ) /  ...
        ( 1 - 2 * weights( n ) ^ 2 );
    end
    if n == 3    
        weights( 1 ) = 1 / sqrt( 2 );
        weights( n ) =  - weights( 1 );
        phi = 1;
    end 
    weights( count:n - count + 1 ) = mtilde( count:n - count + 1 ) / sqrt( phi );
    W = ( weights' * x ) ^ 2 / ( ( x - mean( x ) )' * ( x - mean( x ) ) );
    newn = log( n );
    if ( n >= 4 ) && ( n <= 11 )    
        mu = polyval( PolyCoef_3, n );
        sigma = exp( polyval( PolyCoef_4, n ) );
        gam = polyval( PolyCoef_7, n );    
        newSWstatistic =  - log( gam - log( 1 - W ) );    
    elseif n > 11    
        mu = polyval( PolyCoef_5, newn );
        sigma = exp( polyval( PolyCoef_6, newn ) );    
        newSWstatistic = log( 1 - W );    
    elseif n == 3
        mu = 0;
        sigma = 1;
        newSWstatistic = 0;
    end 
    NormalSWstatistic = ( newSWstatistic - mu ) / sigma;
    pValue = 1 - normcdf( NormalSWstatistic, 0, 1 );
    if n == 3
        pValue = 6 / pi * ( asin( sqrt( W ) ) - asin( sqrt( 3 / 4 ) ) );    
    end 
end 
H = ( alpha >= pValue );
end % end function [ H, pValue, W ] = swtest( x, alpha )

% P2M software author QQ: 1205892765, for learning and communication purposes only, please comply with local laws!
