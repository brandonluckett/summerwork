function ret = LS1_peak(x,y)
ret=[0; 0];
%s=max(abs(y));
%if s<1e-10
%    return
%end

for i=1:20
    d = 1./(1+ret(2)*x);
    A = [-d(:) d(:).*x(:).*y(:)];
    b = -d(:).*y(:);
    ret=(A'*A)\(A'*b);
end
%ret(1)=ret(1)*s;
