
This collection of functions is intended to assist EEG preprocessing.
They have been developed at the MPI for Human Development in the ConMem project.

**Function overview**

- ```cm_label_ica_gui```

Open a GUI with prelabeled channels. This uses the eeglab GUI and therefore depends on an eeglab-type data specification.

To load default coordinates in a 10-20 system, you can use the following code. The ```.txt``` file needs to be manually created from ```eeglab/sample_locs/Standard-10-20-Cap81.ced```.

```
eloc = readtable(fullfile(pn.channel_locations, 'Standard-10-20-Cap81_ced.txt'));
chanlocs_ced = table2struct(eloc);
% potentially rename channels to match the template
fieldtrip_labels = data.label;
% restrict eloc to recorded channels
[~, loc] = ismember(fieldtrip_labels, {chanlocs_ced.labels});
loc(loc==0) = [];
data.chanlocs = struct();
data.chanlocs = chanlocs_ced(loc,1);
cfg.chanlocs = data.chanlocs;
```

- ```cm_eeg_topoplot```

Plot a single topography based on the provided channel information.

- ```cm_eeg_finputcheck``` *deprecated*

Copy of EEGlab's ```finputcheck```.  
This is now replaced: ```addpath(fullfile(pn.tools ,'eeglab')); eeglab;```

- ```cm_eeg_readlocs``` *deprecated*

Copy of EEGlab's ```readlocs```. 
This is now replaced: ```addpath(fullfile(pn.tools ,'eeglab')); eeglab;``` 
See eeglab's documentation on reading in coordinates [here](https://eeglab.org/tutorials/04_Import/Channel_Locations.html).