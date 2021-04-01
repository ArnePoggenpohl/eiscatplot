# eiscatplot
This tool is created to visualize and analyse data from the EISCAT VHF radar.

# Citing
If you use 'eiscatplot', please cite it as (e.g. bibtex):
```bibtex
@manual{eiscatplot,
      author = {Poggenpohl, Arne},
      title = {eiscatplot},
      subtitle = {Plotting tool for EISCAT VHF radar},
      url = {https://github.com/ArnePoggenpohl/eiscatplot},
}
```

# Usage

You basically just need to run the main.mlx script which can be found in [code_new/main.mlx](code_new/main.mlx).
But there are some steps, which you need to note.

## Matlab
First you want to install Matlab. Therefore, you will need a Matlab license, which you have to 
buy or is provided by your organisation.

## Data
Then you will need data from the EISCAT radar. Go to 

* `https://portal.eiscat.se/madrigal/` and select
* `Simple Local Data Access` from the list on the left site.

An example of the data, which was analysed with this code:

* `All Instument Types`: `Incoherent Scatter Radars`
* `Select an instrument`: `EISCAT Tromso VHF IS radar [1990-2020]`
* `Select a year`: `2018`
* `Select a month`: `August`
* Choosen day: `15`

On the right side of the page some more information should appear now.

* `Choose an experiment`: `manda_24: 2018-08-15 00:00:00 - 2018-08-16 00:00:00`
* `Choose a file`: `NCAR_2018-08-15_manda_24_vhf.bin: GUISDAP Fitted Parameters - Final`

Click on `Download data`, choose the `HDF5 format` and click the `Download File` button.
It is important, that the 24 is in the name. That refers to the delay in seconds between the
measurement.
Another format, which is implemented in the code, are the storage in many Matlab-files.
One for each time step. This is available if you click on `Show Plots` and then choose 
`2018-08-15_manda_24_vhf.tar.gz (gzipped file)`.

Assuming after cloning this repository you are in the escatplot folder, store the data in `../data`.
That is the default for this tool. If you want to store it somewhere else, you will have to adjust
the config files.

If you use data, where the config file for this area already exists, you are ready to run 
the 'main.mlx' file. If you want to analyse new data, keep reading.

## How to handle new data
