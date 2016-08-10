function X=reflect(x,opt)
% Reflect image along x and y axis to enforce Neumann boundary condition
% when an fft is used.

if not(exist('opt','var'))
    opt = struct();
end
zeros_cmd  = get_opt(opt,'zeros',@zeros);
sz = size(x);
if length(sz)==2
    sz=[sz 1];
end

X=zeros_cmd(sz);
[N M L]=size(X);

if sz(3)>1
    X=zeros_cmd([2*N 2*M 2*L]);
else
    X=zeros_cmd([2*N 2*M]);
end
X(1:N,1:M,1:L)=x;
X((N+1):(2*N),1:M,1:L)=X(N:-1:1,1:M,1:L);
X(1:N,(M+1):(2*M),1:L)=X(1:N,M:-1:1,1:L);
X((N+1):(2*N),(M+1):(2*M),1:L)=X(N:-1:1,M:-1:1,1:L);    


    if sz(3)>1 
        X(:,:,(L+1):(2*L)) = X(:,:,L:-1:1);
    end
