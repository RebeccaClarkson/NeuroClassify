# NeuroClassify

## Prefrontal cortex layer 5 pyramidal neuron classification

### If data needs to be exported from Igor:
1.  Export from Igor using `Igor_Export.pxp`

2.  Run `Import_and_Classify`(`cell_name*`, options) 
    * `cell_name`: string with the cell name, followed by an asterix
    * options (as struct)
        - 'filepath': relative filepath to location of ibt files 
                (default: 'cell_folder/ibt_files/')
        - 'select_sweep': select which sweeps you want to include for input
          resistance and sag/rebound calculations (default 0)

    ex. Import_and_Classify('040915-2*', struct('filepath', '/cell_folder/ibt_files/', 'select_sweeps', 0))

### If data is already in Matlab:
1. `AnalyzeCell`(Cell)
Cell must be a structure with these fields (`m` = # of data points per
sweep, `n` = # of sweeps):
    * `commands` (current injection commands, `m`x`n`)
    * `data` (current clamp recordings, `m`x`n`)
    * `sweep_time` (time after break-in, in seconds, 1x`n`)
    * `kHz` (sampling frequency in kHz, 1x`n`)
    * `CaBuffer` (*EGTA* or *Fluo5*)
    * `cell_location` (*PFC*)

### Requirements for classification:
* Spiking has to be within the first 2.5 minutes, elicited by 300 ms current
  injection.
* Sag/rebound sweeps must be within the first 5 minutes, and be 120 ms pulse
  duration

### References:
Clarkson et al. 2017, Journal of Neuroscience: 
[D3 Receptors Regulate Excitability in a Unique Class of Prefrontal Pyramidal
Cells](http://www.jneurosci.org/content/37/24/5846)
