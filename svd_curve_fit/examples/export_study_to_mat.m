function make_mat_from_study(StudyUID,good_channels,locations,opt)

%%
if 1
    addpath('clean_up_traces/');
    addpath('clean_up_traces/tdms_Version_2p5_Final/v2p5/')
    addpath('clean_up_traces/tdms_Version_2p5_Final/v2p5/tdmsSubfunctions')
    addpath('clean_up_traces/bgsuppress')
end

%% Load config file and open db connection
cf = py.MDAdbc.parse_config('/etc/metadbconfig.cfg'); % global config with password
if exist('metadbconfig.cfg','file')
    cf.update(py.MDAdbc.parse_config('metadbconfig.cfg')); % local config to point to testing env.
end

dbc = py.MDAdbc.mysql_connection();
dbc.setup_database(cf{'mysql_server'}, ...
                   cf{'mysql_user'}, ...
                   cf{'mysql_password'}, ...
                   cf{'mysql_protocol_db'} ...
                   );
                   
dbc.setup_backup(cf{'mysql_backup'});
dbc.connect();
%%dbc.execute('use '+cf{'mysql_meta_db'})
dbc.execute('use auto_qc_testing')
metastudy=77;
if not(exist('locations','var'))
    locations=py.dict();
end
%setup local mount points, if needed
%locations{27}='/Volumes/di_data1/Data2/SAIF/MRX/squid'; 
%c='1.2.826.0.1.3680043.8.498.52227911456406544521301'; good_channels=[1 1 1 1 1 0 1];  good_channels=[1 1 1 1 1 1 1];  % ScSi Hcr conj. in BT474 tumor mice
%c='1.2.826.0.1.3680043.8.498.52227911456453016711903'; good_channels=[1 1 1 1 1 1 1];  % Sen Sci peg
%c='1.2.826.0.1.3680043.8.498.522279114562386729685805'; good_channels=[1 1 1 1 1 0 1]; % Power cond install
%c='1.2.826.0.1.3680043.8.498.5222791145649428841761'; good_channels=[1 1 1 1 1 0 1]; % 24h bg 16_02_27
%c='1.2.826.0.1.3680043.8.498.52227911456540349331710'; good_channels=[1 1 1 1 1 0 1]; % 24hr background (10 pulses x 5 runs every 30 min) with power conditioner installed
%c='1.2.826.0.1.3680043.8.498.522279114562916438197950'; good_channels=[1 1 1 1 1 0 1]; % Background Measurement - 24 hours 10 pusles x 5 runs x 5 stage positions every 30 min
%c='1.2.826.0.1.3680043.8.498.522279114562978813824214'; good_channels=[1 1 1 1 1 0 1]; % New SenSci Peg set
%c='1.2.826.0.1.3680043.8.498.522279114561898119543756'; good_channels=[1 1 1 1 1 0 1]; % Peg study 0,1 and 2 sources

Series=queryStudyUID(dbc,c,77); 
N=length(Series);
Series_description=cell(N,1);
stage_positions=cell(N,1);
signal=cell(N,1);
time=cell(N,1);
t_sig=cell(N,1);
data=cell(N,1);
stages=cell(N,1);
files=cell(N,1);
file_nr=cell(N,1);

Nrep=10; %need fix to automatically pick nr of repeats
fprintf('load data\n');

%Series={Series{1}};

for i=1:length(Series)
    Series_description{i}=sprintf('%i:%s: %s (%s): %s\n' , i,char(Series{i}{'SeriesNumber'}),char(Series{i}{'SeriesUID'}),char(Series{i}{'Acq_nr'}),char(Series{i}{'SeriesDescription'}));
    fprintf(Series_description{i})
    [t_sig{i},data{i},sig{i},stages{i},files{i}]=loadSeriesByInstanceUIDs(dbc,{char(Series{i}{'SeriesUID'})},locations,metastudy);
end
%%
for i=1:length(Series)
    fprintf('remove jumps from series: %i\n',i);
    Nch=size(data{i}{1},3)-1;
    Nrep=length(data{i});
    [t,av,stages_run,file_nr_run]=correct_jumps(t_sig{i},data{i},stages{i},zeros(size(data{i}{1},1),1,Nch),sig{i}{1}.Props.Dead_Time,good_channels,1,1);
    
    %% Package traces
    stage_positions{i} = stages_run;
    signal{i}=av;
    time{i}=t;
    file_nr{i}=file_nr_run;
end
save -v7.3 /tmp/pegsstudy.mat Series_description time signal stage_positions file_nr files
