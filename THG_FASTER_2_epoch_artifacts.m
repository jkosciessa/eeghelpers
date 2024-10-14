function [index parm zval] = THG_FASTER_2_epoch_artifacts(cfg,data)

%% defaults
if ~isfield(cfg,'criterion'); criterion = 3; else criterion = cfg.criterion; end
if ~isfield(cfg,'recursive'); recursive = 1; else recursive = strcmp(cfg.recursive,'yes'); end

% overall mean (calculation adopted from FASTER)
alltmp = zeros([size(data.trial{1}) length(data.trial)]);
for t = 1:length(data.trial)
    alltmp(:,:,t) = data.trial{t};
end; clear t
means  = mean(mean(alltmp,2),3);

%% loop trials
for t = 1:length(data.trial)

    % trial data
    tmp = data.trial{t}';

%%  amplitude range
    parm.epoch_amp(1,t) = mean(max(tmp)-min(tmp));

%%  variance
    parm.epoch_var(1,t) = mean(var(tmp,1));

%%  channel deviation
    parm.epoch_dev(1,t) = mean(abs(mean(tmp)' - means));

end; clear t

%% zscores
zval.epoch_amp = zscore(parm.epoch_amp); 
zval.epoch_var = zscore(parm.epoch_var); 
zval.epoch_dev = zscore(parm.epoch_dev); 

%% find outlier

% temporary zscores
tmpz = zval;

% amplitude range outlier
tmpz.epoch_amp = cm_outlier2nan(tmpz.epoch_amp,'>',criterion,recursive);

% variance outlier
tmpz.epoch_var = cm_outlier2nan(tmpz.epoch_var,'>',criterion,recursive);

% channel deviation outlier
tmpz.epoch_dev = cm_outlier2nan(tmpz.epoch_dev,'>',criterion,recursive);

%% mark outlier

index = find( isnan(tmpz.epoch_amp) | isnan(tmpz.epoch_var) | isnan(tmpz.epoch_dev) );

