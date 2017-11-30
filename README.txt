How to classify a Layer 5 prefrontal pyramidal neuron as Type 1, Type 2, or
Type 3: 


1) Export from Igor using Igor_Export.pxp

2) Run Import_and_Classify(cell_name, options)
    - cell_name: string with the cell name, followed by an asterix
    - options (as struct)
        - 'filepath': relative filepath to location of ibt files (default: 'cell_folder/ibt_files/')
        - 'select_sweep': select which sweeps you want to include for input
          resistance and sag/rebound calculations (default 0)

ex. Import_and_Classify('040915-2*', struct('filepath', '/cell_folder/ibt_files/', 'select_sweeps', 0))

                                        OR

3) If you have already imported a cell into Matlab, to classify the cell: 

AnalyzeCell(Cell)

Cell must be a structure with these fields (m = # of data points per
sweep, n = # of sweeps):
    - commands (current injection commands, mxn)
    - data (current clamp recordings, mxn)
    - sweep_time (time after break-in, in seconds, 1xn)
    - kHz = sampling frequency in kHz (1xn)
    - CaBuffer ('EGTA' or 'Fluo5')
    - cell_location ('PFC')

Requirements for classification: 
- Spiking has to be within the first 2.5 minutes, elicited by 300 ms current
  injection.
- Sag/rebound sweeps must be within the first 5 minutes, and be 120 ms pulse
  duration

Also, see publication concerning this classification technique:

