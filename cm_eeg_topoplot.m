function [handle,Zi,grid,Xi,Yi] = cm_eeg_topoplot(Values,loc_file,MAPLIMITS)

% Plot a single topography
%
% functions needed:
%   - THG_eeg_readlocs
%   - THG_eeg_finputcheck

%% Set defaults

    % whitebk = 'on';  % by default, make gridplot background color = EEGLAB screen background color

    rmax = 0.5;                 % actual head radius - Don't change this!

    GRID_SCALE = 57;            % plot map on a n x n grid
    CIRCGRID   = 201;           % number of angles to use in drawing circles
    AXHEADFAC = 1.3;            % head to axes scaling factor
    CONTOURNUM = 6;             % number of contour levels to plot
    STYLE = 'both';             % default 'style': both,straight,fill,contour,blank
    HEADCOLOR = [0 0 0];        % default head color (black = [0 0 0])
    BACKCOLOR = [1 1 1];
    ELECTRODES = 'on';          % default 'electrodes': on|off|label - set below
    EMARKER = '.';              % mark electrode locations with small disks
    EMARKERSIZE = 6;
    ECOLOR = [0 0 0];           % default electrode color = black
    EMARKERLINEWIDTH = 1;       % default edge linewidth for emarkers
    HLINEWIDTH = 1;             % default linewidth for head, nose, ears
    BLANKINGRINGWIDTH = .05;    % width of the blanking ring 
    HEADRINGWIDTH    = .01;     % width of the cartoon head ring
    % SHADING = 'flat';         % default 'shading': flat|interp

    cmap = colormap;
    cmaplen = size(cmap,1);

%% Read the channel location information

    %[tmpeloc, labels, Th, Rd, indices] = cm_eeg_readlocs(loc_file);
    [tmpeloc, labels, Th, Rd, indices] = readlocs(loc_file);
    Th = pi/180*Th;                              
    allchansind = 1:length(Th);

%%  Channels to plot    

    plotchans = indices;

%     if isfield(tmpeloc, 'X') && isfield(tmpeloc, 'Y')
%         x = [tmpeloc.X];
%         y = [tmpeloc.Y];
%     else
        disp("transforming electrode locations from polar to cartesian coordinates")
        [x,y]   = pol2cart(Th,Rd);
%     end
    plotchans   = abs(plotchans);   % reverse indicated channel polarities
    allchansind = allchansind(plotchans);
    Th          = Th(plotchans);
    Rd          = Rd(plotchans);
    x           = x(plotchans);
    y           = y(plotchans);
    labels      = labels(plotchans); % remove labels for electrodes without locations
    labels      = strvcat(labels); % make a label string matrix
    Values      = Values(plotchans);

%%  Read plotting radius from chanlocs

    plotrad = min(1.0,max(Rd)*1.02);            % default: just outside the outermost electrode location
    plotrad = max(plotrad,0.5);                 % default: plot out to the 0.5 head boundary
    default_intrad = 1;                         % indicator for (no) specified intrad
    intrad = min(1.0,max(Rd)*1.02);             % default: just outside the outermost electrode location
    
%%  Set radius of head cartoon

    headrad = rmax;  % (anatomically correct)

%%  Find plotting channels

    pltchans = find(Rd <= plotrad);             % plot channels inside plotting circle
    intchans = find(x <= intrad & y <= intrad); % interpolate and plot channels inside interpolation square

%%  Eliminate channels not plotted

    allx      = x;
    ally      = y;
    intchans; % interpolate using only the 'intchans' channels
    pltchans; % plot using only indicated 'plotchans' channels

    intValues = Values(intchans);
    Values = Values(pltchans);
    
    % now channel parameters and values all refer to plotting channels only

    allchansind = allchansind(pltchans);
    
    intTh = Th(intchans);           % eliminate channels outside the interpolation area
    intRd = Rd(intchans);
    intx  = x(intchans);
    inty  = y(intchans);
    Th    = Th(pltchans);           % eliminate channels outside the plotting area
    Rd    = Rd(pltchans);
    x     = x(pltchans);
    y     = y(pltchans);

    labels = labels(pltchans,:);

%%  Squeeze channel locations to <= rmax

    squeezefac  = rmax/plotrad;
    intRd       = intRd*squeezefac; % squeeze electrode arc_lengths towards the vertex
    Rd          = Rd*squeezefac;       % squeeze electrode arc_lengths towards the vertex
                              % to plot all inside the head cartoon
    intx        = intx*squeezefac;   
    inty        = inty*squeezefac;  
    x           = x*squeezefac;    
    y           = y*squeezefac;   
    allx        = allx*squeezefac;    
    ally        = ally*squeezefac;   
    % Note: Now outermost channel will be plotted just inside rmax

    % rotate channels based on chaninfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     rotate = 0;

%%  Make the plot

    xmin = min(-rmax,min(intx)); xmax = max(rmax,max(intx));
    ymin = min(-rmax,min(inty)); ymax = max(rmax,max(inty));

    % Interpolate scalp map data
    xi         = linspace(xmin,xmax,GRID_SCALE);   % x-axis description (row vector)
    yi         = linspace(ymin,ymax,GRID_SCALE);   % y-axis description (row vector)
    [Xi,Yi,Zi] = griddata(inty,intx,intValues,yi',xi,'cubic'); % interpolate data ('invdist' replaced by)
    
    % Mask out data outside the head
    mask      = (sqrt(Xi.^2 + Yi.^2) <= rmax); % mask outside the plotting circle
    ii        = find(mask == 0);
    Zi(ii)    = NaN;                         % mask non-plotting voxels with NaNs
    grid      = plotrad;                     % unless 'noplot', then 3rd output arg is plotrad

    % Colormap limits
    amin    = MAPLIMITS(1);
    amax    = MAPLIMITS(2);
    delta   = (xi(2)-xi(1)); % length of grid entry

    % Scale the axes
    cla         % clear current axis
    hold on
    h = gca;    % uses current axes

	set(gca,'Xlim',[-rmax rmax]*AXHEADFAC,'Ylim',[-rmax rmax]*AXHEADFAC,...
        'color','w','xcolor','w','ycolor','w','zcolor','w','xtick',[],'ytick',[]);

%%  plot

    tmph = surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,...
        'EdgeColor','none','FaceColor','flat'); % 'FaceColor','interp' or 'flat'
    colormap jet
    
%%  Set color axis

    caxis([amin amax]) % set coloraxis
    handle = gca;

%%  Plot filled ring to mask jagged grid boundary

    hwidth  = HEADRINGWIDTH;                        % width of head ring 
    hin     = squeezefac*headrad*(1- hwidth/2);     % inner head ring radius

    rwidth  = BLANKINGRINGWIDTH;                    % width of blanking outer ring
    rin     =  rmax*(1-rwidth/2);                   % inner ring radius
    if hin>rin
        rin = hin;                                  % don't blank inside the head ring
    end

%%  mask the jagged border around rmax

    circ    = linspace(0,2*pi,CIRCGRID);
    rx      = sin(circ); 
    ry      = cos(circ); 
    ringx   = [[rx(:)' rx(1) ]*(rin+rwidth)  [rx(:)' rx(1)]*rin];
    ringy   = [[ry(:)' ry(1) ]*(rin+rwidth)  [ry(:)' ry(1)]*rin];

    ringh   = patch(ringx,ringy,0.01*ones(size(ringx)),BACKCOLOR,'edgecolor','none'); hold on 

%%  Plot head outline

    headx = [[rx(:)' rx(1) ]*(hin+hwidth)  [rx(:)' rx(1)]*hin];
    heady = [[ry(:)' ry(1) ]*(hin+hwidth)  [ry(:)' ry(1)]*hin];
    ringh  = patch(headx,heady,ones(size(headx)),'k','edgecolor','none'); hold on

%%  Plot ears and nose

    base  = rmax-.0046;
    basex = 0.18*rmax;          % nose width
    tip   = 1.15*rmax; 
    tiphw = .04*rmax;           % nose tip half width
    tipr  = .01*rmax;           % nose tip rounding
    q     = .04;                % ear lengthening
    EarX  = [.497-.005  .510  .518  .5299 .5419  .54    .547   .532   .510   .489-.005]; % rmax = 0.5
    EarY  = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199];
    sf    = headrad/plotrad;                                          % squeeze the model ears and nose 
                                                                      % by this factor
    plot3([basex;tiphw;0;-tiphw;-basex]*sf,[base;tip-tipr;tip;tip-tipr;base]*sf,...
         2*ones(size([basex;tiphw;0;-tiphw;-basex])),...
         'Color',HEADCOLOR,'LineWidth',HLINEWIDTH);                                       % plot nose
    plot3(EarX*sf,EarY*sf,2*ones(size(EarX)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)    % plot left ear
    plot3(-EarX*sf,EarY*sf,2*ones(size(EarY)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)   % plot right ear


%%  Show electrode information

     plotax = gca;
     axis square                                      
     axis off

     pos = get(gca,'position');
     xlm = get(gca,'xlim');
     ylm = get(gca,'ylim');
     axis square % make textax square

     pos = get(gca,'position');
     set(plotax,'position',pos);

     xlm = get(gca,'xlim');
     set(plotax,'xlim',xlm);

     ylm = get(gca,'ylim');
     set(plotax,'ylim',ylm);                               % copy position and axis limits again


%%  Mark electrode locations only

    ELECTRODE_HEIGHT = 2.1;  % z value for plotting electrode information (above the surf)
    hp2 = plot3(y*.95,x*.95,ones(size(x))*ELECTRODE_HEIGHT,...
            EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);


%%%%%%%%%%%%% Set EEGLAB background color to match head border %%%%%%%%%%%%%%%%%%%%%%%%

    hold off
    axis off
    return
