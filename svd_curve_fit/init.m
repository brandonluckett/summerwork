%% init.m 
% Initialization script for database connection

if 1
    addpath('clean_up_traces/');
    addpath('clean_up_traces/tdms_Version_2p5_Final/v2p5/')
    addpath('clean_up_traces/tdms_Version_2p5_Final/v2p5/tdmsSubfunctions')
    addpath('clean_up_traces/bgsuppress')
end

%% Load config file and open db connection
cf = py.MDAdbc.parse_config('/etc/metadbconfig.cfg');
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
locations{27}='/Volumes/di_data1/Data2/SAIF/MRX/squid'; 