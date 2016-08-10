function [t_sig,data,sig,stages,files]=loadSeriesByInstanceUIDs(dbc,uids,locations,metastudy)
% Query Meta Databse for all files of a series and load load the tdms files
% into the data cell array.
% t_sig is the time since pulse for all traces
% data is a cell array with one cell per stage position
%      data{1}...data{n} is a 3D array with dimenstions time,pulses,chennels)
% sig is a cell array with all raw tdms data structures
% stages is a vector with stage positions (stage positions are rounded to
%        one decimal
% files is a python array with the metadb entries
% locations a python dictionary with the path to a particular location

s=sprintf('("%s")',strjoin(uids,'","'));
data_type='raw';

% Get location table and replace with locations from passed argument 
dbc.execute('select id,parameters from external_location');
loc=py.dict();
if not(exist('locations','var'))
    locations=py.dict();
end
for l = dbc.fetchtodict()
    %keyboard
    if not(locations.has_key(py.long(l{1}{'id'})))
        loc{py.long(l{1}{'id'})}=l{1}{'parameters'};
    else
        loc{py.long(l{1}{'id'})}=locations{py.long(l{1}{'id'})};
    end
end

% % get stage positions from db
% q=py.str(['select *,count(*) as cnt from (SELECT '  ...
%             '(cast(m0.value as decimal(5,1))) as Xstage,' ...
%             '(cast(m1.value as decimal(5,1))) as Ystage,' ...
%             '(cast(m2.value as decimal(5,1))) as Zstage ' ...
%             'FROM external_files f '  ...
%             'JOIN external_meta_info m0 on f.id=m0.file_id and m0.name="Xstage" ' ...
%             'JOIN external_meta_info m1 on f.id=m1.file_id and m1.name="Ystage" ' ...
%             'JOIN external_meta_info m2 on f.id=m2.file_id and m2.name="Zstage" ' ...
%             'WHERE f.study_id = %s and f.SeriesUID in ' ...
%             s ...
%             ') a ' 
%            % ' group by Xstage,Ystage,Zstage'
%             ]);
% v={py.str(metastudy)};
% dbc.execute(q,v); 
% stages=[];
% i=1;
% for st=dbc.fetchall()
%     for j=1:4
%        % keyboard
%         stages(i,j)=double(py.float(cell(cell(st){1}){j}));
%     end
%     i=i+1;
% end

% query for file locations and names
q = ['SELECT '  ...
            'f.id, ' ...
            'f.location,f.path,' ...
            'cast(m0.value as decimal(5,1)) as Xstage,' ...
            'cast(m1.value as decimal(5,1)) as Ystage,' ...
            'cast(m2.value as decimal(5,1)) as Zstage, ' ...
            'UNIX_TIMESTAMP(to_local(cast(m3.value as datetime))) as file_modified ' ...
            'FROM external_files f '  ...
            'JOIN external_location l on f.location=l.id ' ...
            'JOIN external_meta_info m0 on f.id=m0.file_id and m0.name="Xstage" ' ...
            'JOIN external_meta_info m1 on f.id=m1.file_id and m1.name="Ystage" ' ...
            'JOIN external_meta_info m2 on f.id=m2.file_id and m2.name="Zstage" ' ...
            'LEFT JOIN external_meta_info m3 on f.id=m3.file_id and m3.name="file_modified" ' ...
            'WHERE f.study_id = %s and f.SeriesUID in ' ...
            s ...
            ' ORDER BY cast(m3.value as datetime)'
            ];
        
             % 'JOIN external_meta_info m on f.id=m.file_id and m.name="data_type" and m.value=%s ' ...
       

dbc.execute(q,{metastudy});
files = dbc.fetchtodict();
sig=cell(length(files),1);
stages=zeros(length(files),3);
%keyboard
fn = char(loc{files{1}.get('location')}+'/'+files{1}.get('path'));
sig{1} = TDMS_getStruct(fn);
[t_sig traces_sig_org]=pre_process_channel3(sig{1});
Nch=size(traces_sig_org,3)-1; % last channel is magnetometer
data=cell(size(stages,1),1);
for i = 1:length(files)
    
    stage=[double(py.float(files{i}.get('Xstage'))) ...
           double(py.float(files{i}.get('Ystage'))) ...
           double(py.float(files{i}.get('Zstage'))) ...
          ];
    stages(i,:)=stage;
    jstage = i; % one stage per file
    %jstage = find(sum(((stages(:,1:3))-repmat((stage),[size(stages,1) 1])).^2,2)==0);  
    fn = char(loc{files{i}.get('location')}+'/'+files{i}.get('path'));
    sig{i} = TDMS_getStruct(fn);
    [t_sig traces_sig_org]=pre_process_channel3(sig{i});
    data{i} = traces_sig_org;
end
% keyboard