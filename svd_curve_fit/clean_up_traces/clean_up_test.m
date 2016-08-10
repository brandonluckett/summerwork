clear all 
close all

if 0
    addpath('tdms_Version_2p5_Final/v2p5/')
    addpath('tdms_Version_2p5_Final/v2p5/tdmsSubfunctions')
    addpath('bgsuppress')
end

bg = TDMS_getStruct('br2_12_17_001.tdms');
sig= TDMS_getStruct('br2_12_17_015.tdms');

% [t_bg, traces_bg, jumps_bg, traces_bg_org]=pre_process_channel(bg,opt);    % Reorder and remove jumps
% [t_sig, traces_sig, jumps_sig, traces_sig_org]=pre_process_channel(sig,opt); % Reorder and remove jumps
[t_bg, traces_bg_org]=pre_process_channel3(bg);    % Reorder 
[t_sig traces_sig_org]=pre_process_channel3(sig); % Reorder 
S  = [sin(2*pi*60*t_sig') cos(2*pi*60*t_sig') sin(2*pi*120*t_sig') cos(2*pi*120*t_sig') sin(2*pi*180*t_sig') cos(2*pi*180*t_sig') ];
Si = [2*pi*60*cos(2*pi*60*t_sig') -2*pi*60*sin(2*pi*60*t_sig') 2*pi*120*cos(2*pi*120*t_sig') -2*pi*120*sin(2*pi*120*t_sig') 2*pi*180*cos(2*pi*180*t_sig') -2*pi*180*sin(2*pi*180*t_sig') ];

% Remove jumps
sz=size(traces_bg_org);
traces_bg=traces_bg_org;
traces_sig=traces_sig_org;
traces=zeros(sz(1),sz(3));
for k=1:sz(3)
    [cum, jump_fnc,C_bg]=remove_jumps(traces_bg_org(:,:,k)); 
    traces_bg(:,:,k)=traces_bg(:,:,k)-cum;
    [cum, jump_fnc,C_sig]=remove_jumps(traces_sig_org(:,:,k)); 
    traces_sig(:,:,k)=traces_sig(:,:,k)-cum;
    traces(:,k)=mean(traces_sig(:,:,k),2)-C_sig-mean(traces_bg(:,:,k),2)+C_bg;
end
figure(1)
plot(t_bg,squeeze(mean(traces_sig_org,2)-mean(traces_bg_org,2))); title('Original averaged traces')
figure(2)
plot(t_bg,traces); title('cleaned up traces')

t=t_bg(500:end-1);
Sd2=Si(500:end-1,:);
d=diff(traces_sig(500:end,1,1));
figure(1)
c=(Sd2'*Sd2)\(Sd2'*d);
plot(t,d-Sd2*c,'g',t,d,'k',t,Sd2*c,'m')
figure(2)
plot(t_bg,S*c,'g',t_bg,traces_sig(1:end,1,1),'k');
