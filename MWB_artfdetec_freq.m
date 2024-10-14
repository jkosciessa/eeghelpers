function outdat = MWB_artfdetec_freq(cfg,data)

%--------------------------------------------------------------------------
% required arguments:
%--------------------------------------------------------------------------
% data - according to ft_preprocessing output
% cfg.freq.foi
%
%--------------------------------------------------------------------------
% optional arguments
%--------------------------------------------------------------------------
% cfg.visualize 
% cfg.visualtype = {'chan'}, or {'trial'}, or {'chan','trial'};
%
%--------------------------------------------------------------------------
% MWB, 06/02/2014
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% default settings and sanity checks
%--------------------------------------------------------------------------
if ~isfield(cfg,'channel'), cfg.channel = 'all'; end
if ~isfield(cfg,'method'), error('you have to specify the method to use: freq, kurt, corr \n'); end
if ~isfield(cfg,'visualize'), plotflag = 0; else plotflag = cfg.visualize; end
if ~isfield(cfg,'foi'), error('give freq-range to check - cfg.freq.foi = [lF,hF]'); end
if ~isfield(cfg,'pad'), cfg.pad = 5; end
    
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% specify settings for fft via ft_freqanalysis
%--------------------------------------------------------------------------
fftcfg = [];
fftcfg.method     = 'mtmfft';
fftcfg.output     = 'pow';
fftcfg.channel    = cfg.channel;
fftcfg.keeptrials = 'yes';
fftcfg.pad        = cfg.pad;
fftcfg.foilim     = cfg.foi;
fftcfg.taper      = 'hanning';
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% compute FFT
%--------------------------------------------------------------------------
fftdat = ft_freqanalysis(fftcfg,data);
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% compute relevant z-scores
%--------------------------------------------------------------------------
freqavgFFT = squeeze(mean(fftdat.powspctrm,3));
% compute log
freqavgFFT = log(freqavgFFT);
% compute distribution parameters across all mean-freq values
tmp.vec = reshape(freqavgFFT,[prod(size(freqavgFFT)),1]);
% get freq-distr. without outliers ...
tmp.clean_vec = MWB_iterative_outlierdetection(tmp.vec,2);
% compute mean and std
tmp.m = mean(tmp.clean_vec); tmp.s = std(tmp.clean_vec); tmp = rmfield(tmp,'clean_vec');
% convert to z-scores
zavgFFT = (freqavgFFT - tmp.m) ./ tmp.s;
clear tmp;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% compute outputs
%--------------------------------------------------------------------------
outdat.label      = fftdat.label;
% collect some information about trials
if isfield(data,'sampleinfo')
    outdat.sampleinfo = data.sampleinfo;
end
if isfield(data,'cfg')
if isfield(data.cfg,'trl')
    outdat.trl = data.cfg.trl;
end
end
% channel markers
outdat.chan.mean(:,1) = mean(zavgFFT,1);
tmp.m = mean(outdat.chan.mean); tmp.s = std(outdat.chan.mean);
outdat.chan.zscore(:,1) = (outdat.chan.mean - tmp.m)./ tmp.s; clear tmp;
% trial markers
outdat.trial.mean(:,1) = mean(zavgFFT,2);
tmp.m = mean(outdat.trial.mean); tmp.s = std(outdat.trial.mean);
outdat.trial.zscore(:,1) = (outdat.trial.mean - tmp.m)./ tmp.s; clear tmp;
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% visualize the results?
%--------------------------------------------------------------------------
if plotflag
    if ~isfield(cfg,'visualtype'), cfg.visualtype = {'chan','trial'}; end
    
    MWB_artfdetec_plotdetecres(cfg,outdat);
    
end
%--------------------------------------------------------------------------
        
        
    
