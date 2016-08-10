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
cf = py.MDAdbc.parse_config('metadbconfig.cfg');

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
locations=py.dict();
%locations{27}='/Volumes/di_data1/Data2/SAIF/MRX/squid'; 

% ScSi Hcr conj. in BT474 tumor mice
good_channels=[1 1 1 1 1 1 1];
c_bg = {'1.2.826.0.1.3680043.8.498.52227911456426313242086'}; % bg
c1={'1.2.826.0.1.3680043.8.498.52227911456526617685234'}; % BF time=0
c2={'1.2.826.0.1.3680043.8.498.52227911456305049356636'}; % BF t=3h
c3={'1.2.826.0.1.3680043.8.498.5222791145688516790885'}; % BF t=1h
c4={'1.2.826.0.1.3680043.8.498.52227911456131849898325'}; % BF t=2h
c5={'1.2.826.0.1.3680043.8.498.5222791145654772412342'}; % BG t=0
c6={'1.2.826.0.1.3680043.8.498.52227911456559539445755'}; % BH t=0 
[t,ref1,av1,pars1]=svd_curve_fit(dbc,c_bg,c1,good_channels,locations,metastudy);
[t,ref2,av2,pars2]=svd_curve_fit(dbc,c_bg,c2,good_channels,locations,metastudy);
[t,ref3,av3,pars3]=svd_curve_fit(dbc,c_bg,c3,good_channels,locations,metastudy);
[t,ref4,av4,pars4]=svd_curve_fit(dbc,c_bg,c4,good_channels,locations,metastudy);
[t,ref5,av5,pars5]=svd_curve_fit(dbc,c_bg,c5,good_channels,locations,metastudy);
[t,ref6,av6,pars6]=svd_curve_fit(dbc,c_bg,c6,good_channels,locations,metastudy);


plot(ref1,ref2,'r',ref2,ref4,'b');
xlabel('BF tr=0 (V)')
ylabel('BF t=3h (V)');
