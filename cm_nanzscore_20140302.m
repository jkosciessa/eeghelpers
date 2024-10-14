function zvals = cm_nanzscore_140302(data)

ind_nan = find(isnan(data));
ind_num = find(~isnan(data));

zvals = zeros(size(data));
zvals(ind_num) = zscore(data(ind_num));
zvals(ind_nan) = NaN;
