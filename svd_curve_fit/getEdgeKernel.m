function iOp = getEdgeKernel(time,opt)
% get edge detection kernel and some other related operators
% iOp.m : stincil size
% iOp.edgeOp
% iOp.matchOp 
% iOp.harmSmoothOp
% iOp.diffSmoothOp
if not(exist('opt','var'))
   opt=struct();
end
t = time;
n = get_opt(opt,'poly_order',2);
n_h = get_opt(opt,'harm_order',0);
os = get_opt(opt,'oversample',1);
f0 = get_opt(opt,'harm_base',60);
m   = (n+1+n_h*2)*os;
gap=0;
iOp.m=m;

[N M] = meshgrid(0:n,1:m);
iOp.Apl = M.^N; % Vandermonde matrix for right fit
iOp.Apld = N .* M.^(N-1);  % derivative of Vandermonde matrix for right fit
iOp.Apl2d = (N-1).*N.* M.^(N-2);  % derivative of Vandermonde matrix for right fit
iOp.Aml = (-m+M-gap).^N; % Vandermonde matrix for left fit

% Harmonics form right
dt = t(2)-t(1);
tp = ((1:m)*dt).';
iOp.Aph=[];
for i=1:n_h
    iOp.Aph =[iOp.Aph sin(2*pi*f0*tp*i) cos(2*pi*f0*tp*i)  ];
end
iOp.Ap =[iOp.Apl iOp.Aph ];

% Harmonics from left
tm = ((-m+(1:m)-gap)*dt).';
iOp.Amh = [];
for i=1:n_h
    iOp.Amh =[iOp.Amh sin(2*pi*f0*tm*i) cos(2*pi*f0*tm*i)  ];
end

iOp.Am = [iOp.Aml iOp.Amh  ];

iOp.Aps = inv(iOp.Ap'*iOp.Ap)*iOp.Ap'; % Interpolation coefficients using least squares
iOp.Ams = inv(iOp.Am'*iOp.Am)*iOp.Am';

iOp.Ep = (iOp.Ap*iOp.Aps-eye(m,m)); % Error matrix for right
iOp.Em = (iOp.Am*iOp.Ams-eye(m,m)); % Error matrix for left

%% Find kernals for edge detectors
% First value of Interpolate curve for right dataset (psfi)
%  Fist value of extrapolated curve for left applied to t-values on right (psfe)
psfi = zeros(size(t));
psfe = zeros(size(t));

tmp  = iOp.Ap*iOp.Aps; psfi(1:m) = tmp(1,end:-1:1); psfi=circshift(psfi,-m);
tmp2 = iOp.Ap*iOp.Ams; psfe(1:m) = tmp2(1,end:-1:1); psfe=circshift(psfe,gap);
psf1 = psfi-psfe; % edge detector kernel is interpolated point - exterpolated point

% PSF to interpolate last point without sin cos, i.e only polynomial
HarmSmoothKernel = zeros(size(t));
tmp  = iOp.Apl*iOp.Aps(1:(n+1),:); HarmSmoothKernel(1:m) = tmp(1,end:-1:1); HarmSmoothKernel=circshift(HarmSmoothKernel,-m);

DiffKernel = zeros(size(t));
tmp  = iOp.Apld*iOp.Aps(1:(n+1),:); 
DiffKernel(1:m) = tmp(1,end:-1:1); DiffKernel=circshift(DiffKernel,-m);

DiffKernel2 = zeros(size(t));
tmp  = iOp.Apl2d*iOp.Aps(1:(n+1),:); 
DiffKernel2(1:m) = tmp(1,end:-1:1); DiffKernel2=circshift(DiffKernel2,-m);


psfi = zeros(size(t));
psfe = zeros(size(t));
tmp  = iOp.Am*iOp.Aps; psfi(1:m) = tmp(end,end:-1:1); psfi=circshift(psfi,-m);
tmp2 = iOp.Am*iOp.Ams; psfe(1:m) = tmp2(end,end:-1:1); psfe=circshift(psfe,gap);
psf2 = psfi-psfe;

edgeKernel = (psf1+psf2)/2; % average left and right kernel

% Find matching waveform by applying edge detection to unit jump
hev = zeros(size(t));
hev(1:(size(t)/2))=1;

iOp.edgeOp  = Convolution(edgeKernel);
matchKernel = iOp.edgeOp*hev;
matchKernel((2*m+1):(end-2*m-1))=0;
iOp.matchOp = Convolution(matchKernel);
iOp.harmSmoothOp = Convolution(HarmSmoothKernel);
iOp.diffSmoothOp = Convolution(DiffKernel);
iOp.diff2SmoothOp = Convolution(DiffKernel2);

