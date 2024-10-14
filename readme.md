
This collection of functions is intended to assist EEG preprocessing.
They have been developed at the MPI for Human Development in the ConMem project.

**Function overview**

- ```cm_label_ica_gui```

Open a GUI with prelabeled channels. This uses the eeglab GUI and therefore depends on an eeglab-type data specification.

- ```cm_eeg_topoplot```

Plot a single topography based on the provided channel information.

- ```cm_eeg_finputcheck``` *deprecated*

Copy of EEGlab's ```finputcheck```. 
This is now replaced: ```addpath(fullfile(pn.tools ,'eeglab')); eeglab;```

- ```cm_eeg_readlocs``` *deprecated*

Copy of EEGlab's ```readlocs```.
This is now replaced: ```addpath(fullfile(pn.tools ,'eeglab')); eeglab;```
See eeglab's documentation on reading in coordinates [here](https://eeglab.org/tutorials/04_Import/Channel_Locations.html).