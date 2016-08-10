function [jumpf,iOp] = getJumpFunction(dat,time,opt)
% Get jump function approximation and the 
% smoothing operator

if not(exist('opt','var'))
    opt=struct();
end
lambda= get_opt(opt,'lambda',0.1);
eps= get_opt(opt,'eps',1e-6);
maxiter= get_opt(opt,'maxiter',1000);
th= get_opt(opt,'th',eps*2);
verbose =  get_opt(opt,'verbose',0);

% get kernels
iOp = getEdgeKernel(time,opt);
dt2 = dat(:,:);
dt2 = dt2-repmat(mean(dt2,1),[size(dt2,1) 1]);
%Edge detecton using edge kernel
Lx = ifft(repmat(iOp.edgeOp.PSFh,[1 size(dt2,2)]).*fft(dt2));
% Remove oscillations using matchOp
norm = max(abs(Lx(:)));
jumpf = L1_decon_par(Lx / norm,iOp.matchOp,lambda,eps,verbose,maxiter)*norm;
jumpf(1:iOp.m,:)=0; %% set edge from periodic assumption to zero
jumpf = jumpf.*(abs(jumpf)>th);
jumpf = reshape(jumpf,size(dat));
