%% L1 deconvolution
% y images
% W: y = W * x 
% lambda: regularization parameter (depends on noise)

function x=L1_decon_par(y,W,lambda,eps,verbose,maxiter)
    if not(exist('verbose','var'))
       verbose=1;
    end
    if not(exist('maxiter','var'))
       maxiter=1000;
    end    
    sz=size(y);
    N = sz(2); % number of vectors
    
    Lambda=zeros(sz);
    tau=max(lambda(:));
    lhs=W'*W+tau;
    lhs_h=repmat(lhs.PSFh,[1 N]);
    
    b = ifft(repmat(conj(W.PSFh),[1 N]).*fft(y));
    %b=W'*y;
    
    go=1; i=0;
    epsno=norm(y(:));
    y=zeros(size(b));
    while go
        if verbose>0
            fprintf('.');
        end
        i=i+1;
        rhs=b+Lambda+tau*y;
        %%x=lhs\rhs;
        x = ifft(fft(rhs)./lhs_h);
        
        tmp=x-Lambda/tau;
        y=abs(tmp);
        if 0 % soft th
            y=max(y-lambda./tau,0);
        else %hard th
            y=(y>=lambda./tau).*y;
        end 
        
        y=sign(tmp).*y;
       
        d=x-y;
        Lambda=Lambda-1.8*tau*d;
        go=and((norm(d(:))/epsno)>eps,i<maxiter);
        % fprintf('%i: %e\n',i,norm(d(:)))
        if mod(i,10)==0;
            tau=tau*2;
            lhs=W'*W+tau;
            lhs_h=repmat(lhs.PSFh,[1 N]);
        end
    end
    
    if verbose>0
        fprintf('\n');
    end
        
        