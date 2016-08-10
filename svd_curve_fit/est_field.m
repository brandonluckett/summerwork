function [beta res]=est_field(time,signal,BG_Series,channel_mask,win)
% Estimate field values
% from the signal sig
% without using backgound bg
%
% This method uses the derivative of the decay curves.
% One estimate per curve is producted.
%
% An inner product with g is used to compute the field values
% 
% The decay rate is estimated using an estimated referce curve g
%
% 

if not(exist('win','var'))
    win=[25 1000];
end 
if not(exist('channel_mask','var'))
  channel_mask=ones(size(signal{1},3));
end 
% construct derivative kernel
opt=struct('poly_order',3,'harm_order',3,'oversample',4,'harm_base',60);
iOp = getEdgeKernel(time{1},opt);
h = fft(iOp.diffSmoothOp.PSF);
% apply kernel to signal and background
beta=cell(length(signal),1);
res=cell(length(signal),1);
g=exp((-time{1}(win(1):win(2)).^0.1)/0.07);
g=-g/norm(g);
for i=1:length(signal)
    fprintf('%i ',i)
    bgnr=BG_Series(i);
    if bgnr>0
        sig=signal{i};
        bg =signal{bgnr};
        d2 = ifft(repmat(h,[1 size(sig,2) size(sig,3)]).*fft(sig));
        bg = ifft(repmat(h,[1 size(bg ,2) size(bg ,3)]).*fft(bg ));
        % subtract background from signal
        bg = mean(bg,2); 
        %bg = median(bg,2); 
        d2p = d2-repmat(bg,[1 size(sig,2) 1]);

        if 0
          %find SVD to get "common" decay curve
          d2p2 = d2p(win(1):win(2),:,channel_mask(1,:)==1);
          [U,S,V] = svd(squeeze(d2p2(:,:)));
          g = U(:,1);
          % normalize refernce curve in window
          g=g/norm(g);
        else
          % use canned reference function
          d2p2 = d2p(win(1):win(2),:,channel_mask(1,:)==1);
          gp=repmat(g,[1 size(d2p2,2) size(d2p2,3)]);
        end
        a=sum(d2p2.*gp,1);
        beta{i} = squeeze(a);
        res{i} = squeeze(sqrt(sum((d2p2-repmat(a,[size(d2p2,1) 1 1]).*gp).^2,1)));
    end
end
fprintf('\n')