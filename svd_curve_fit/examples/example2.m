clear all 
%close all

%% This code reads a study rom the db and asks the user to select the background and signal
% 1) The data is jump corrected and put in a matrix (av).
% 2) Singular vectors are computed from av
% 3) The decay curves and the 1st sing. vector are fit to 
%    alpha * exp((t^0.1)/0.4) + beta
% 4) Plot output

%%
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
%locations{27}='/Volumes/di_data1/Data2/SAIF/MRX/squid'; 

%Series=queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.522279114562162526166129',77); good_channels=[1 1 1 1 1 0 1]; % dispersion study dried on plastic
%Series=queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.52227911456406544521301',77);  good_channels=[1 1 1 1 1 1 1]; % ScSi Hcr conj. in BT474 tumor mice
Series=queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.52227911456453016711903',77);  good_channels=[1 1 1 1 1 1 1]; % ScSiPeg data
%Series=queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.522279114561643719805273',77); good_channels=[1 1 1 1 1 0 1]; % Animal study in February
%Series=queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.522279114561695535613784',77); good_channels=[1 1 1 1 1 0 1]; % Peg Study 2016-02-24 MDA
%Series=queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.522279114563183911767230',77); good_channels=[1 1 1 1 1 0 1]; % 81 Peg Study
%Series=queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.52227911456292799626133',77); good_channels=[1 1 1 1 1 0 1]; % 1st day  Peg Study
%Series=queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.522279114561451314318886',77); good_channels=[1 1 1 1 1 0 1]; % Sen Sci Pegs at MDA 02-09-16
Series = queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.522279114562978813824214',77); good_channels=[1 1 1 1 1 0 1]; % New SenSci Peg set
Series = queryStudyUID(dbc,'1.2.826.0.1.3680043.8.498.52227911456197162841904',77);  good_channels=[1 1 1 1 1 0 1]; % Peg Standards

for i=1:length(Series)
    fprintf('%i: %s (%s): %s\n' , i,char(Series{i}{'SeriesUID'}),char(Series{i}{'Acq_nr'}),char(Series{i}{'SeriesDescription'}))
end
bg_idx = input('Please pick BG: ');
sig_idx = input('Please pick signal: ');

%% Load curves and remove background
opt=struct('good_channels',good_channels, ...
           'metastud',metastudy, ...
           'filter_jump',1, ...
           'filter_60Hz',1, ...
           'harm_order',3,...
           'oversample',3, ...
           'lambda',0.01)
           
[t,av,opt_sig,opt_bg]=load_traces_from_db(dbc,{char(Series{bg_idx}{'SeriesUID'})},{char(Series{sig_idx}{'SeriesUID'})},opt);

%% compute reference wave forms

ch = 1 ;
av=squeeze(av(:,:,ch));

% SVD to find "reference curve"
[U,S,V] = svd(av);
ref = U(:,1);
if ref(end)>ref(1) % flip upside down if increasing
    ref=-ref;
end
ref=ref*S(1,1);

% Log fit using Sen Sci method
% here only used to get initial guess for offset
fun_log =  @(r,t)(r(1)*log(1+r(2)./t)+r(3));
fit_par_log = lsqcurvefit(fun_log,[1 1 ref(end)],t(500:end),ref(500:end),[0 0 -10],[1e3 1e8 10]);
yoffset = fit_par_log(3);

% 
fun_exp = @(r,t)(r(1)*exp((-t.^r(3))/r(2))+r(4));

options = optimoptions('lsqcurvefit','Algorithm','trust-region-reflective','MaxFunEvals',1000);
fit_par_exp = lsqcurvefit(fun_exp,[1 1 .1 yoffset],t,ref,[0 0 0 -10],[1e10 1e10 1 10],options);

ref=(ref-fit_par_exp(4))/fit_par_exp(1); % correct ref to lim t->0 ref->1 and t-> inf ref->0

%% fit lines to reference curve
[Lalpha,Lbeta.Lrxy] = multiLinFit(repmat(ref,[1 size(av,2)]),av);

fprintf('tau  : %4.3f s\n',fit_par_exp(2));
fprintf('beta : %3.2f \n',fit_par_exp(3));

%% use fixed exp as the reference
%  Needs to be validated that this is a good choice

pars2=struct();
%ref2=pars.fun_exp([1 5000 0.1 0],t); % reference decay curve
%ef2=fun_exp([1 0.5391  0.0685 0],t);
fix_pars  = [1 0.7  .35 0];
fix_pars  = [1 0.4 .1 0];

ref2=fun_exp(fix_pars,t);

[pars2.Lalpha,pars2.Lbeta,pars2.Lrxy] = multiLinFit(repmat(ref2,[1 size(av,2)]),av); % Lin fit decay curves to reference (LBeta is the slope, LAlpha the offset)
fprintf('Signal strength:\n')
pars2.Lbeta
fprintf('R^2:\n');
pars2.Lrxy
fprintf('Stage positions:\n');
%opt_sig.stages


%% plots
%close all
figure,
plot(t,squeeze(opt_bg.bg))
xlabel('time (s)'); ylabel('sig (V)');title('Background signal');

figure,
plot(t,av-repmat(pars2.Lalpha,[size(av,1) 1]),'b',t,ref,'r'); legend(); xlabel('time (s)'); ylabel('(V)');title('bg corrected raw');

figure,
subplot(1,3,1)
plot(t,U(:,1:5)); xlabel('time (s)'); ylabel('(V)');title('Dominant SV''s');
subplot(1,3,2)
tt=linspace(0,t(end),10000);
best_fit_tt = ((fun_exp(fit_par_exp,tt)-fit_par_exp(4))/fit_par_exp(1)).';
[pars3.Lalpha,pars3.Lbeta,pars3.Lrxy] = multiLinFit(ref2,ref); % Lin fit decay curves to reference (LBeta is the slope, LAlpha the offset)
mod_fit_tt = fun_exp(fix_pars,tt)';
plot(t,ref,'b',tt,best_fit_tt,'r',tt,mod_fit_tt,'m'); legend('dominant SV','best exp fit','fixed exp model')

xlabel('time (s)'); ylabel('reference sig (V)');title('reference fit');
subplot(1,3,3)
plot(ref2,ref); xlabel('exp ref'); ylabel('sig ref');title('Model (ref) linearity to dominant SV');

figure,
plot(ref2,av,'.-');% xlim([0 ref(1)]);
xlabel('reference sig (V)'); ylabel('bg correted sig (V)');title('Signal linearity to model');
