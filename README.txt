How to classify a Layer 5 prefrontal pyramidal neuron as Type 1, Type 2, or Type 3: 

1) Export from Igor to Matlab - make sure the ibt files are within the Matlab path
2) Run Import_and_Classify(Cell), where "Cell" is a string with an asterix after it.
    - Options: 
        - 'select_sweep': select which sweeps you want to include for input resistance and sag/rebound calculations

ex. Import_and_Classify('040915-2*', 'select_sweeps', 0)

OR
3) If you have already imported a cell into Matlab, to classify the cell: AnalyzeCell(Cell)

In which, Cell is a structure with these fields: 
m = number of data points per sweep, n = number of sweeps)
	- commands (current injection commands, mxn)
    - data (current clamp recordings, mxn)
    - sweep_time (time after break-in, in seconds, 1xn)
    - kHz = sampling frequency in kHz (1xn)
    - CaBuffer ('EGTA' or 'Fluo5')
    - cell_location ('PFC')

Requirements for classification: 
- Spiking has to be within the first 2.5 minutes, elicited by 300 ms current injection.
- Sag/rebound sweeps must be within the first 5 minutes, and be 120 ms pulse duration

