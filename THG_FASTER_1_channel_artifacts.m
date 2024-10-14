function [index parm zval] = cm_FASTER_1_channel_artifacts(cfg,data)

%% defaults
if ~isfield(cfg,'criterion'); criterion = 3; else criterion = cfg.criterion; end
if ~isfield(cfg,'recursive'); recursive = 1; else recursive = strcmp(cfg.recursive,'yes'); end

%% mean correlation between channels

tmp = cell2mat(data.trial);

% correlation
cor = corr(tmp');

% set autocorrelation to NaN
for j = 1:length(cor)
    cor(j,j) = NaN;
end; clear j

% z statistic
parm.chan_cor = cm_inv_fisher_Z(nanmean(cm_fisher_Z(cor))'); 
zval.chan_cor = zscore(parm.chan_cor); 

%% channel variance

% z statistic
parm.chan_var = var(tmp',1)'; 
zval.chan_var = zscore(parm.chan_var); 

%% hurst exponent

% calculate hurst exponent
for t = 1:length(data.trial)
    display(['processing trial ' num2str(t)])
for c = 1:length(data.label)
    hurst(c,t) = cm_heuristic_hurst_exponent(data.trial{t}(c,:));
end; clear c
end; clear t

% z statistic of average hurst exponent
parm.chan_hurst = mean(hurst,2);
zval.chan_hurst = zscore(parm.chan_hurst);

%% find outlier

% temporary zscores
tmpz = zval;

% correlation outlier
tmpz.chan_cor = cm_outlier2nan(tmpz.chan_cor,'<',criterion,recursive);

% variance outlier
tmpz.chan_var = cm_outlier2nan(tmpz.chan_var,'>',criterion,recursive);

% hurst exponent outlier
tmpz.chan_hurst = cm_outlier2nan(tmpz.chan_hurst,'>/<',criterion,recursive);

%% mark outlier

index = find( isnan(tmpz.chan_cor) | isnan(tmpz.chan_var) | isnan(tmpz.chan_hurst) );