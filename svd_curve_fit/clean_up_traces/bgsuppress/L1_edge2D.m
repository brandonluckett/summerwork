%% L1 edge detection
% y images
% lambda: regularization parameter (depends on noise)
% order:  edge detection order (larger order eliminates larger gradients
%         but is also more sensitive to noise
% dir:    direction 0:y, 1:x 2:z
% optional: H ... convolution operator that corruptes y, i.e. edges in y* are found if
%  y = H * y*
function x=L1_edge2D(y0,lambda,eps,order,H,verbose)
    if not(exist('verbose','var'))
       verbose=1;
    end
    sz=size(y0);
    md=length(sz);
    
    L=cell(md,1);
    W=cell(md,1);
    y=cell(md,1);
    W=cell(md,1);
    b=cell(md,1);
    Lambda=cell(md,1);
    lhs=cell(md,1);
    tmp=cell(md,1);
    rhs=cell(md,1);
    x=cell(md,1);
    dir=cell(md,1);
    d=cell(md,1);   
    tau=max(lambda(:));
    for i=1:md
        sh=zeros(md,1);
        sh(i)=1;
        %L{i}=(-1)^(order)*circshift(Convolution.get_l(sz,order,i-1,0),sh);
        %W{i}=(-1)^(order)*circshift(Convolution.get_l(sz,order,i-1,1),sh);
        L{i}=Convolution.get_l(sz,order,i-1,0);
        W{i}=Convolution.get_l(sz,order,i-1,1);
        
        if exist('H','var')
           W{i} = W{i}*H;
        end
        Lambda{i}=zeros(sz);
        lhs{i}=W{i}'*W{i}+tau;
        b{i}=W{i}'*L{i}*y0;
        y{i}=zeros(size(b{i}));   
    end
    go=1; i=0;
    epsno=norm(y{1}(:));
    while go
        if verbose>0
            fprintf('.');
        end
        i=i+1;
        for j=1:md
            rhs{j}=b{j}+Lambda{j}+tau*y{j};
            x{j}=lhs{j}\rhs{j};
            tmp{j}=x{j}-Lambda{j}/tau;
        end
        
        ym=tmp{1}.*tmp{1};
        for j=2:md
            ym=ym+tmp{j}.*tmp{j};
        end
        ym=sqrt(ym);
       
        for j=1:md
            dir{j}=tmp{j}./(ym+1e-10);
        end
        
        if 1 % soft th
            ym=max(ym-lambda/tau,0);
        else %hard th
            ym=(ym>=lambda/tau).*ym;
        end 
        
        for j=1:md
            y{j}=dir{j}.*ym;
            d{j}=x{j}-y{j};
            Lambda{j}=Lambda{j}-1.8*tau*d{j};
        end
        
        go=and((norm(d{1}(:))/epsno)>eps,i<50);
        % fprintf('%i: %e\n',i,norm(d(:)))
        if mod(i,10)==0;
            tau=tau*2;
            for j=1:md
                lhs{j}=W{j}'*W{j}+tau;
            end
        end
    end
    if verbose>0
        fprintf('\n');
    end
        
        