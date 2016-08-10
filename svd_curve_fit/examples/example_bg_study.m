clear all 
close all

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

%setup local mount points, if needed
locations=py.dict();
%locations{27}='/Volumes/di_data1/Data2/SAIF/MRX/squid'; 
%c='1.2.826.0.1.3680043.8.498.52227911456406544521301'; good_channels=[1 1 1 1 1 0 1];  good_channels=[1 1 1 1 1 1 1];  % ScSi Hcr conj. in BT474 tumor mice
c='1.2.826.0.1.3680043.8.498.52227911456453016711903'; good_channels=[1 1 1 1 1 1 1];  % Sen Sci peg
%c='1.2.826.0.1.3680043.8.498.522279114562386729685805'; good_channels=[1 1 1 1 1 0 1]; % Power cond install
%c='1.2.826.0.1.3680043.8.498.5222791145649428841761'; good_channels=[1 1 1 1 1 0 1]; % 24h bg 16_02_27
%c='1.2.826.0.1.3680043.8.498.52227911456540349331710'; good_channels=[1 1 1 1 1 0 1]; % 24hr background (10 pulses x 5 runs every 30 min) with power conditioner installed
%c='1.2.826.0.1.3680043.8.498.522279114562916438197950'; good_channels=[1 1 1 1 1 0 1]; % Background Measurement - 24 hours 10 pusles x 5 runs x 5 stage positions every 30 min
c='1.2.826.0.1.3680043.8.498.522279114562978813824214'; good_channels=[1 1 1 1 1 0 1]; % New SenSci Peg set
c='1.2.826.0.1.3680043.8.498.522279114561898119543756'; good_channels=[1 1 1 1 1 0 1]; % Peg study 0,1 and 2 sources
c = '1.2.826.0.1.3680043.8.498.52227911456197162841904';  good_channels=[1 1 1 1 1 0 1]; % Peg Standards

Series=queryStudyUID(dbc,c,77);  

for i=1:length(Series)
    fprintf('%i:%s: %s (%s): %s\n' , i,char(Series{i}{'SeriesNumber'}),char(Series{i}{'SeriesUID'}),char(Series{i}{'Acq_nr'}),char(Series{i}{'SeriesDescription'}))
end
bg_idx = input('Please pick BGs "[s1,s2,s3]" : ');
c={};
for i=1:length(bg_idx)
    c{i}=char(Series{bg_idx(i)}{'SeriesUID'});
end
opt=struct('good_channels',good_channels, ...
           'metastud',metastudy, ...
           'filter_jump',1, ...
           'filter_60Hz',1, ...
           'harm_order',3,...
           'oversample',3, ...
           'lambda',0.001);

[t_sig,data,sig,stages,files]=loadSeriesByInstanceUIDs(dbc,c,locations,metastudy);
[t,av,opt]=correct_jumps(t_sig,data,stages,opt);

%[t_sig,data,sig,stages,files]=loadSeriesByInstanceUIDs(dbc,c,locations,metastudy);
Nch=size(data{1},3)-1;
Nrep=length(data);
N=size(av,2);
[I,J]=meshgrid(1:N,1:N);
%%
ch=6;
D=arrayfun(@(i,j)norm(av(:,i,ch)-av(:,j,ch)),I,J).^2;
imagesc(D,[0 .5])
fprintf('median  : %5.4f\n',median(D(:)))
fprintf('mean    : %5.4f\n',mean(D(:)))
