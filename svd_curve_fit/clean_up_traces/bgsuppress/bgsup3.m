function xhat=bgsup3(ph,weight,opt)
%% unwrapping and background phase removal
% phi           input phase
% weights       for each pixel
% opt.order     for edge detector
%   1           ... no edge detection, just unwrap signal
%   >=2         ... use "edge" detection, unwrap and remove background
% opt.nth       regularization paramter
% opt.eps       stopping eps
% opt.maxiter   maximum number of iterations
% opt.x0        || x0 - x ||_1 is minimized
%
% wstefan@mdanderson.org

sz= size(ph);
if not(exist('opt','var'))
    opt = struct();
end
zeros_cmd  = get_opt(opt,'zeros',@zeros);
initx0  = get_opt(opt,'x0',zeros_cmd(sz));
order   = get_opt(opt,'order',3);
nth     = get_opt(opt,'nth',1e-6);
lambda  = get_opt(opt,'lambda',1e-8);
eps     = get_opt(opt,'eps',0.01);
maxiter = get_opt(opt,'maxiter',100);
unwrap  = get_opt(opt,'unwrap',1);
refl  = get_opt(opt,'reflect',1);
verbose = get_opt(opt,'verbose',1);
H  = get_opt(opt,'H',Convolution.eye(size(ph)));

if and(unwrap,abs(max(ph(:))-min(ph(:))-2*pi)>1e-2)
    disp('WARNING: Phase does not seem to be from -pi to pi')
end
if sum(abs(imag(weight(:))))>1e-2
    disp('WARNING: Weight seems to be complex')
end

if or(order==1,refl)
    if length(nth)>1
        nth=reflect(nth,opt);
    end
    ph=reflect(ph,opt);
    weight=reflect(weight,opt);
    initx0=reflect(initx0,opt);
    H2=zeros(sz*2);
    if length(sz)>2
        H2(1:sz(1),1:sz(2),1:sz(3))=circshift(H.PSF,sz/2);
    else
        H2(1:sz(1),1:sz(2))=circshift(H.PSF,sz/2);
    end
    H = Convolution(circshift(H2,-sz/2));
    clear H2
end
sz= size(ph);

if length(sz)==2
    sz=[sz 1];
    odd=0;
else
    if mod(sz(3),2)==1 %% odd number of slices
        sz(3)=sz(3)+1;
        z=zeros_cmd(sz(1),sz(2));
        ph(:,:,sz(3))=z;
        weight(:,:,sz(3))=z;
        odd=1;
    else
        odd=0;
    end
end

W = circshift(weight,[0 0 0]);

if 1
    Wx = min(W,circshift(W,[0 1 0]));
    Wy = min(W,circshift(W,[1 0 0]));
    Wz = min(W,circshift(W,[0 0 1]));
%     Wx = min(Wx,circshift(W,[0 -1 0]));
%     Wy = min(Wy,circshift(W,[-1 0 0]));
%     Wz = min(Wz,circshift(W,[0 0 -1]));

else
    if 0
        We=W;
        for i=-2:2
            for j=-2:2
                for k=-2:2
                    s=[i j k];
                    We = min(We,circshift(W,s));
                end
            end
        end
        Wx=We;
        Wy=We;
        Wz=We;
    else
        Wx=W;
        Wy=W;
        Wz=W;
    end
end


% construct FD operators
Ly=Convolution.get_l(sz,1,0,0);
Lx=Convolution.get_l(sz,1,1,0);
Lz=Convolution.get_l(sz,1,2,0);

%Lx.PSFh=fftn(Lx.PSF);
%Ly.PSFh=fftn(Ly.PSF);

if order>1
    g=L1_edge2D(ph,nth,1e-8,order,H,verbose);
    
%     if verbose>0
%         fprintf('edge detection y-dir\n');
%     end
%     gy=(-1)^(order)*circshift(L1_edge(ph,nth,1e-8,order,0,H,verbose),[1 0 0]);
%     if verbose>0
%         fprintf('edge detection x-dir\n');
%     end
%     gx=(-1)^(order)*circshift(L1_edge(ph,nth,1e-8,order,1,H,verbose),[0 1 0]);
%     if verbose>0
%         fprintf('edge detection z-dir\n');
%     end
%     gz=(-1)^(order)*circshift(L1_edge(ph,nth,1e-8,order,2,H,verbose),[0 0 1]);
else
    g{1} = Ly*ph;
    g{2} = Lx*ph;
    g{3} = Lz*ph;
end

if unwrap
    gx=angle(exp(1i.*g{2})); % map to -pi to pi
    gy=angle(exp(1i.*g{1}));
else
    gx=g{2};
    gy=g{1};
end

if length(g)==3
    if unwrap
        gz=angle(exp(1i.*g{3}));
    else
        gz=g{3};
    end
else
    gz=zeros(size(g{2}));
end

%% Solve Laplace equation with weights

% preconditioner for CG algorithm is the solution of the Laplace equation
% without weights (M\b)
M = Lx'*Lx + Ly'*Ly + Lz'*Lz + lambda;
% RHS
b = Lx'*(Wx.*gx) + Ly'*(Wy.*gy) + Lz'*(Wz.*gz) + lambda*initx0;

x=initx0;
r=b-A(x);
nr0=sqrt(r(:)'*r(:));
k=0;
go=1;
if verbose>0
    fprintf('Laplace eq solution: ');
end
% Preconditioned CG solver from J. Nocedal et.al. "Numerical
% Optimization"
while go
    
    resn=(sqrt(r(:)'*r(:))/nr0);
    go = and(resn>eps,k<maxiter);
    k=k+1;
    
    %fprintf('%i: %f\n',k,resn)
    z=M\r;
    if k==1
        p=z;
    else
        beta= (r(:)'*z(:)) / (ro(:)'*zo(:));
        p=z+beta*p;
    end
    zo=z;
    ro=r;
    
    Ap=A(p);
    al = (r(:)'*z(:)) / (p(:)' * Ap(:));
    x = x + al*p;
    r = r - al*Ap;
end
if verbose>0
    fprintf(' iter = %i (eps = %e) \n',k,resn);
end
if odd
    xhat= x(:,:,1:(end-1));
else
    xhat = x;
end
if or(order==1,refl)
    if sz(3)>1
        xhat = xhat(1:(sz(1)/2),1:(sz(2)/2),1:(sz(3)/2));
    else
        xhat = xhat(1:(sz(1)/2),1:(sz(2)/2),1);
    end
end

if 0
    phi_h = phantom(256);
    temp=((Lx*phi_h));
    keyboard
end

    function y=A(x)
        % forward operator for weighted Laplace equation
        Ax=@(xh)conj(Lx.PSFh).*fftn(Wx.*ifftn(Lx.PSFh.*xh));
        Ay=@(xh)conj(Ly.PSFh).*fftn(Wy.*ifftn(Ly.PSFh.*xh));
        Az=@(xh)conj(Lz.PSFh).*fftn(Wz.*ifftn(Lz.PSFh.*xh));
        xh=fftn(x);
        y=ifftn(Ax(xh)+Ay(xh)+Az(xh))+lambda*x;
    end
end