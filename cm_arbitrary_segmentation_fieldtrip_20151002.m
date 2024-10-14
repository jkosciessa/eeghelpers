function [new data] = cm_arbitrary_segmentation_fieldtrip_20151002(data,cfg)
%
% data = cm_arbitrary_segmentation_fieldtrip(data,cfg)
%
% arbitrary segmentation of existing fieldtrip data into segments a
% cfg.length seconds
%
% data       = fieldtrip data structure
% cfg.length = segment length in seconds
% cfg.n      = maximum number of segments
% cfg.type   = sampling of segments:
%              'beg' = n segments from the beginning (default)
%              'end' = n segments from the end
%              'bne' = n/2 segments from the beginning and n/2 segments 
%                      from the end
%              'rnd' = n segments randomly selected

% 26.01.2014 THG
% NOTE: reference to original data points is lost
%
% 02.10.2015 THG
% fix: if now .hdr is defined in data, it is ignored

%%  set default values
if ~isfield(cfg,'type')
    cfg.type  = 'beg';
end

%%  get possible segments

% segment length in number of data points
n = cfg.length * data.fsample;

% get trials and lengths
for j = 1:length(data.trial)
    
    trl(j,1) = j;
    trl(j,2) = length(data.trial{j});
    
end; clear j

% create all possible segments
cnt = 1;
for j = 1:size(trl,1)
    
    left  = trl(j,2); % remaining data poitns in trial
    cnt2 = 1;
    
    while left >= n
        
        % get indices
        seg(cnt,1) = trl(j,1);          % number of trial
        seg(cnt,2) = (cnt2-1)*n + 1;    % starting data point
        seg(cnt,3) = cnt2*n;            % ending data point
        
        % update number of remaining data points
        left = left - n;
        
        % update counters
        cnt  = cnt  + 1;
        cnt2 = cnt2 + 1;
        
    end
    
    % clear variables
    clear cnt2 left
        
end; clear j cnt

%%  choose segments

if size(seg,1) <= cfg.n 
    
    seg = seg;

elseif strcmp(cfg.type,'beg')
    
    seg = seg(1:cfg.n,:);
    
elseif strcmp(cfg.type,'end')

    seg = seg(end-cfg.n+1:end,:);
    
elseif strcmp(cfg.type,'bne')
    
    % size of halves
    n1 = floor(cfg.n/2);
    n2 = length(floor(cfg.n/2) + 1 : cfg.n);

    % segments at the beginning
    seg1 = seg(1:n1,:);
    
    % segments at the end
    seg2 = seg(end-n2+1:end,:);
    
    % chosen segments
    seg  = [seg1; seg2]; clear seg1 seg2
    
elseif strcmp(cfg.type,'rnd')
    
    % set random generator seeds
    rand('seed',cfg.seed);
    randn('seed',cfg.seed);
    
    % select random segments
    ind = randperm(size(seg,1)); ind = sortrows(ind(1:cfg.n)');
    
    seg = seg(ind,:);
    
end

%%  get data & update fields

% time vector
tim = [1/data.fsample:1/data.fsample:n/data.fsample];

% get header information
if isfield(data,'hdr')
    new.hdr     = data.hdr;
end

% get data
for j = 1:size(seg,1)

    new.trial{j} = data.trial{seg(j,1)}(:,seg(j,2):seg(j,3));
    new.time{j}  = tim;
    
end; clear j    

% update fields
new.label   = data.label;
new.fsample = data.fsample;

    
