function beta=est_field_nobg(time,signal,win)
% Estimate field values
% from the signal sig
% without using backgound bg
%
% This method uses the derivative of the decay curves.
% One estimate per curve is producted.
%
% An inner product with g is used to compute the field values
%
% Because the inner product is linear the backgound field can be computed 
% using the smae method and the field values can be subtracted to compute
% the corrected measurments.
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

g=exp((-time{1}(win(1):win(2)).^0.1)/0.07);
g=-g/norm(g);
for i=1:length(signal)
    fprintf('%i ',i)
    sig=signal{i};
    d2 = ifft(repmat(h,[1 size(sig,2) size(sig,3)]).*fft(sig));
    d2p = d2;
    %find SVD to get "common" decay curve
    d2p2 = d2p(win(1):win(2),:,:);
    gp=repmat(g,[1 size(d2p2,2) size(d2p2,3)]);
    a = sum(d2p2.*gp,1);
    beta{i} = squeeze(a);
end
fprintf('\n')