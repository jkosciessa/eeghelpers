function [cleaneddat removedtrl] = MWB_iterative_outlierdetection(dat, sd, minnrtrlremaining)

% dat = input-vector of data
% sd  = how many sds are acceptable (default = 3)
% minnrtrlremaining = minimum nr of trials that should be kapt after exclusion
%
% cleaneddat = data after outlier removal
% removedtrl = indices of data-points deleted from dat

if nargin < 2, sd = 3; minnrtrlremaining = 50; end
if nargin < 3, minnrtrlremaining = 50; end

% make sure dat is a coloumn-vector
[tmp.s1 tmp.s2] = size(dat);
if tmp.s2 > tmp.s1; dat = dat'; end 
clear tmp;

rundetection = 1; tmp.dat = dat;  removedtrl   = [];
while rundetection > 0
    
    if length(tmp.dat) < minnrtrlremaining
        rundetection = 0;
    else
        
        [tmp.q1 tmp.q2 ol] = testboxplot(tmp.dat, sd, 0, 0); % based on an m-file from mathworks-central
        
        if isempty(ol)
            rundetection = 0;
        else
            % determine the indices for trl in dat
            for i1 = 1:size(ol,1)
                tmp.idx = find(dat == tmp.dat(ol(i1,1)));
                removedtrl = cat(1,removedtrl,tmp.idx); tmp = rmfield(tmp,'idx');
            end
            tmp.dat(ol(:,1)) = [];
            
        end
    end
end
cleaneddat = tmp.dat;

