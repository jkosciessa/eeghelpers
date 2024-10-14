function [iclabels] = cm_label_ica_gui(cfg,data)
%
% INPUT:    data         = ica data structure
%           cfg.topoall  = 'yes': plot overview (topographies of all channels)
%                          'no' (default)
%           cfg.chanlocs = channel location / information structure (EEGLAB format)
% OUTPUT:   iclabels     = indices of components (ok, blink, move, artefact, unclear)

% required functions:
% - cm_eeg_topoplot
% -

% 26.01.2014 THG
% - currently relies on an adapted topoplot function from EEGLAB
%
% 26.02.2014 THG
% - changed labeling in overview

% 16.01.2018 JQK
% - added EMG as labeling choice

%% set default values
if ~isfield(cfg,'topoall')
    cfg.topoall = 'no';
end

%% construct info structure for plotting (see subfun below)
info = construct_info_100521(data);

%% set further default info values
% default text OR insert labels
if ~isfield(data,'iclabels')
    
    for i = 1:info.nic
        info.txt{i,1} = 'not labeled yet';
        info.cmp{i,1} = '   ';
    end; clear i
    
% collect previous labels if existent
elseif isfield(data,'iclabels')
    % not labeled
    for i = 1:info.nic
        info.txt{i,1} = 'not labeled yet';
        info.cmp{i,1} = [];
    end; clear i
    % labeled as OK
    for k = 1:length(data.iclabels.oks)
        info.txt{data.iclabels.oks(k),1} = 'OK';
        info.cmp{data.iclabels.oks(k),1} = 'OK!';
    end; clear k
    % labeled as BLINK
    for k = 1:length(data.iclabels.bli)
        info.txt{data.iclabels.bli(k),1} = 'BLINK';
        info.cmp{data.iclabels.bli(k),1} = 'BLI';
    end; clear k
    % labeled as MOVE (eye movement)
    for k = 1:length(data.iclabels.mov)
        info.txt{data.iclabels.mov(k),1} = 'MOVE';
        info.cmp{data.iclabels.mov(k),1} = 'MOV';
    end; clear k
    % labeled as TONGUE (tongue movement)
    for k = 1:length(data.iclabels.tng)
        info.txt{data.iclabels.tng(k),1} = 'TONGUE';
        info.cmp{data.iclabels.tng(k),1} = 'TNG';
    end; clear k
    % labeled as HEART (heart beat artefact)
    for k = 1:length(data.iclabels.hrt)
        info.txt{data.iclabels.hrt(k),1} = 'HEART';
        info.cmp{data.iclabels.hrt(k),1} = 'HRT';
    end; clear k
    % labeled as ARTEFACT (muscle artefact)
    for k = 1:length(data.iclabels.art)
        info.txt{data.iclabels.art(k),1} = 'ARTEFACT';
        info.cmp{data.iclabels.art(k),1} = 'ART';
    end; clear k
    % labeled as EMG (emg artefact)
    for k = 1:length(data.iclabels.emg)
        info.txt{data.iclabels.emg(k),1} = 'EMG';
        info.cmp{data.iclabels.emg(k),1} = 'EMG';
    end; clear k
    % labeled as ELECTRODE (artefact limited to one electrode)
    for k = 1:length(data.iclabels.elc)
        info.txt{data.iclabels.elc(k),1} = 'ELECTRODE';
        info.cmp{data.iclabels.elc(k),1} = 'ELC';
    end; clear k
    % labeled as REFERENCE (reference artefact)
    for k = 1:length(data.iclabels.ref)
        info.txt{data.iclabels.ref(k),1} = 'REFERENCE';
        info.cmp{data.iclabels.ref(k),1} = 'REF';
    end; clear k
    % labeled as UNCLEAR
    for k = 1:length(data.iclabels.unc)
        info.txt{data.iclabels.unc(k),1} = '?';
        info.cmp{data.iclabels.unc(k),1} = '???';
    end; clear k
    % not yet labeled
    if isfield(data.iclabels,'nol')
        for k = 1:length(data.iclabels.nol)
            info.txt{data.iclabels.nol(k),1} = 'not labeled yet';
            info.cmp{data.iclabels.nol(k),1} = '   ';
        end; clear k
    end
end
        
% start index = 1
info.i     = 1;
% index for single trials
info.index = 1;
% default
info.quit  = 0;

clear data

%%  plot topos
if strcmp(cfg.topoall,'yes') && isfield(cfg,'chanlocs')
    % IC weights
    topo = double(info.topo.dat);
    % define figure size
    tmp_sz = get(0,'screensize');
    % initialize figure
    top = figure('color','w','position',[tmp_sz(3)*0.05 tmp_sz(4)*0.025 tmp_sz(3:4)*0.9]); 
    % plotting parameters
    b = .05; % border
    n_ver = 7;
    n_hor = 10;
    % plot
    for m = 1:n_ver
        for n = 1:n_hor
            % counter
            k = (m-1)*n_hor + n;
            % plot
            if k <= size(topo,2)
                display(['plot topography #' num2str(k)])
                s_ver = (1-2*b)/n_ver;
                s_hor = (1-2*b)/n_hor;
                pos_v = 1 - b - s_ver*m;
                pos_h = b + s_hor*(n-1);
                axes('position',[pos_h pos_v s_hor s_ver])
                set(gca,'xtick',[],'ytick',[])
                nchans = size(cfg.chanlocs,1);
                maplim(1) = min(topo([1:nchans],k));
                maplim(2) = max(topo([1:nchans],k));
                maplim = [max(abs(maplim))*-1 max(abs(maplim))];
                % plot topography
                cm_eeg_topoplot(topo([1:nchans],k),cfg.chanlocs(1:nchans),maplim);
                % show IC label
                text(0,1.05,[num2str(k) ': ' info.cmp{k,1}],'fontsize',8,'units','normalized')
                % clear variables
                clear k s_* pos_* maplim
            end
        end
    end; clear m n
    % clear variables
    clear tmp_sz
end

%%  initialize GUI
fig = figure('Units','Normalized','Position',[.05 .1 .8 .8]);
guidata(fig,info);

% general
uicontrol(fig,'units','normalized','position',[.01 .01 .06 .07],'BackgroundColor','k', ... 
                                                                'ForegroundColor','w','String','QUIT','Callback',@stop);
% IC label on top
uicontrol(fig,'units','normalized','position',[.40 .96 .20 .03],'BackgroundColor','w','Style','Text',...
              'String',['IC' num2str(info.i) ': ' info.txt{info.i}],'fontsize',12,'fontweight','bold')
% forward/backward for IC
uicontrol(fig,'units','normalized','position',[.86 .01 .03 .03],'BackgroundColor','w','String','<','Callback',@prev);
uicontrol(fig,'units','normalized','position',[.94 .01 .03 .03],'BackgroundColor','w','String','>','Callback',@next);
% textfield for IC
uicontrol(fig,'units','normalized','position',[.895 .01 .04 .03],'Style','Edit','String',num2str(info.i),'Callback',@edittext2);
         
% OK
uicontrol(fig,'units','normalized','position',[.07 .01 .075 .04],'BackgroundColor','w', ...
                                                                'ForegroundColor','k','String','OK >','Callback',@OK);
% blink
uicontrol(fig,'units','normalized','position',[.14 .01 .075 .04],'BackgroundColor','w', ...
                                                                'ForegroundColor','r','String','blink >','Callback',@blink);
% move
uicontrol(fig,'units','normalized','position',[.21 .01 .075 .04],'BackgroundColor','w', ...
                                                                'ForegroundColor','g','String','move >','Callback',@move);
% tongue
uicontrol(fig,'units','normalized','position',[.28 .01 .075 .04],'BackgroundColor','w', ...
                                                                'ForegroundColor','c','String','tongue >','Callback',@tongue);
% heart
uicontrol(fig,'units','normalized','position',[.35 .01 .075 .04],'BackgroundColor','w', ...
                                                                'ForegroundColor','b','String','heart >','Callback',@heart);
% emg
uicontrol(fig,'units','normalized','position',[.42 .01 .075 .04],'BackgroundColor','w', ...
                                                                'ForegroundColor','b','String','emg >','Callback',@emg);                                                        
% artefact
uicontrol(fig,'units','normalized','position',[.49 .01 .075 .04],'BackgroundColor','r', ... 
                                                                'ForegroundColor','k','String','artefact >','Callback',@artefact);
% electrode
uicontrol(fig,'units','normalized','position',[.56 .01 .075 .04],'BackgroundColor','r', ...
                                                                'ForegroundColor','k','String','electrode >','Callback',@electrode);
% reference
uicontrol(fig,'units','normalized','position',[.63 .01 .075 .04],'BackgroundColor','w', ...
                                                                'ForegroundColor','m','String','reference >','Callback',@reference);
% unclear
uicontrol(fig,'units','normalized','position',[.70 .01 .075 .04],'BackgroundColor','w', ...
                                                                'ForegroundColor','k','String','? >','Callback',@unclear);

                                                            
% forward / backward for single trial
uicontrol(fig,'units','normalized','position',[.200 .08 .02 .02],'String','<','Callback',@prev_sngl);
uicontrol(fig,'units','normalized','position',[.280 .08 .02 .02],'String','>','Callback',@next_sngl);
% textfield for sinlge trials
uicontrol(fig,'units','normalized','position',[.222 .08 .056 .02],'Style','Edit','String',num2str(info.index),'Callback',@edittext1);


%% CORE

interactive = 1;
while interactive && ishandle(fig)
    
    refresh(fig);
    info = guidata(fig);
    % title
    uicontrol(fig,'units','normalized','position',[.40 .96 .20 .03],'Style','Text',...
                  'String',['IC' num2str(info.i) ': ' info.txt{info.i}],'fontsize',12,'fontweight','bold')
    % textfield for IC
    uicontrol(fig,'units','normalized','position',[.895 .01 .04 .03],'Style','Edit','String',num2str(info.i),'Callback',@edittext2);
              
    % plot topography
    axes('units','normalized','position',[.10 .66 .3 .3],'fontsize',8)
    set(gca,'xtick',[],'ytick',[])
    maplim(1) = min(info.topo.dat(:,info.i));
    maplim(2) = max(info.topo.dat(:,info.i));
    maplim = [max(abs(maplim))*-1 max(abs(maplim))];
    hold on; cm_eeg_topoplot(info.topo.dat(:,info.i),cfg.chanlocs(1:nchans),maplim);
    
    % plot the powerspectrum
    li1 = axes('units','normalized','position',[.55 .78 .4 .13],'fontsize',8);
    hold on; plot(sqrt(info.fft.freq),squeeze(info.fft.dat(info.i,:)),'k');
    axis([0 10 -info.fft.maxpow*0.05 info.fft.maxpow*1.05]);
    set(li1,'XTick',[sqrt(1) sqrt(2) sqrt(4) sqrt(8) sqrt(10) sqrt(16) sqrt(20) sqrt(32) sqrt(50) sqrt(64) sqrt(100)])
    set(li1,'XTickLabel',{'1','2','4','8','10','16','20','32','50','64','100'})
    
    % plot the scaled component power spectrum
    li2 = axes('Position',get(li1,'Position'),'YAxisLocation','right','Color','none',...
               'XColor','k','YColor','r','fontsize',8);
    hold on; plot(sqrt(info.fft.freq),squeeze(info.fft.scaled(info.i,:)),'r');
    axis([0 10 info.fft.minpow_scaled*1.05 info.fft.maxpow_scaled*1.05]);
    uicontrol(fig,'units','normalized','position',[.65 .915 .20 .025],'Style','Text',...
                  'String','scaled component power spectrum','fontsize',8,'foregroundcolor','r')
    uicontrol(fig,'units','normalized','position',[.65 .725 .20 .025],'Style','Text',...
                  'String','component power spectrum','fontsize',8)
    set(li2,'XTick',[sqrt(1) sqrt(2) sqrt(4) sqrt(8) sqrt(10) sqrt(16) sqrt(20) sqrt(32) sqrt(50) sqrt(64) sqrt(100)])
    set(li2,'XTickLabel',{'1','2','4','8','10','16','20','32','50','64','100'})
              
    % plot the erp-image
    axes('units','normalized','position',[.55 .36 .4 .32],'XLim',[min(info.data.time) max(info.data.time)],'YLim',[0.5 info.ntrls+0.5],...
         'XTickLabel',[],'fontsize',8)
    uicontrol(fig,'units','normalized','position',[.65 .685 .20 .025],'Style','Text',...
              'String','ERP image & ERP','fontsize',8)
    erpim = single((squeeze(info.data.trls(info.i,:,:)) - info.data.meanerp(info.i))./info.data.stderp(info.i));
    hold on; imagesc(info.data.time,[1:info.ntrls],erpim,[-50 50]); clear erpim
    
    % plot ERP1
    lo1 = axes('units','normalized','position',[.55 .23 .4 .12],'fontsize',8,...
    'XTickLabel',[],'YTick',[info.data.erpmini1(info.i) info.data.erpmaxi1(info.i)],...
    'YTickLabel',{num2str(info.data.erpmini1_(info.i)) num2str(info.data.erpmaxi1_(info.i))});
    hold on; plot(info.data.time,info.data.erpmax(info.i,:),'r');
    hold on; plot(info.data.time,info.data.erpmin(info.i,:),'b');
    min_ = info.data.erpmini1(info.i) - abs(info.data.erpmini1(info.i))*0.1;
    max_ = info.data.erpmaxi1(info.i) + abs(info.data.erpmaxi1(info.i))*0.1;
    axis([min(info.data.time) max(info.data.time) min_ max_])
    clear min_ max_
    uicontrol(fig,'units','normalized','position',[.955 .290 .03 .025],'Style','Text',...
          'String','max','fontsize',8,'foregroundcolor','r')
    uicontrol(fig,'units','normalized','position',[.955 .265 .03 .025],'Style','Text',...
          'String','min','fontsize',8,'foregroundcolor','b')
    
    % plot ERP2
    lo2 = axes('units','normalized','position',[.55 .10 .4 .12],'fontsize',8,...
    'YTick',[info.data.erpmini2(info.i) info.data.erpmaxi2(info.i)],...
    'YTickLabel',{num2str(info.data.erpmini2_(info.i)) num2str(info.data.erpmaxi2_(info.i))});
    hold on; plot(info.data.time,info.data.erpPzm,'g');
    hold on; plot(info.data.time,info.data.erpPz(info.i,:),'k');
    min_ = info.data.erpmini2(info.i) - abs(info.data.erpmini2(info.i))*0.1;
    max_ = info.data.erpmaxi2(info.i) + abs(info.data.erpmaxi2(info.i))*0.1;
    axis([min(info.data.time) max(info.data.time) min_ max_])
    clear min_ max_
    uicontrol(fig,'units','normalized','position',[.955 .160 .03 .025],'Style','Text',...
          'String','@Pz','fontsize',8,'foregroundcolor','g')
    uicontrol(fig,'units','normalized','position',[.955 .135 .03 .025],'Style','Text',...
          'String','IC','fontsize',8,'foregroundcolor','k')

    % plot four randomly selected trials
    min_ = min(min(info.data.rand(info.i,:,:))); min_ = min_ - abs(min_)*0.1;
    max_ = max(max(info.data.rand(info.i,:,:))); max_ = max_ + abs(max_)*0.1;
    re1 = axes('units','normalized','position',[.05 .51 .4 .07],'XTickLabel',[],'fontsize',8);
    hold on; plot(info.data.time,squeeze(info.data.rand(info.i,1,:)),'k'); 
    axis([min(info.data.time) max(info.data.time) min_ max_])
    uicontrol(fig,'units','normalized','position',[.15 .585 .20 .025],'Style','Text',...
                  'String','randomly selected trials','fontsize',8)
    re2 = axes('units','normalized','position',[.05 .43 .4 .07],'XTickLabel',[],'fontsize',8);
    hold on; plot(info.data.time,squeeze(info.data.rand(info.i,2,:)),'k');
    axis([min(info.data.time) max(info.data.time) min_ max_])
    re3 = axes('units','normalized','position',[.05 .35 .4 .07],'XTickLabel',[],'fontsize',8);
    hold on; plot(info.data.time,squeeze(info.data.rand(info.i,3,:)),'k');
    axis([min(info.data.time) max(info.data.time) min_ max_])
    re4 = axes('units','normalized','position',[.05 .27 .4 .07],'fontsize',8);
    hold on; plot(info.data.time,squeeze(info.data.rand(info.i,4,:)),'k');
    axis([min(info.data.time) max(info.data.time) min_ max_])
    clear min_ max_

    % plot single trial
    mini = min(squeeze(info.data.trls(info.i,info.index,:)));
    maxi = max(squeeze(info.data.trls(info.i,info.index,:)));
    mini_ = round(mini*100)/100;
    maxi_ = round(maxi*100)/100;
    re = axes('units','normalized','position',[.05 .12 .4 .07],'fontsize',8,...
              'YTick',[mini maxi],...
              'YTickLabel',{num2str(mini_) num2str(maxi_)});
    uicontrol(fig,'units','normalized','position',[.13 .195 .24 .025],'Style','Text',...
                  'String',['single trial #' num2str(info.index)],'fontsize',8)
    hold on; plot(info.data.time,squeeze(info.data.trls(info.i,info.index,:)),'k');
    axis([min(info.data.time) max(info.data.time) mini*1.02 maxi*1.02])
    clear maxi maxi_ mini mini_
    uicontrol(fig,'units','normalized','position',[.222 .08 .056 .02],'Style','Edit',...
              'String',num2str(info.index),'Callback',@edittext1);
    
    if info.quit == 0
        
        uiwait;
        set(lo1,'YTickLabel',[])
        set(lo2,'YTickLabel',[])
        set(re, 'YTickLabel',[])
        set(li1,'YTickLabel',[])
        set(li2,'YTickLabel',[])
        set(re1,'YTickLabel',[])
        set(re2,'YTickLabel',[])
        set(re3,'YTickLabel',[])
        set(re4,'YTickLabel',[])

    elseif info.quit == 1 

        check = find(strcmp(info.txt,'not labeled yet'));
        if ~isempty(check)
            button = questdlg('Not all components were labeled!  Continue labeling?', ...
                              '','Continue','Quit','Continue'); 
            
            if strcmp(button,'Continue')
                
                info.quit = 0;
                interactive = 1;
                
                guidata(fig,info);
                
                clear button check
                continue
                
            elseif strcmp(button,'Quit')
                
                iclabels.nol = check;
                warning([num2str(length(check)) ' components were not labeled'])
                iclabels.oks = find(strcmp(info.txt,'OK'));
                iclabels.bli = find(strcmp(info.txt,'BLINK'));
                iclabels.mov = find(strcmp(info.txt,'MOVE'));
                iclabels.tng = find(strcmp(info.txt,'TONGUE'));
                iclabels.hrt = find(strcmp(info.txt,'HEART'));
                iclabels.art = find(strcmp(info.txt,'ARTEFACT'));
                iclabels.elc = find(strcmp(info.txt,'ELECTRODE'));
                iclabels.ref = find(strcmp(info.txt,'REFERENCE'));
                iclabels.emg = find(strcmp(info.txt,'EMG'));
                iclabels.unc = find(strcmp(info.txt,'?'));
                iclabels.version = '20140226';
                delete(fig);
                close all
                break
                
            end
            
        else               

            iclabels.oks = find(strcmp(info.txt,'OK'));
            iclabels.bli = find(strcmp(info.txt,'BLINK'));
            iclabels.mov = find(strcmp(info.txt,'MOVE'));
            iclabels.tng = find(strcmp(info.txt,'TONGUE'));
            iclabels.hrt = find(strcmp(info.txt,'HEART'));
            iclabels.art = find(strcmp(info.txt,'ARTEFACT'));
            iclabels.elc = find(strcmp(info.txt,'ELECTRODE'));
            iclabels.ref = find(strcmp(info.txt,'REFERENCE'));
            iclabels.emg = find(strcmp(info.txt,'EMG'));
            iclabels.unc = find(strcmp(info.txt,'?'));
            delete(fig);
            close all
            break
            
        end
        
    end

end

          
%% basic subfunctions

function varargout = next(fig, eventdata, handles, varargin)
    info = guidata(fig);
    if info.i < info.nic
      info.i = info.i + 1;
    end
    guidata(fig,info);
    uiresume;

function varargout = prev(fig, eventdata, handles, varargin)
    info = guidata(fig);
    if info.i > 1
      info.i = info.i - 1;
    end
    guidata(fig,info);
    uiresume;

function varargout = next_sngl(fig, eventdata, handles, varargin)
    info = guidata(fig);
    if info.index < info.ntrls
      info.index = info.index + 1;
    end
    guidata(fig,info);
    uiresume;

function varargout = prev_sngl(fig, eventdata, handles, varargin)
    info = guidata(fig);
    if info.index > 1
      info.index = info.index - 1;
    end
    guidata(fig,info);
    uiresume;

function varargout = OK(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = 'OK';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = blink(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = 'BLINK';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = move(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = 'MOVE';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = tongue(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = 'TONGUE';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = heart(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = 'HEART';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = emg(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = 'EMG';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = artefact(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = 'ARTEFACT';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = electrode(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = 'ELECTRODE';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = reference(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = 'REFERENCE';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = unclear(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.txt{info.i,1} = '?';
    guidata(fig,info);
    next(fig);
    uiresume;

function varargout = stop(fig, eventdata, handles, varargin)
    info = guidata(fig);
    info.quit = 1;
    guidata(fig,info);
    uiresume;

function edittext1(fig,eventdata)
    info = guidata(fig);
    user_string = get(fig,'String');
    user_number = str2double(user_string); clear user_string
    if user_number > info.ntrls || isempty(user_number)
        errordlg(['trial # must be between 1 and ' num2str(info.ntrls)])
    else
        info.index = user_number;
        guidata(fig,info);
        uiresume;
    end

function edittext2(fig,eventdata)
    info = guidata(fig);
    user_string = get(fig,'String');
    user_number = str2double(user_string);
    clear user_string
    if user_number > info.nic || isempty(user_number)
        errordlg(['component # must be between 1 and ' num2str(info.nic)])
    else
        info.i = user_number;
        guidata(fig,info);
        uiresume;
    end


%% subfunction get configs = preprocessing and plot settings
function cfg = get_config(data)

    cfg.fft = [];
    cfg.fft.method     = 'mtmfft';
    cfg.fft.output     = 'pow';
    cfg.fft.taper      = 'hanning';
    cfg.fft.foilim     = [0.1 100];
    cfg.fft.keeptrials = 'no';

    cfg.fd.jackknife     = 'yes';
    cfg.fd.biascorrect   = 'yes';

    cfg.p = [];
    tmp = [];
    tmp.elec = data.elec;
    cfg.p.layout = ft_prepare_layout(tmp);


%% subfunction construct info
function info = construct_info_100521(data)

    tic
    %% basic info values
    % number of components
    info.nic = size(data.topo,2);
    % number of trials
    info.ntrls = length(data.trial);
    % time vector
    info.data.time = data.time{1};

    %% get backprojections
    % topographies
    info.topo.dat  = double(data.topo);
    info.topo.mean = single(mean(info.topo.dat));
    info.topo.max  = single(max(info.topo.dat));
    info.topo.min  = single(min(info.topo.dat));
    % topography Pz
    ind_Pz         = find(strcmp(data.topolabel,'Pz'));
    info.topo.Pz   = single(info.topo.dat(ind_Pz,:));
    clear ind_Pz

    % mean backprojections
    info.data.trls = single(zeros(info.nic,info.ntrls,length(info.data.time)));
    for k = 1:info.ntrls
        info.data.trls(:,k,:) = (info.topo.mean'*ones(1,length(info.data.time))).*data.trial{1,k};
    end; clear k
    % max backprojections
    tmp = single(zeros(info.nic,info.ntrls,length(info.data.time)));
    for k = 1:info.ntrls
        tmp(:,k,:)           = (info.topo.max'*ones(1,length(info.data.time))).*data.trial{1,k};
    end; clear k
    info.data.erpmax = squeeze(mean(tmp,2));
    % min backprojections
    tmp = single(zeros(info.nic,info.ntrls,length(info.data.time)));
    for k = 1:info.ntrls
        tmp(:,k,:)           = (info.topo.min'*ones(1,length(info.data.time))).*data.trial{1,k};
    end; clear k
    info.data.erpmin = squeeze(mean(tmp,2));
    % Pz backprojections
    tmp = single(zeros(info.nic,info.ntrls,length(info.data.time)));
    for k = 1:info.ntrls
        tmp(:,k,:)           = (info.topo.Pz'*ones(1,length(info.data.time))).*data.trial{1,k};
    end; clear k
    info.data.erpPz = squeeze(mean(tmp,2));
    info.data.erpPzm = sum(info.data.erpPz);

    %% data preprocessing - fft (on raw ICs!)
    data.label = data.topolabel;
    if isfield(data,'iclabels')
        data = rmfield(data,{'topolabel','topo','cfg','iclabels'});
    else
        data = rmfield(data,{'topolabel','topo','cfg'});
    end

    % preprocessing values
    cfg = get_config(data);

    % fft of ICs
    fftdat = ft_freqanalysis(cfg.fft,data);                                   
    info.fft.dat = fftdat.powspctrm;
    for k = 1:size(info.fft.dat,2)
        tmp = info.fft.dat(:,k);
        info.fft.scaled(:,k) = (tmp - mean(tmp)) ./ std(tmp);
    end; 
    clear k tmp

    % scaling values
    info.fft.maxpow = max(max(info.fft.dat));
    info.fft.minpow = min(min(info.fft.dat));
    info.fft.maxpow_scaled = max(max(info.fft.scaled));
    info.fft.minpow_scaled = min(min(info.fft.scaled));

    % freqencies
    info.fft.freq = fftdat.freq;
    clear fftdat

    %% data preprocessing - data
    % random data indices
    tempidc = randperm(info.ntrls);
    tempidc = tempidc(1:4);

    % erpimage & erp 
    for j = 1:info.nic

        info.data.meanerp(j) = mean(mean(squeeze(info.data.trls(j,:,:))));
        info.data.stderp(j)  = std(std(squeeze(info.data.trls(j,:,:))));

        % ERP1
        info.data.erpmini1(j) = min(min([info.data.erpmin(j,:) info.data.erpmax(j,:)]));
        info.data.erpmaxi1(j) = max(max([info.data.erpmin(j,:) info.data.erpmax(j,:)]));
        info.data.erpmini1_(j) = round(info.data.erpmini1(j)*100)/100;
        info.data.erpmaxi1_(j) = round(info.data.erpmaxi1(j)*100)/100;

        % ERP2
        info.data.erpmini2(j) = min(info.data.erpPzm);
        info.data.erpmaxi2(j) = max(info.data.erpPzm);
        info.data.erpmini2_(j) = round(info.data.erpmini2(j)*100)/100;
        info.data.erpmaxi2_(j) = round(info.data.erpmaxi2(j)*100)/100;

        % random data        
        info.data.rand(j,:,:) = single(squeeze(info.data.trls(j,tempidc,:))); 

    end; clear j tempidc

    % get preprocessing & plot configs
    info.cfg.topoplot  = cfg.p;

    clear cfg data
    toc