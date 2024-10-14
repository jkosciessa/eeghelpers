function [new data] = cm_segmentation_of_continuous_data_fieldtrip_20150825(data,cfg)
%
% data = cm_segmentation_of_continuous_data_fieldtrip_20141217(data,cfg)
%
% segmentation of existing continuous fieldtrip data into segments as
% defined by cfg.trl
% 
%
% data       = fieldtrip data structure (continous data)
% cfg.trl    = trial structure (data points relative to the data in the fieldtrip data structure!)

% 17.12.2014 THG

% 25.08.2015 (THG) changed: checks if field .hdr exists

%%  get data & update fields

% get fields from original data
if isfield(data,'hdr')
    new.hdr = data.hdr;
end
new.label   = data.label;

% get data
for j = 1:size(cfg.trl,1)
    
    % time vector
    n = cfg.trl(j,2) - cfg.trl(j,1) + 1;
    tim = [1/data.fsample:1/data.fsample:n/data.fsample];
    new.time{j}  = tim; clear tim

    % data
    new.trial{j} = data.trial{1}(:,cfg.trl(j,1):cfg.trl(j,2));
    
end; clear j    

% update fields
new.fsample = data.fsample;
new.sampleinfo = cfg.trl(:,1:2);

    
