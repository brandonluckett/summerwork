function ret = LS2_peaks(x,y)
ret=[0; 0; 0 ; 0];
% s=max(abs(y));
% if s<1e-10
%     return
% else
%     y=y/s;
% end

for i=1:20
    d = (1+ret(3)*x + ret(4)*x.^2);
%     if min(d)<1e-10;
%         ret=[0; 0; 0; 0];
%         return
%     end
    A = [-1./d(:) -1./d(:).*x(:) 1./d(:).*x(:).*y(:) 1./d(:).*x(:).^2.*y(:)];
    b = -1./d(:).*y(:);
    ret=A\b;
end
% ret(1:2)=ret(1:2)*s;
