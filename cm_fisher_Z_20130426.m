function Z = cm_fisher_Z_20130426(r)
%
% Z = cm_fisher_Z(r)
%
% calculates the Fisher Z transform for correlation coefficients

% THG 26.04.2013

Z = 1/2*log((1+r)./(1-r));

