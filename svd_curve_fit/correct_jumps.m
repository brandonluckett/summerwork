    function [t,av,opt_out]=correct_jumps(t_sig,data_sig,data_stages,opt)
    % remove 
    if not(exist('opt','var'))
        opt=struct();
    end
    opt_out=struct();
    collect_channels = get_opt(opt,'collect_channels',1);
    good_channels = get_opt(opt,'good_channels',1);
    bg = get_opt(opt,'bg',0);
    filter_jump= get_opt(opt,'filter_jump',1);
    filter_60Hz= get_opt(opt,'filter_60Hz',1);
    shift_rule= get_opt(opt,'shift_rule','end_mean');
    
    %%deadtime= get_opt(opt,'Dead_Time',0);
    
    Nstages = length(data_sig);
%     jumpf=cell(Nstages,1);
%     corr_sig=cell(Nstages,1);
%     step_sig=cell(Nstages,1); 
%     for i = 1:Nstages
%         fprintf('edge detection stage %i\n',i);
%         [jumpf{i},iOp{i}] = getJumpFunction(data_sig{i},t_sig',opt); 
%         step_sig{i}  = cumsum(jumpf{i}); 
%         corr_sig{i} = data_sig{i}-step_sig{i};
%     end
    fprintf('re-order data\n');
    %% Post processing
    t = t_sig';
    %dt=t(2)-t(1);
    %t=t+double(deadtime)*dt;

    ch   = size(data_sig{1},3)-1;
    Nrep = size(data_sig{1},2);
    if collect_channels
        av=zeros(size(data_sig{1},1),Nrep*length(data_sig),ch);
        stages=zeros(Nrep*length(data_sig),3); 
        file_nr=zeros(Nrep*length(data_sig),1);
    else
        av=zeros(size(data_sig{1},1),Nrep,ch*length(data_sig));
        stages=zeros(Nrep,ch*length(data_sig),3);
        file_nr=zeros(Nrep,ch*length(data_sig),1);
    end
    ii=0;
    for i = 1:length(data_sig)
        sig = data_sig{i}(:,:,1:ch);
        if not(bg==0)
            sig = sig -repmat(bg,[1 Nrep 1]);
        end
        if collect_channels
            av(:,ii+(1:Nrep),:) = sig;
            stages(ii+(1:Nrep),:) = repmat(data_stages(i,:),[Nrep 1]);
            file_nr(ii+(1:Nrep)) = i;
            ii=ii+Nrep;
        else
            for k=1:Nrep
                av(:,k,(1:ch)+ch*(i-1)) = sig(:,k,:); 
            end
            stages(i,:)=data_stages(i,:);
            file_nr(i)=i;
        end
    end
    opt_out.org_av = av;
    opt_out.org_t = t;
    fprintf('filter jumps\n');
    [jumps,iOp] = getJumpFunction(av,t,opt);
    fprintf('Number of jumps: ');
    fprintf('%i ',squeeze(sum(sum(jumps>0,1),2)))
    fprintf('\n')
    step = cumsum(jumps);
    if filter_jump
        av = av - step;
    end
    if filter_60Hz
        av=av(:,:);
        avf = fft(av);
        av = ifft(repmat(iOp.harmSmoothOp.PSFh,[1 size(av,2)]).*avf);
        avd = ifft(repmat(iOp.diffSmoothOp.PSFh,[1 size(av,2)]).*avf);
        av = reshape(av,size(step));
        avd = reshape(avd,size(step));
        t=t(1:end-2*iOp.m);
        av=av(1:end-2*iOp.m,:,:);
        avd=avd(1:end-2*iOp.m,:,:); 
        opt_out.avd=avd;
    end

    %% shift = mean(av,1); % subtract mean
    if shift_rule=='end_mean'
        shift = mean(av((end-50):end,:,:),1);
    elseif shift_rule=='mean'
        shift = mean(av,1);
    elseif shift_rule=='log_fit'
        %% need to implement
    else
        shift = 0;
    end

    %% shift = mean(av,1); % subtract mean
    %%shift = mean(av((end-50):end,:,:),1);
    
    av=av-repmat(shift,[size(av,1) 1 1]);
    
    if collect_channels
        av=av(:,:,good_channels(:)==1);
    else
        av=av(:,:,repmat(good_channels(:),[Nstages 1])==1);
    end
    %% keyboard
    opt_out.stages=stages;
    opt_out.file_nr=file_nr;
    opt_out.shift=shift;
    opt_out.step=step;
    opt_out.iOp=iOp;
    opt_out.nr_jumps=squeeze(sum(jumps>0,1));
    
    