%% L1 edge detection
% y images
% lambda: regularization parameter (depends on noise)
% order:  edge detection order (larger order eliminates larger gradients
%         but is also more sensitive to noise
% dir:    direction 0:y, 1:x 2:z
% optional: H ... convolution operator that corruptes y, i.e. edges in y* are found if
%  y = H * y*
function x=L1_edge(y,lambda,eps,order,dir,H,verbose,maxiter)
    if not(exist('verbose','var'))
       verbose=1;
    end
    if not(exist('maxiter','var'))
       maxiter=50;
    end    
    sz=size(y);
    L=Convolution.get_l(sz,order,dir,0);
    W=Convolution.get_l(sz,order,dir,1);
    
    if and(not(H==[]),exist('H','var'))
        W = W*H;
    end

    Lambda=zeros(sz);
    tau=max(lambda(:));
    lhs=W'*W+tau;
    b=W'*L*y;
    
    go=1; i=0;
    epsno=norm(y(:));
    y=zeros(size(b));
    while go
        if verbose>0
            fprintf('.');
        end
        i=i+1;
        rhs=b+Lambda+tau*y;
        x=lhs\rhs;
        
        tmp=x-Lambda/tau;
        y=abs(tmp);
        if 1 % soft th
            y=max(y-lambda/tau,0);
        else %hard th
            y=(y>=lambda/tau).*y;
        end 
        
        y=sign(tmp).*y;
       
        d=x-y;
        Lambda=Lambda-1.8*tau*d;
        go=and((norm(d(:))/epsno)>eps,i<maxiter);
        % fprintf('%i: %e\n',i,norm(d(:)))
        if mod(i,10)==0;
            tau=tau*2;
            lhs=W'*W+tau;
        end
    end
    if verbose>0
        fprintf('\n');
    end
        
        