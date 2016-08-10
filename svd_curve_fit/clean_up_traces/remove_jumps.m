function [cum,jump_fnc,C]=remove_jumps(I,opt)
    %Parameter:
    if not(exist('opt','var'))
        opt = struct();
    end
    fil_len   = get_opt(opt,'filter_len',10); % reg parameter
    lambda    = get_opt(opt,'lambda',1e-4); % reg parameter
    th        = get_opt(opt,'th',0.01); % minimum jump size
    eps       = get_opt(opt,'eps',1e-7); % L1 convergence eps 
    order     = get_opt(opt,'order',3);   % Edge detection order
    maxiter   = get_opt(opt,'maxiter',500);   % max iterations
    

    % Use Neumann boundary condition, extend left and right by length of filter.
    sz=size(I);
    sz2=[sz(1)+2*fil_len,sz(2)];
    A=zeros(sz2);
    A((fil_len+1):(end-fil_len),:)=I;
    A(1:fil_len,:)=repmat(I(1,:),[fil_len,1]);
    A((end-fil_len+1):end,:)=repmat(I(end,:),[fil_len,1]);
    
    % Create moving average filter
    f=zeros(sz2);
    f(1:fil_len,:)=1/fil_len;
    f=circshift(f,[-round(fil_len/2),1]);
    B=ifft(fft(A).*fft(f));
    B=B((fil_len+1):(end-fil_len),:); %crop to oroginal length 
    C=median(I-B,2); % Assume that less than half the traces have no jump within filter_len
    % Run jump detection on cleaned traces
    jump_fnc=L1_edge(I-repmat(C,[1,sz(2)]),lambda,eps,order,0,[],1,maxiter);
    jump_fnc(abs(jump_fnc)<th)=0;   % remove remaining noise
    cum=cumsum(jump_fnc);
    cum=cum-repmat(cum(1,:),[sz(1) 1]);
    