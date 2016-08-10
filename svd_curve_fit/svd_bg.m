function [ref mask]=svd_bg(data)
%%
av3=data-repmat(mean(data,1),[size(data,1) 1]); % zero mean for all traces
%%
%N=3;
mask=ones(size(av3,2),1);
ref=median(av3(:,mask==1),2);

if 0
    for i=1:10
        %[U, S, V]=svd(av3(:,mask==1));
        %PC=U*S; % Principal components
        %ref = sum(PC(:,1:N),2); % Take N PC's
        ref=median(av3(:,mask==1),2);
        if ref(end)>ref(1) % flip upside down if increasing
            ref=-ref;
        end
        % Fit each trace to SVD
        [Lalpha,Lbeta,Lrxy] = multiLinFit(repmat(ref,[1 size(av3,2)]),av3);

        % Mark everything outside of 2 stds
        mask = and(abs(Lbeta-mean(Lbeta))<2*std(Lbeta),abs(Lrxy)>.8);
    end
end