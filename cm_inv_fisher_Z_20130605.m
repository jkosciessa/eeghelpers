function r = cm_inv_fisher_Z_20130605(Z)
%
% r = cm_inv_fisher_Z(Z)
%
% inverse of Fisher's Z transform for correlation coefficients

% THG 05.06.2013

r = (exp(2.*Z) - 1) ./ (exp(2.*Z) + 1);
