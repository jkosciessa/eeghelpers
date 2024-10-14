function [index parm zval] = THG_FASTER_3_ICA_artifacts(cfg,data)

%% defaults
if ~isfield(cfg,'criterion'); criterion = 3; else criterion = cfg.criterion; end
if ~isfield(cfg,'recursive'); recursive = 1; else recursive = strcmp(cfg.recursive,'yes'); end

%% components

comp = ft_componentanalysis(cfg,data);

%% parameter:

%% - spatial kurtosis

parm.ica_kurt = kurtosis(comp.topo)';
zval.ica_kurt = zscore(parm.ica_kurt);

%% - hurst exponent

% calculate hurst exponent
for t = 1:length(comp.trial)
    display(['processing trial ' num2str(t)])
for c = 1:length(comp.label)
    hurst(c,t) = cm_heuristic_hurst_exponent(comp.trial{t}(c,:));
end; clear c
end; clear t

% z statistic of average hurst exponent
parm.ica_hurst = mean(hurst,2);
zval.ica_hurst = zscore(parm.ica_hurst);

%% - median gradient

% calculate gradients (trial-wise)
for t = 1:length(comp.trial)
    med{t} = diff(comp.trial{t}')';
end; clear t

% median gradient
parm.ica_med = median(cell2mat(med)')';
zval.ica_med = zscore(parm.ica_med);

%% - high-frequency distribution

% demean
cfg_.demean = 'yes';
comp_       = ft_preprocessing(cfg_,comp);

% normalization
tmp = cell2mat(comp_.trial);
SD  = std(tmp',1)';
for t = 1:length(comp.trial)
    comp_.trial{t} = comp_.trial{t} ./ (SD * ones(1,size(comp_.trial{t},2)));
end; clear t

% prepare fft
fftcfg.method     = 'mtmfft';
fftcfg.output     = 'pow';
fftcfg.channel    = 'all';
fftcfg.foilim     = [cfg.fft.lowlim cfg.fft.uplim];
fftcfg.taper      = 'hanning';

% fft
fftdat = ft_freqanalysis(fftcfg,comp_);

% zscores by frequenices
zfft = zscore(fftdat.powspctrm);

% mean & subsequent zscore
parm.ica_fft = mean(zfft(:,find(fftdat.freq >= 30 & fftdat.freq <= 100)),2);
zval.ica_fft = zscore(parm.ica_fft);

%% high- to low-freq ratio

ind1 = find(fftdat.freq <= 30);
ind2 = find(fftdat.freq > 30);

fft1 = mean(fftdat.powspctrm(:,ind1),2);
fft2 = mean(fftdat.powspctrm(:,ind2),2);

% mean & subsequent zscore
parm.ica_rat = fft2./fft1;
zval.ica_rat = zscore(parm.ica_rat);

%% find outlier

% temporary zscores
tmpz = zval;

% spatial kurtosis outlier
tmpz.ica_kurt = outlier2nan(tmpz.ica_kurt,criterion,recursive);

% hurst exponent outlier
tmpz.ica_hurst = outlier2nan(tmpz.ica_hurst,criterion,recursive);

% median gradient outlier
tmpz.ica_med = outlier2nan(tmpz.ica_med,criterion,recursive);

% fft outlier
tmpz.ica_fft = outlier2nan(tmpz.ica_fft,criterion,recursive);

% ration outlier
tmpz.ica_rat = outlier2nan(tmpz.ica_rat,criterion,recursive);

%% plot outlier
% figure; imagesc(isnan([tmpz.ica_kurt tmpz.ica_hurst tmpz.ica_med tmpz.ica_fft tmpz.ica_rat]))

%% mark outlier

index  = find( isnan(tmpz.ica_kurt) | isnan(tmpz.ica_hurst) | ...
               isnan(tmpz.ica_med) | isnan(tmpz.ica_fft) | isnan(tmpz.ica_rat) );

% alternative: fixed values
index2 = find(parm.ica_kurt > 30 | parm.ica_rat > 1 );

% merge
index  = unique([index; index2]);
         
% exclude blink, move, heart components
cnt = 1;
ex  = [];
for j = 1:length(cfg.labeled)
    ind_ = find(index == cfg.labeled(j));
    if ~isempty(ind_)
        ex(cnt) = ind_;
        cnt = cnt + 1;
    end
    clear ind_
end; clear j

% keep unique indices
index(ex) = [];
index = sortrows(index);
    
end

%% subfunction outlier2nan (replace outliers with NaN)
function data = outlier2nan(data,criterion,recursive)

%% find epochs

% make sure data orientation is ok (i.e. N X 1 data points)
sz = size(data);
if sz(1) == 1 && sz(2) > 1
    data = data';
elseif sz(2) == 1 && sz(1) > 1
    data = data;
end

% temporary z values
z = cm_nanzscore_140302(data);

% initialize index variable
index = [];

% find indices to exclude
index = find( z > criterion );

% replace outliers with NaNs
data(index) = NaN;
z(index)    = NaN;

% recursive exclusion
if recursive
if ~isempty(index)

    check = 0;
    while check == 0

        % number of excluded outliers
        Nex = length(index);

        % new zscore calculation after outlier exclusion
        z = cm_nanzscore(z);

        % find channels to exclude
        index_2 = find( z > criterion );

        % update index
        index = [index; index_2];

        % update data
        data(index) = NaN;
        z(index)    = NaN;

        % check if additional channel excluded
        if Nex == length(index)
            check = 1;
        end

        % clear variables
        clear Nex index_2

    end; clear check

end
end

end
