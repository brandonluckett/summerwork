function make_mat_from_study_comandline(StudyUID,filt,filename,lambda)
    %if ~isdeployed
    %    addpath('clean_up_traces/tdms_Version_2p5_Final/v2p5')
    %    addpath('clean_up_traces/tdms_Version_2p5_Final/v2p5/tdmsSubfunctions')
    %    addpath('clean_up_traces');
    %    addpath('clean_up_traces/bgsuppress')
    %end
    lambda=str2num(lambda);
    disp(['lambda:   ' lambda])
    disp(['StudyUID: ' StudyUID])
    if str2num(filt)==1
        disp(['making ' filename])
        opt = struct('good_channels',[1 1 1 1 1 1 1],'verbose',1,'harm_base',60,'lambda',lambda);
        make_mat_from_study(filename,StudyUID,opt);
    end

    if str2num(filt)==0
        disp(['making ' filename])
        opt = struct('good_channels',[1 1 1 1 1 1 1],'verbose',1,'filter_jump',0,'filter_60Hz',0);
        make_mat_from_study(filename,StudyUID,opt);
    end

