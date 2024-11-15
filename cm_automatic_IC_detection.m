function [iclabels] = cm_automatic_IC_detection(data,icadata)

% automatically detects IC most likely representing eye blinks, eye 
% movements, muscle artifacts related to eye blinks and eye movements, as 
% well as ECG artifacts

%%  get most likely eye & heart components

ica = cell2mat(icadata.trial);
dat = cell2mat(data.trial);

%% find BLINK component

% get ior channel
ior = dat(find(strcmp(data.label,'vEOG')),:)';

% correlation between ior and ICs
for j = 1:size(ica,1)
    
    r_bli(j,1) = corr(ica(j,:)',ior);
    
end; clear j

% get "significant" correlation
bli = cm_get_sig_corr(r_bli,2);

% clear variables
clear r_bli

%% find MOVE component

% get EOG channels
eog = dat(find(strcmp(data.label,'hEOG')),:)';

% correlation between EOG and ICs
for j = 1:size(ica,1)
    
    r_mov(j,1) = corr(ica(j,:)',eog);
    
end; clear j

% delete blink component
excl = [];
if bli(1,3) == 1
    excl = [excl bli(1,1)];
end

% get "significant" correlation
mov = cm_get_sig_corr(r_mov,2,excl);

% clear variables
clear r_mov excl

%% find MOVE muscle spikes

% prepare EOG channel data
eog = [abs(diff(eog)); 0];

% correlation between EOG and ICs
for j = 1:size(ica,1)
    
    r_spk(j,1) = corr(ica(j,:)',eog);
    
end; clear j

% delete blink & move components
excl = [];
if bli(1,3) == 1
    excl = [excl bli(1,1)];
end
if mov(1,3) == 1
    excl = [excl mov(1,1)];
end

% get "significant" correlations
spk = cm_get_sig_corr(r_spk,2,excl);

% clear variables
clear r_spk excl

%% find BLINK muscle component

% prepare components
ica2 = ica.^2;
    
% correlation between ior and squared ICs
for j = 1:size(ica,1)
    
    r_msc(j,1) = abs(corr(ica2(j,:)',ior));
    
end; clear j

% delete blink & move components
excl = [];
if bli(1,3) == 1
    excl = [excl bli(1,1)];
end
if mov(1,3) == 1
    excl = [excl mov(1,1)];
end
if spk(1,3) == 1
    excl = [excl spk(1,1)];
end

% get "significant" correlations
msc = cm_get_sig_corr(r_msc,2,excl);

% clear variables
clear ica2 excl

%% find HEART component

% get ecg
ecg = dat(find(strcmp(data.label,'ECG')),:)';

if ~prod(size(ecg))==0

    % correlation between ECG and ICs
    for j = 1:size(ica,1)

        r_hrt(j,1) = abs(corr(ica(j,:)',ecg));

    end; clear j

    % delete blink & move components
    excl = [];
    if bli(1,3) == 1
        excl = [excl bli(1,1)];
    end
    if mov(1,3) == 1
        excl = [excl mov(1,1)];
    end
    if spk(1,3) == 1
        excl = [excl spk(1,1)];
    end
    if msc(1,3) == 1
        excl = [excl msc(1,1)];
    end

    % get "significant" correlations
    hrt = cm_get_sig_corr(r_hrt,2,excl);

    % clear variables
    clear r_hrt ica2
    
    % existence of automatic hrt detection
    hrt_exist = 1;
    
else
    
    % existence of automatic hrt detection
    hrt_exist = 0;

end

%% generate fields for ICA labels

iclabels.nol = [];
iclabels.oks = [];
% blink components
if bli(1,3) == 1
    iclabels.bli = bli(1,1);
else
    iclabels.bli = [];
end
if msc(1,3) == 1
    iclabels.bli = [iclabels.bli msc(1,1)];
end
% eye movement components
if mov(1,3) == 1
    iclabels.mov = mov(1,1);
else
    iclabels.mov = [];
end
if spk(1,3) == 1
    iclabels.mov = [iclabels.mov spk(1,1)];
end
iclabels.tng = [];
% ecg component
if hrt_exist == 1
    if hrt(1,3) == 1
        iclabels.hrt = hrt(1,1);
    else
        iclabels.hrt = [];
    end
else
    iclabels.hrt = []; 
end
iclabels.art = [];
iclabels.elc = [];
iclabels.ref = [];
iclabels.unc = [];

% keep correlations
iclabels.cbli = bli;
iclabels.cblm = msc;
iclabels.cmov = mov;
iclabels.cspk = spk;
if hrt_exist == 1
    iclabels.chrt = hrt;
else
    iclabels.chrt = [];
end

% documentation
iclabels.version = '20141217';

%% subfunction: "get significant correlation"
function ic = cm_get_sig_corr(r_ic,crit,excl)

% Fisher Z transform
Z = cm_fisher_Z(r_ic);

% exclude data
if exist('excl','var')
    Z(excl) = NaN;
end

% criterion
mn = nanmean(Z);
sd = nanstd(Z,1);

% set up blink table
ic(:,1) = 1:length(r_ic);
ic(:,2) = r_ic;
ic(:,3) = Z;
ic(:,4) = abs(Z);

% exclude data
if exist('excl','var')
    ic(excl,4) = 0;
end

% sortrows
ic = sortrows(ic,-4);

% check "significance"
for j = 1:length(r_ic);

    if ic(j,2) < 0
    
        ic(j,3) = (ic(j,3) < mn - crit*sd);

    elseif ic(j,2) > 0

        ic(j,3) = (ic(j,3) > mn + crit*sd);

    end
    
end; clear j

% delete Z values
ic(:,4) = [];
