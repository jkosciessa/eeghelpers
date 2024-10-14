function [index parm zval] = cm_MWB_channel_x_epoch_artifacts_20170922(cfg,data)

% 20170922 JQK extended padding to 20

%% defaults
if ~isfield(cfg,'criterion'); criterion = 3; else criterion = cfg.criterion; end
if ~isfield(cfg,'recursive'); recursive = 1; else recursive = strcmp(cfg.recursive,'yes'); end

% clear cfg
clear cfg

%% calculate parameters

%% - kurtosis

cfg.method = 'kurt';

kurt = MWB_artfdetec_kurt(cfg,data);

% clear cfg
clear cfg

%% - low frequencies

cfg.method = 'freq';
cfg.foi = [0.5 2];
cfg.pad = 20;

fft_low = MWB_artfdetec_freq(cfg,data);

% clear cfg
clear cfg

%% - high frequencies

cfg.method = 'freq';
cfg.foi = [30 100];
cfg.pad = 20;

fft_hi = MWB_artfdetec_freq(cfg,data);

% clear cfg
clear cfg

%% calculate stats

% channels
parm.c_kurt = kurt.chan.mean;
zval.c_kurt = kurt.chan.zscore;

parm.c_low = fft_low.chan.mean;
zval.c_low = fft_low.chan.zscore;

parm.c_high = fft_hi.chan.mean;
zval.c_high = fft_hi.chan.zscore;

% trials
parm.t_kurt = kurt.trial.mean;
zval.t_kurt = kurt.trial.zscore;

parm.t_low = fft_low.trial.mean;
zval.t_low = fft_low.trial.zscore;

parm.t_high = fft_hi.trial.mean;
zval.t_high = fft_hi.trial.zscore;

%% find outlier

% temporary zscores
tmp = parm;

% kurtosis outlier
tmp.c_kurt = cm_outlier2nan_20140311(tmp.c_kurt,'>',criterion,recursive);
tmp.t_kurt = cm_outlier2nan_20140311(tmp.t_kurt,'>',criterion,recursive);

% low frequency outlier
tmp.c_low = cm_outlier2nan_20140311(tmp.c_low,'>',criterion,recursive);
tmp.t_low = cm_outlier2nan_20140311(tmp.t_low,'>',criterion,recursive);

% high frequency outlier
tmp.c_high = cm_outlier2nan_20140311(tmp.c_high,'>',criterion,recursive);
tmp.t_high = cm_outlier2nan_20140311(tmp.t_high,'>',criterion,recursive);

%% mark outlier

index.c = find( isnan(tmp.c_kurt) | isnan(tmp.c_low) | isnan(tmp.c_high) );
index.t = find( isnan(tmp.t_kurt) | isnan(tmp.t_low) | isnan(tmp.t_high) );
            

