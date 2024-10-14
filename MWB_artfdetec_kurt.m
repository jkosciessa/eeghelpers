function outdat = MWB_artfdetec_kurt(cfg,data)

%--------------------------------------------------------------------------
% required arguments:
%--------------------------------------------------------------------------
% data - according to ft_preprocessing output
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
if ~isfield(cfg,cfg.method), cfg.(cfg.method) = []; end
% method_cfg = cfg.(cfg.method);
% if ~isfield(method_cfg,'foi'), error('give freq-range to check - cfg.freq.foi = [lF,hF]'); end
% if ~isfield(method_cfg,'pad'), method_cfg.pad = 5; end
    
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% collect some info ...
%--------------------------------------------------------------------------
nr.trl = length(data.trial);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% find selected channels ...
%--------------------------------------------------------------------------
selchan = ft_channelselection(cfg.channel,data.label);
for iC = 1:length(selchan)
    tmpidx(iC,1) = find(strcmp(selchan{iC},data.label));
end

for iT = 1:nr.trl
    data.trial{iT} = data.trial{iT}(tmpidx,:);
end
data.label = data.label(tmpidx);
clear tmpidx iT iC selchan;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% compute kurtosis
%--------------------------------------------------------------------------
fprintf('computing kurtosis \n');
for iT = 1:nr.trl;
    tmp = data.trial{iT};
    avgKURT(iT,:) = kurtosis(tmp,0,2);
end
clear tmp;
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% compute relevant z-scores
%--------------------------------------------------------------------------
% compute log
avgKURT = log(avgKURT);
% compute distribution parameters across all mean-freq values
tmp.vec = reshape(avgKURT,[prod(size(avgKURT)),1]);
% get freq-distr. without outliers ...
tmp.clean_vec = MWB_iterative_outlierdetection(tmp.vec,2);
% compute mean and std
tmp.m = mean(tmp.clean_vec); tmp.s = std(tmp.clean_vec); tmp = rmfield(tmp,'clean_vec');
% convert to z-scores
zavgKURT = (avgKURT - tmp.m) ./ tmp.s;
clear tmp;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% compute outputs
%--------------------------------------------------------------------------
outdat.label      = data.label;
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
outdat.chan.mean(:,1) = sum(zavgKURT,1);
tmp.m = mean(outdat.chan.mean); tmp.s = std(outdat.chan.mean);
outdat.chan.zscore(:,1) = (outdat.chan.mean - tmp.m)./ tmp.s; clear tmp;
% trial markers
outdat.trial.mean(:,1) = sum(zavgKURT,2);
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
        
        
    
