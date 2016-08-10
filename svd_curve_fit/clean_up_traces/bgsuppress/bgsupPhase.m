function out=bgsupPhase(image,opt)
%% unwrapping and background phase removal
% image         MRImage
% opt.order     for edge detector
%   1           ... no edge detection, just unwrap signal
%   >=2         ... use "edge" detection, unwrap and remove background
% opt.nth       regularization paramter
% opt.eps       stopping eps
% opt.maxiter   maximum number of iterations
% opt.x0        || x0 - x ||_1 is minimized
%
% wstefan@mdanderson.org

out=MRImage.like(image);
mag=image.getMagnitudeData();
ph=bgsup3(image.getPhaseData(),mag.^2,opt);
out.setMagnitudePhaseData(mag,ph);
