% Example for export of Study to mat file
%StudyUID = '1.2.826.0.1.3680043.8.498.522279114562713435623108';  good_channels=[1 1 1 1 1 0 1]; % Peg Standards
%StudyUID = '1.2.826.0.1.3680043.8.498.52227911456292799626133 ';  good_channels=[1 1 1 1 1 0 1]; % Peg Day1
%StudyUID = '1.2.826.0.1.3680043.8.498.522279114561913716138689';  good_channels=[1 1 1 1 1 1 1]; % Peg Standards SenSci 2/2/2016
StudyUID = '1.2.826.0.1.3680043.8.498.52227911456127175984041'; good_channels=[1 1 1 1 1 1 1]; % One source after repair (16/05/25)
%%StudyUID = '1.2.826.0.1.3680043.8.498.522279114561181547330639'; good_channels=[1 1 1 1 1 1 1]; % Peg Standards 06/2016
opt = struct('good_channels',[1 1 1 1 1 1 1],'verbose',1,'harm_base',60);
make_mat_from_study('/tmp/Peg_Standards_06_2016_filterd.mat',StudyUID,opt);

opt = struct('good_channels',[1 1 1 1 1 1 1],'verbose',1,'filter_jump',0,'filter_60Hz',0);
make_mat_from_study('/tmp/Peg_Standards_06_2016.mat',StudyUID,opt);
