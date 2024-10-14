function [index parm zval] = THG_FASTER_4_channel_x_epoch_artifacts(cfg,data)

%% defaults
if ~isfield(cfg,'criterion'); criterion = 3; else criterion = cfg.criterion; end
if ~isfield(cfg,'recursive'); recursive = 1; else recursive = strcmp(cfg.recursive,'yes'); end

%% generate data structure

sz = size(data.trial{1});
nt = length(data.trial);

tmp = zeros([sz(1)*nt sz(2)]);

for t = 1:nt
    tmp((t-1)*sz(1)+1:t*sz(1),:) = data.trial{t};
end; clear t

% overall mean (calculation adopted from FASTER)
alltmp = zeros([size(data.trial{1}) length(data.trial)]);
for t = 1:length(data.trial)
    alltmp(:,:,t) = data.trial{t};
end; clear t
means = mean(mean(alltmp,2),3);
means = repmat(means,nt,1);

%% parameter

% variance
parm.c_x_e_var = var(tmp',1)';

% median gradient
parm.c_x_e_med = median(diff(tmp'))';

% amplitude range
parm.c_x_e_amp = (max(tmp') - min(tmp'))';

% deviation of the mean amplitude
parm.c_x_e_dev = mean(tmp')' - means;

%% zscores

zval.c_x_e_var = zscore(parm.c_x_e_var); 
zval.c_x_e_med = zscore(parm.c_x_e_med); 
zval.c_x_e_amp = zscore(parm.c_x_e_amp); 
zval.c_x_e_dev = zscore(parm.c_x_e_dev); 

%% find outlier

% temporary zscores
tmpz = zval;

% variance outlier
tmpz.c_x_e_var = cm_outlier2nan(tmpz.c_x_e_var,'>',criterion,recursive);

% median gradient outlier
tmpz.c_x_e_med = cm_outlier2nan(tmpz.c_x_e_med,'>',criterion,recursive);

% amplitude range outlier
tmpz.c_x_e_amp = cm_outlier2nan(tmpz.c_x_e_amp,'>',criterion,recursive);

% deviation outlier
tmpz.c_x_e_dev = cm_outlier2nan(tmpz.c_x_e_dev,'>',criterion,recursive);

%% mark outlier

ind_ = find( isnan(tmpz.c_x_e_var) | isnan(tmpz.c_x_e_med) | ...
             isnan(tmpz.c_x_e_amp) | isnan(tmpz.c_x_e_dev) );

index = zeros(sz(1),nt);
index(ind_) = 1;

%% restructure data

% parameter
parm.c_x_e_var = reshape(parm.c_x_e_var,sz(1),nt); 
parm.c_x_e_med = reshape(parm.c_x_e_med,sz(1),nt); 
parm.c_x_e_amp = reshape(parm.c_x_e_amp,sz(1),nt); 
parm.c_x_e_dev = reshape(parm.c_x_e_dev,sz(1),nt); 

% zscores
zval.c_x_e_var = reshape(zval.c_x_e_var,sz(1),nt); 
zval.c_x_e_med = reshape(zval.c_x_e_med,sz(1),nt); 
zval.c_x_e_amp = reshape(zval.c_x_e_amp,sz(1),nt); 
zval.c_x_e_dev = reshape(zval.c_x_e_dev,sz(1),nt); 
