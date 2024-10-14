% The Hurst exponent
%--------------------------------------------------------------------------
% This function does dispersional analysis on a data series, then does a 
% Matlab polyfit to a log-log plot to estimate the Hurst exponent of the 
% series.
%
% This algorithm is far faster than a full-blown implementation of Hurst's
% algorithm.  I got the idea from a 2000 PhD dissertation by Hendrik J 
% Blok, and I make no guarantees whatsoever about the rigor of this approach
% or the accuracy of results.  Use it at your own risk.
%
% Bill Davidson
% 21 Oct 2003

% THG 02.03.2014: algorithm downloaded together with the FASTER toolbox on
% 02.03.2014

function [hurst] = cm_heuristic_hurst_exponent(ts)
%
% input:  ts = 1xN time series
% output: hurst = hurst exponent of the input time series

npoints = length(ts);

yvals = zeros(1,npoints);
xvals = zeros(1,npoints);
ts2   = zeros(1,npoints);

index   = 0;
binsize = 1;

while npoints>4
    
    y=std(ts);
    index=index+1;
    xvals(index)=binsize;
    yvals(index)=binsize*y;
    
    npoints=fix(npoints/2);
    binsize=binsize*2;
    % average adjacent points in pairs    
    for ipoints=1:npoints 
        ts2(ipoints)=(ts(2*ipoints)+ts((2*ipoints)-1))*0.5;
    end
    ts=ts2(1:npoints);
    
end

xvals=xvals(1:index);
yvals=yvals(1:index);

logx=log(xvals);
logy=log(yvals);

p2=polyfit(logx,logy,1);

% Hurst exponent is the slope of the linear fit of log-log plot
hurst=p2(1); 

return;
