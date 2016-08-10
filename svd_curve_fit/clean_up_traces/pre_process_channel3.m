function [t, d_in]=pre_process_channel3(obj)
    % preprocess SQUID data.
    % For each channel:
    % 1. Extract runs (reshape signal)

    N=obj.Props.Number_of_pulses;
    pulse_end=obj.Props.Pulse_Length;
    dec_start=obj.Props.Pulse_Length+obj.Props.Dead_Time;
    N_channels=length(fieldnames(obj.SQUID))-3;
   
    % compute data size and setup some helper variables
    d=obj.SQUID.channel0.data;
    d2=reshape(d,[length(d)/N N]);
    d2_dec=d2(dec_start:end,:);
    sz=size(d2_dec);
    
    dt = 1/double(obj.Props.rateout);
    t=((1:sz(1)))*dt;
    deadtime = obj.Props.Dead_Time;
    t=t+double(deadtime)*dt;
    d_in  = zeros([sz(1) sz(2) N_channels]);
    for i=1:N_channels
        d=getfield(obj.SQUID,sprintf('channel%i',i));
        d=d.data;
        d2=reshape(d,[length(d)/N N]);
        % extract runs
        d2_dec=d2(dec_start:end,:);
        d_in(:,:,i)=d2_dec; 
    end
    
    
    
    