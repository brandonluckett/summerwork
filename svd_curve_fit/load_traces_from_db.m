function [t,av,opt_sig,opt_bg]=load_traces_from_db(dbc,bgSeriesUIDs,sigSeriesUIDs,opt)

if not(exist('opt','var'))
    opt=struct();
end
locations     = get_opt(opt,'locations',py.dict());
metastudy      = get_opt(opt,'metastudy',77);

% collection variable for output parameters
pars=struct(); 

% Load backgrounds
%%keyboard
[t_sig,data_bg,sig_bg,stages_bg,files_bg]=loadSeriesByInstanceUIDs(dbc,bgSeriesUIDs,locations,metastudy);
[t,av_bg,opt_bg]=correct_jumps(t_sig,data_bg,stages_bg,opt);
opt_bg.bg = mean(av_bg,2);
opt_bg.av = av_bg;

% Load siganls

[t_sig,data_sig,sig,data_stages,files_sig]=loadSeriesByInstanceUIDs(dbc,sigSeriesUIDs,locations,metastudy);
[t,av_sig,opt_sig]=correct_jumps(t_sig,data_sig,data_stages,opt);
opt_sig.av=av_sig;
av = av_sig-repmat(opt_bg.bg,[1 size(av_sig,2) 1]);
