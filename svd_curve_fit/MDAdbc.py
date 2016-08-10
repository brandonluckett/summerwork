import re
import datetime
import numpy as np

class db_connection:
    def __init__(self):
        self.lock_edit=False;
        self.set_default_user()
        self.revision=None;

    def setup_database(self,host,user,password,db):
        self.dbhost=host;
        self.dbuser=user;
        self.dbpassword=password;
        self.dbname=db;
        
    def getVar(self,name,default=None):
        self.execute('select value from '+cf['mysql_protocol_db']+'.session_variables where session_id=%s and name=%s limit 2',(self.sid,name))
        val=self.fetchall()
        if len(val)==0:
            return default
        else:
            #assert len(val)==1;
            return val[0][0]
        
    def setVar(self,name,value):
        self.execute('select count(*) from '+cf['mysql_protocol_db']+'.session_variables where session_id=%s and name=%s limit 2',(self.sid,name))
        val=int(self.fetchone()[0])
        if val==0:
            self.execute('insert into '+cf['mysql_protocol_db']+'.session_variables (session_id,name,value) values (%s,%s,%s)',(self.sid,name,value))
        else:
            self.execute('update '+cf['mysql_protocol_db']+'.session_variables set value=%s where session_id=%s and name=%s',(value,self.sid,name))
        
    def setup_backup(self,host):
        self.dbbackup_host=host
        
    def set_revision(self,revision):
        self.revision = revision;

    def connect(self):
        
        try:
            self.open_connection(host=self.dbhost,user=self.dbuser,passwd=self.dbpassword,db=self.dbname)  
            self.backup=False;
            try:
                self.execute("select name,value from database_meta")
                self.db_info=table_do_dic(self.fetchall())  
            except:
                self.db_info={}
            return True
        except:
            try:
                self.open_connection(host=self.dbbackup_host,user=self.dbuser,passwd=self.dbpassword,db=self.dbname)
            except:
                import traceback,StringIO
                output = StringIO.StringIO()
                traceback.print_exc(file=output)
                print                 
                print "%s" % output.getvalue()
                return False

            self.select("select last_download from scanner_cn where auth='trash'")
            self.backup_date=self.fetchone()[0]
            self.backup=True;
            self.log_error("Main database server down")
            try:
                self.execute("select name,value from database_meta")
                self.db_info=table_do_dic(self.fetchall())  
            except:
                self.db_info={}            
            return True
            
    def log_error(self,text):  
        try:
            now=datetime.datetime.utcnow()
            q="insert into error_log (sessionid,time,errormessage,env,software_revision) values (%s,%s,%s,%s,%s)"
            v=(self.sid,now,text,str(os.environ),self.revision)
            #print q % v
            self.execute(q,v)
        except:
            pass 
            #print "Error logging error: %s" % text
            #raise           
            
    def drop_old_sessions(self):
        now=datetime.datetime.utcnow()
        to_old_for_cookie=now+datetime.timedelta(days=-1)
        to_old_for_activity=now+datetime.timedelta(minutes=-int(cf.get('session_timeout',15))) # MDA policy
        self.execute("update session set end_time=%s where start_time<%s or last_action<%s and end_time is Null",(now,to_old_for_cookie,to_old_for_activity))

    def set_default_user(self):
        
        self.user=""
        self.userid=-1;
        self.sid=-1;
        self.ugroup=-1;
        self.admin=False;
        self.edit_allowed=False;
        self.view_allowed=False;
        self.limitview_allowed=True;
        self.download_allowed=False;
        self.change_passwd_allowed=False;
        self.tempo=False;
        self.session_key=None; 
        self.user_permissions=[];
        
    def load_user(self,userid):
        now=datetime.datetime.now()
        self.select("""select u.uname,
                              u.ugroup,
                              g.edit,
                              g.view,
                              g.limitview,
                              -1 as keyvalue,
                              g.download,
                              g.admin,
                              u.change_passwd,
                             -1 as id,
                             u.tmp_ugroup,
                             u.tmp_expire,
                             u.id 
                       from """+cf['mysql_protocol_db']+""".users u 
                       join """+cf['mysql_protocol_db']+""".groups g on g.ugroup=u.ugroup 
                       where u.id=%s""", userid)
        userdb=self.fetchall()
        if userdb[0][10] is not None: # user has temporary user group settings
            s="select tmp_ugroup,tmp_db,tmp_expire,tmp_comment from users where id=%s and tmp_expire>%s"
            q=(userdb[0][12],now)                
            self.select( s, q)
            # message+= "%s<br>" % (s % q) 
            tmp=self.fetchone();
#                print 
#                print tmp[0]
            if tmp is not None: # if the temporay settin is active get temparay group info from db
                #message+="<b>Temporary user group '%s' expires %s</b><br>" % (tmp[0],tolocal(tmp[2]))
                #message+="Reason for temporary status: %s<br><br>" % (tmp[3])
                self.select("""select u.uname,
		                      u.ugroup,
		                      g.edit,
		                      g.view,
		                      g.limitview,
		                      -1 as keyvalue,
		                      g.download,
		                      g.admin,
		                      u.change_passwd,
		                     -1 as id,
		                     u.tmp_ugroup,
		                     u.tmp_expire,
		                     u.id 
		               from """+cf['mysql_protocol_db']+""".users u 
		               join """+cf['mysql_protocol_db']+""".groups g on g.ugroup=u.tmp_ugroup 
		               where u.id=%s""", userid)

                userdb=self.fetchall()
                self.tempo_reason=tmp[3];
                self.tempo_expire=tmp[2];
                self.tempo=True
            else:
                self.tempo=False
        else:
            self.tempo=False;
                
        self.user=userdb[0][0]        
        self.ugroup=userdb[0][1]    
        self.admin=userdb[0][7]==1
        self.edit_allowed=(userdb[0][2]==1 and (not self.backup) and (not self.lock_edit)) or self.admin==1;
        self.view_allowed=userdb[0][3]==1 or (userdb[0][2] and self.backup);
        self.limitview_allowed=userdb[0][4]==1
        self.session_key=userdb[0][5]
        self.download_allowed=(userdb[0][6]==1 and (not self.backup) and (not self.lock_edit)) or self.admin==1;
        self.change_passwd_allowed=userdb[0][8]==1 and not self.backup
        self.sid=userdb[0][9];
        self.userid=userdb[0][12];

        # extened permissions
        self.execute("select id,uname,ugroup,name from "+cf['mysql_protocol_db']+".user_permissions where uname=%s",self.user)
        self.user_permissions=[];
        for e in self.fetchall():
            self.user_permissions.append("%s" % (e[3]))

        # get user variables
        q="select name,value from "+cf['mysql_protocol_db']+".user_vars where user_id=%s"
        v=(self.userid,)
        self.execute(q,v)
        self.user_vars={};
        for e in self.fetchall():
            self.user_vars[e[0]]=e[1];       
 
    def set_user_var(self,name,value):
        q='insert into CT_QT.user_vars (user_id,name,value) values (%s,%s,%s) on duplicate key update value=%s';
        v=(self.userid,name,value,value)
        self.execute(q,v)    
        self.user_vars[name]=value;       

    def get_session(self,session_id):
        now=datetime.datetime.utcnow()
        self.select("select s.id,s.userid,s.keyvalue from "+cf['mysql_protocol_db']+".session s where s.keyvalue=%s and end_time is Null", str(session_id))
        userdb=self.fetchall()
        if len(userdb)==0: # session id not found
            self.set_default_user()
        else: 
            self.load_user(userdb[0][1])
            self.sid=userdb[0][0];
            try:
                form = cgi.FieldStorage()     
                menu = form.getfirst('menu','') 
                pform = form.getfirst('pform','html')
                if pform == 'html' and not (menu=="getfile" or menu=="getDICOMImage"):
                    self.execute("update "+cf['mysql_protocol_db']+".session set last_action=%s where id=%s and end_time is Null",(now,self.sid))
                    if menu=="login" or menu=="change_password" or menu=="change_password_admin" or menu=="add_user":
                        self.execute("insert into "+cf['mysql_protocol_db']+".activity_log (sessionid,time,menu_item,parameters,fields) values(%s,%s,%s,%s,%s)",(self.sid,now,menu,"",""))
                    else:    
                        self.execute("insert into "+cf['mysql_protocol_db']+".activity_log (sessionid,time,menu_item,parameters,fields) values(%s,%s,%s,%s,%s)",(self.sid,now,menu,str(os.environ.get("REQUEST_URI",'')),str(form)))
                self.commit();
            except:
                raise
            #self.sid=userdb[0][1];
            self.session_key=userdb[0][2]
        
    def can(self,permission):
        # ask if user has permissions to ...
        
        if self.admin or ('admin' in self.user_permissions): # admin can do everthing
            return True
        
        if permission in self.user_permissions:
            return True
           
        if permission=='admin':
            return self.admin

        if permission=='edit':
            return self.edit_allowed

        if permission=='view':
            return self.view_allowed

        if permission=='limitview':
            return self.limitview_allowed
    
        if permission=='CTPMT:download':
            return self.download_allowed

        if permission=='change_passwd':        
            return self.change_passwd_allowed
            
        return False   
            
    def logout(self):
        now=datetime.datetime.utcnow()
        self.execute("update "+cf['mysql_protocol_db']+".session set end_time=%s where keyvalue=%s and end_time is Null",(now,self.session_key))
        self.select("select id,uname,passwd,first_name,last_name from "+cf['mysql_protocol_db']+".users where uname=%s",self.user)    
        return self.fetchone()
        
        
    def login(self,userid,location,browser):
        # returns cookie
        
        now=datetime.datetime.utcnow()
        key=random.randint(0,1000000000);
        expiration = now + datetime.timedelta(days=1)
        ##self.execute('start transaction')
        newid=self.insert("insert into "+cf['mysql_protocol_db']+".session (keyvalue,userid,start_time,location,useragent) values (%s,%s,%s,%s,%s)",(key,userid,now,location,browser))
        ##self.execute('lock tables '+cf['mysql_protocol_db']+'.session write')
        ##self.execute('select max(id)+1 from '+cf['mysql_protocol_db']+'.session');
        ##newid=self.fetchone()[0];
        ##self.execute("insert into "+cf['mysql_protocol_db']+".session (id,keyvalue,userid,start_time,location,useragent) values (%s,%s,%s,%s,%s,%s)",(newid,key,userid,now,location,browser))
        ##self.execute('unlock tables');
        self.get_session(key)  
        ##self.commit()
        return (key,expiration.strftime("%a, %d-%b-%Y %H:%M:%S PST"))
        
    def login_forward(self,title="",ctproto='yes',no_view='no'):
        try:
            nxt=os.environ["REQUEST_URI"]
        except:
            nxt=''
            
        load_url="ldap_login.py?%s" % urllib.urlencode({'menu':'login','ctproto':ctproto,'title':title,'next':nxt,'no_view':no_view})
    
        out="\n"
        out+= """\
        <html>
        <head><meta http-equiv="X-UA-Compatible" content="IE=edge" />"""
        out+=  """<meta http-equiv="refresh" content="0;URL=%s">""" % load_url    
        out+=  """<title>CT protocols</title></head><body>
        <A href="%s">Please login here.</a>
        </body></html>
           """     % load_url  
        return out

    def open_connection(self,host,user,passwd,db):
        pass
        
    def select(self,q,v):
        pass
        
    def create(self,q,v):
        pass
    
    def drop(self,q,v):
        pass
        
    def update(self,q,v):
        pass

    def delete(self,q,v):
        pass
        
    def insert(self,q,v):
        pass 
        
    def fetchone(self):
        pass

    def fetchall(self):
        pass

    def fetchtodict(self):
        pass
        
    
    def start_transaction(self):
        pass
        
    def commit(self):
        pass
        
    def rollback(self):
        pass


    def makeMetaPivotQuery(self,tab,fieldlist,uname=False):
        """ make a pivot SQL query string. 
            tab is the table with (name,value) pairs.
            field list is a list of either strings with the field name or a list of 
            lists with (group_operator,field_name,type_cast)
        """
        q=[]
        for e in fieldlist:
            if isinstance(e, (list, tuple)):
                colname=e[1];
                s=e[0]+"(CASE WHEN "+tab+".name='"+e[1]+"' THEN "
                if len(e)>2:
                    s+=" CAST("+tab+".value as %s) " % e[2]
                else:
                    s+=" "+tab+".value " 
                s+="END)  AS `"+colname+"`"
                q.append(s)
                if uname:
                    s=e[0]+"(CASE WHEN "+tab+".name='"+e[1]+"' THEN "
                    s+=" "+tab+".uname "
                    s+="END)  AS `"+colname+"_uname`"
                    q.append(s)
                
            else:
                colname=e;
                q.append("MAX(CASE WHEN "+tab+".name='"+e+"' THEN "+tab+".value END) as `"+colname+"`")
                if uname:
                    q.append("MAX(CASE WHEN "+tab+".name='"+e+"' THEN "+tab+".uname END) as `"+colname+"_uname`")
    
                
                
        qq=',\n'.join(q)
        return qq    
    
    def makePivotQuery(self,tab,fieldlist):
        """ make a pivot SQL query string. 
            tab is the table with (name,value) pairs.
            field list is a list of either strings with the field name or a list of 
            lists with (group_operator,field_name,type_cast)
        """
        q=[]
        for e in fieldlist:
            if isinstance(e, (list, tuple)):
                colname=e[1];
                s=e[0]+"(CASE WHEN "+tab+".name='"+e[1]+"' THEN "
                if len(e)>2:
                    s+=" CAST("+tab+".value as %s) " % e[2]
                s+="END)  AS `"+colname+"`"
                q.append(s)
            else:
                colname=e;
                q.append("MAX(CASE WHEN "+tab+".name='"+e+"' THEN "+tab+".value END) as `"+colname+"`")
                
                
        qq=',\n'.join(q)
        return qq
    
    def select_jq(self,fields,tables,v,order,page=1,rows=100):
        # query for jqGrid
        q='select count(*) as cnt '+tables
        self.debug_query=q
        self.execute(q,v);
        count=int(self.fetchone()[0]);
        if count>0:
            total_pages = np.ceil(float(count)/float(rows));
        else:
            total_pages = 0;
        page = np.min([total_pages, page]);
        start = np.max([int(rows*page - rows),0]);    
        
        q="select "+fields+tables+" "+order+" LIMIT "+str(start)+","+str(rows)
        self.debug_query=q
        self.execute(q,v)
        description=self.c.description;
        res={'page':page,'total':total_pages,'records':count,'description':description}
        res['rows']=[]
        for r in self.fetchall():
            res['rows'].append({'cell':r})
        json_out=json.dumps(res); 
        return json_out
        


       
class mysql_connection(db_connection):
    
    def __init__(self):
        db_connection.__init__(self)
        self.auto_commit=True
    
    def setAutoCommit(self,c=True):
        self.auto_commit=c
        
    def open_connection(self,host,user,passwd,db):
        import MySQLdb
        self.db=MySQLdb.connect(host=host,user=user,passwd=passwd,db=db) 
        self.c=self.db.cursor()
        
    def select(self,q,v=None):
        self.execute(q,v)
        
    def create(self,q,v=None):
        self.execute(q,v)
        
    def update(self,q,v=None):
        self.execute(q,v)

    def delete(self,q,v=None):
        self.execute(q,v)   
        
    def insert(self,q,v=None,commit=True):
        self.execute(q,v)
        self.c.execute('select LAST_INSERT_ID()')
        try:
            last_index=int(self.c.fetchone()[0])
        except:
            raise
        finally:
            if commit or self.auto_commit:
                self.db.commit();
        return last_index
        
    def fetchone(self):
        return self.c.fetchone()

    def fetchall(self):
        return self.c.fetchall()
        
    def fetchtodict(self):
        datacol=self.fetchall()
        col_names=self.c.description
        data=[]
        for r in datacol:
            row={}
            for (i,c) in enumerate(r):
                row[col_names[i][0]]=c
            data.append(row)
        return data

    def start_transaction(self):
        self.db.start_transaction();
        
    def commit(self):
        self.db.commit();
        
    def rollback(self):
        self.db.rollback()
        
    def drop(self):
        self.db.commit();
        
    def execute(self,q,v=None,commit=True):
        self.c.execute(q,v)
        if commit or self.auto_commit:
            self.db.commit();
        
    def close(self):
        self.commit()
        self.db.close()

    def waitfortables(self,tables,db=None,timeout=120,verbose=0,sleep=1):
        import time as wtm
        if not isinstance(tables,(list,tuple)):
            tables=(tables,);
        wait = True
        cnt=0
        if db is None:
            self.execute("select database();")
            db=self.fetchone()[0]
            
        print_log('Checking for %s' % tables)
        while wait and cnt<timeout:
          cnt+=1
          q = """SHOW OPEN TABLES 
                    where (IN_use or Name_locked)
                    and `Database` = '"""+db+"""'
                    and `Table` in ("""+','.join(["'%s'" % i for i in tables])+""")
                                         """
          ##print_log( q ) 
          self.execute( q )
          used_tables = self.fetchall()
          wait = len(used_tables) > 0
          if verbose>0 and wait:
            tabs=[]
            for li in used_tables:
              tabs.append('%s.%s' % (li[0],li[1]))
            print ('used : ' + ','.join(tabs))
            
          wtm.sleep(1.0);
            
        return not wait
                    
        
class sqlite_connection(db_connection):
    def open_connection(self,host,user,passwd,db):
        import sqlite3
        self.db=sqlite3.connect(db) 
        self.c=self.db.cursor()
        
    def select(self,q,v=None):
        self.execute_likemysql(q,v)
        
    def create(self,q,v=None):
        self.execute_likemysql(q,v)
        
    def update(self,q,v=None):
        self.execute_likemysql(q,v)

    def delete(self,q,v=None):
        self.execute_likemysql(q,v) 
        
    def insert(self,q,v=None):
        self.execute_likemysql(q,v)  
        return c.lastrowid
        
    def fetchone(self):
        return self.c.fetchone()

    def fetchall(self):
        return self.c.fetchall()

    def start_transaction(self):      
        self.db.start_transaction();        

    def commit(self):
        self.db.commit()
        
    def rollback(self):
        self.db.rollback()        

    def drop(self):
        self.execute_likemysql(q,v) 
        
    def execute(self,q,v=None):
        self.execute_likemysql(q,v)   
        
    def execute_likemysql(self,q,v):
        q=q.replace("""%s""",'?');
        try:
            if v is None:
                self.c.execute(q)
            else:
                if not isinstance(v,(list,tuple)):
                    v=(v,);
                self.c.execute(q,v) 
    #            if q.startswith('insert') or q.startswith('update') or q.startswith('create') or q.startswith('delete'):
    #                self.db.commit();
        except:
            print >> sys.stderr, "query: '%s'\n" % q
            raise

    def close(self):
        self.commit()
        self.db.close()

def parse_config(filename):
    COMMENT_CHAR = '#'
    OPTION_CHAR =  '='
    options = {}
    f = open(filename)
    for line in f:
        # First, remove comments:
        if COMMENT_CHAR in line:
            # split on comment char, keep only the part before
            line, comment = line.split(COMMENT_CHAR, 1)
        # Second, find lines with an option=value:
        if OPTION_CHAR in line:
            # split on option char:
            option, value = line.split(OPTION_CHAR, 1)
            # strip spaces:
            option = option.strip()
            value = value.strip()
            # store in dictionary:
            options[option] = value
    f.close()
    return options