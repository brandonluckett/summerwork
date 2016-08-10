% Stand alone example of jump removal and filtering

close all
clear all
% Load data
load /tmp/pegstandards_unfilterd.mat

% Print out series description of 1st series
Series_description{1}

figure(1);
plot(time{1},signal{1}(:,:,1));
title('1st Series, 1st channel')

%% Run edge detection and filter
opt=struct('harm_order',3,...
           'oversample',3, ...
           'lambda',0.01);

[jumps,iOp] = getJumpFunction(signal{1},time{1},opt);       
t=time{1};

figure(2);
plot(t,jumps(:,:,1));
title('1st Series, 1st channel jumps')

% subtract out jumps
figure(3);
av = signal{1} - cumsum(jumps);
plot(t,av(:,:,1));
title('1st Series, 1st channel corrected')

% Filter 60Hz
avfil=av(:,:); % re-arrange decay curves
avf = fft(avfil);
avfil = ifft(repmat(iOp.harmSmoothOp.PSFh,[1 size(avfil,2)]).*avf);
avfil = reshape(avfil,size(signal{1}));
t=t(1:end-2*iOp.m);
avfil=avfil(1:end-2*iOp.m,:,:); % Trim artifacts of periodic filter 
shift = mean(avfil((end-50):end,:,:),1);
avfil=avfil-repmat(shift,[size(avfil,1) 1 1]);

figure(4);
plot(t,avfil(:,:,1));
title('1st Series, 1st channel filtered')


