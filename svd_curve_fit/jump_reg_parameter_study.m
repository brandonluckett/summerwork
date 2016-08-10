% Stand alone example of jump removal and filtering

close all
clear all
% Load data
load /tmp/pegstandards_unfilterd.mat

ser=4;
% Print out series description of 1st series
Series_description{ser}

%% Run edge detection and filter
X = signal{ser};
t = time{ser};

lambdas=logspace(-3,0,100);
mn = zeros(length(lambdas),size(signal{ser},3)); % space for mean 
md = mn; % space for median
for ii=1:length(lambdas)
    ii
    lambda = lambdas(ii)
    opt=struct('harm_order',3,...
               'oversample',3, ...
               'lambda',lambda);
    % run jump detection
    [jumps,iOp] = getJumpFunction(,,opt);       
    t=time{ser};
    av = signal{ser} - cumsum(jumps);

    % Filter 60Hz
    avfil=av(:,:); % re-arrange decay curves
    avf = fft(avfil);
    avfil = ifft(repmat(iOp.harmSmoothOp.PSFh,[1 size(avfil,2)]).*avf);
    avfil = reshape(avfil,size(signal{ser}));
    t=t(1:end-2*iOp.m);
    avfil=avfil(1:end-2*iOp.m,:,:); % Trim artifacts of periodic filter 
    %shift = mean(avfil((end-50):end,:,:),1);
    shift = mean(avfil(10:end,:,:),1);
    avfil=avfil-repmat(shift,[size(avfil,1) 1 1]);
    N=size(av,2);
   
    [I,J]=meshgrid(1:N,1:N);    
    for ch=1:size(signal{1},3);
        D=arrayfun(@(i,j)norm(avfil(10:end,i,ch)-avfil(10:end,j,ch)),I,J).^2;
        mn(ii,ch) = mean(D(:));
        md(ii,ch) = median(D(:));    
    end
end
%% Plot
colors={'b','m','k','c','g','r'};
figure(1)
hold on
leg=[];
for ch=1:6
    % plot(log(lambdas),log(mn(:,ch)),[colors(ch) ':'],log(lambdas),log(md(:,2)),colors(ch))
    plot(log(lambdas),log(md(:,ch)),colors{ch})
    leg=[leg; sprintf('Channel %i',ch)];
end
legend(leg)
xlabel('log(\lambda)');
ylabel('log(Median)');

