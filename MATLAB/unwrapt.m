% parameters

close all

N = 512;

ampPhase = 20;

noise = 0.5;

[x, y] = meshgrid(linspace(-1,1,N));

%% %%% (1) unweighted case

% original unwrapped phase

phi = exp(-(x.*x+y.*y)/2/0.2^2) * ampPhase + (x + y) * ampPhase/2;

% wrapped phase

psi = wrapToPi(phi + randn(size(phi))*noise);

% unweighted case

abc = tic;

phi2 = unwrap(psi);

% phi2 = unwrap('1c.bmp');
disp(sprintf('Unweighted phase unwrap of a %dx%d image takes %f seconds', N, N, toc(abc)));

% show the images

close all;

subplot(2,2,1);

imagesc(phi); title('Original phase');

subplot(2,2,2);

imagesc(psi); title('Wrapped phase with noise');

subplot(2,2,3);

imagesc(ones(N)); title('Weight');

subplot(2,2,4);

imagesc(phi2); title('Unwrapped phase');

%%%%% (2) now test the weighted case

weight = ones(N);

xregion = floor(N/4):floor(N/2);

yregion = floor(N/4):floor(N/2);

weight(yregion, xregion) = 0;

% change the zero-weighted region to noise only

psi3 = psi;

psi3(yregion, xregion) = randn([length(yregion), length(xregion)]);

% now unwrap

bac = tic;

phi3 = unwrap(psi3, weight);

disp(sprintf('Weighted phase unwrap of a %dx%d image takes %f seconds', N, N, toc(bac)));

% show the images

figure;

subplot(2,2,1);

imagesc(phi); title('Original phase');

subplot(2,2,2);

imagesc(psi3); title('Wrapped phase with noise');

subplot(2,2,3);

imagesc(weight); title('Weight');

subplot(2,2,4);

imagesc(phi3); title('Unwrapped phase');
