function data = cm_outlier2nan_20140311(data,comparator,criterion,recursive)
%
% data = cm_outlier2nan_20140311(data,comparator,criterion,recursive)
%
% marks outlier in data as NaN
% input:  data       = [N x 1] vector
%         comparator = '>', '<', '>=', '<=', '>/<'
%         criterion  = criterion*SD as the outlier criterion
%         recursive  = recursive outlier exclusion (1)
%
% output: data = [N x 1] vector; outliers set to NaN

% THG 11.03.2014

%% find epochs

% make sure data orientation is ok (i.e. N X 1 data points)
sz = size(data);
if sz(1) == 1 && sz(2) > 1
    data = data';
elseif sz(2) == 1 && sz(1) > 1
    data = data;
end

% temporary z values
z = cm_nanzscore_20140302(data);

% initialize index variable
index = [];

% find indices to exclude
if strcmp(comparator,'>/<')
    index = find( abs(z) > criterion);
elseif strcmp(comparator,'>') || strcmp(comparator,'>=')
    eval(['index = find( z ' comparator ' criterion );']);
elseif strcmp(comparator,'<') || strcmp(comparator,'<=')
    eval(['index = find( z ' comparator ' criterion*-1 );']);
end

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
        z = cm_nanzscore_20140302(z);

        % find channels to exclude
        if strcmp(comparator,'>/<')
            index_2 = find( abs(z) > criterion);
        elseif strcmp(comparator,'>') || strcmp(comparator,'>=')
            eval(['index_2 = find( z ' comparator ' criterion );']);
        elseif strcmp(comparator,'<') || strcmp(comparator,'<=')
            eval(['index_2 = find( z ' comparator ' criterion*-1 );']);
        end
        
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

