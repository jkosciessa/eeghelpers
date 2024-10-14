function [data index] = THG_automatic_artifact_correction_trials(data)

%%  preset config

    cfg.criterion = 3;
    cfg.recursive = 'no';

%%  create index for trials to keep
    index = 1:length(data.trial);

%%  repeat exclusion of trials
    check = 0;
    while check == 0;

%%  get artifact contaminated epoch by kurtosis, low & high frequency artifacts

        [indexA parmA zvalA] = cm_MWB_channel_x_epoch_artifacts(cfg,data);

%%  get artifact contaminated epochs by FASTER

        [indexB parmB zvalB] = THG_FASTER_2_epoch_artifacts(cfg,data);

%%  delete trials

        % collect bad trials
        badtrl = unique([indexA.t; indexB]);

        if prod(size(badtrl)) ~= 0
            
            % define trials to keep
            trials          = 1:length(data.trial);
            trials(badtrl)  = [];

            % config for deleting trials
            tmpcfg.trials   = trials;
            tmpcfg.channel = 'all';

            % update index
            index(badtrl)   = [];

            % remove trials
            data = ft_preprocessing(tmpcfg,data);
            
            % clear variables
            clear *A *B badtrl trials tmpcfg labels

        else

            check = 1;

            % clear variables
            clear *A *B
            
        end

    end