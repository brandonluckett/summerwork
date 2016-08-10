
import MDAdbc
import MySQLdb

cf  = MDAdbc.parse_config('/etc/metadbconfig.cfg'); 
dbc = MDAdbc.mysql_connection();
dbc.setup_database(cf['mysql_server'     ], 
                   cf['mysql_user'       ], 
                   cf['mysql_password'   ], 
                   cf['mysql_protocol_db'] 
                   );
                   
dbc.setup_backup(cf['mysql_backup']);
dbc.connect();
dbc.execute('use auto_qc_testing')
metastudy=77;
