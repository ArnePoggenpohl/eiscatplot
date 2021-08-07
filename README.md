# eiscatplot
This tool is created to visualize and analyse data from the EISCAT VHF radar.

## Citing
If you use 'eiscatplot', please cite it as (e.g. bibtex):
```bibtex
@manual{eiscatplot,
      author = {Poggenpohl, Arne},
      title = {eiscatplot},
      subtitle = {Plotting tool for EISCAT VHF radar},
      url = {https://github.com/ArnePoggenpohl/eiscatplot},
}
```

## Usage

You basically just need to run the main.mlx script which can be found in [code_new/main.mlx](code_new/main.mlx).
But there are some steps, which you need to do in advance.

### Matlab
First you want to install Matlab. Therefore, you will need a Matlab license, which you have to 
buy or is provided by your organisation.

### Data
Then you will need data from the EISCAT radar. Go to 

* `https://madrigal.eiscat.se/madrigal/index.html` and select
* `Access Data` from the top bar and then `Select single experiment`. Fill out the short form then you can access the data.

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

But that is only the data until midnight. To get the data from the whole night, choose `16`
in the calendar on the left side. Then choose:

* `Choose an experiment`: `manda_24: 2018-08-16 00:00:00 - 2018-08-17 00:00:00`
* `Choose a file`: `NCAR_2018-08-16_manda_24_vhf.bin: GUISDAP Fitted Parameters - Final`

Download the data in the same way as before.

Assuming after cloning this repository you are in the escatplot folder, store the data in `../data`.
That is the default for this tool. If you want to store it somewhere else, you will have to adjust
the config files.

### How to handle new data
When using a new dataset, you have to set up a new config file. The easiest way to do this, is to copy 
one of the existing ones and change the names and properties defined in this class. Further details are 
described in the config files themselves.

The data in the madrigal database has a time delay of 24 seconds between each measurment. In case you want
to use data of higher resolution (e.g. 4.8 seconds delay), you can add `_HR` to the config file and set
`HR = 'on'` in `main.mlx`. Some plots will be made slightly different then.

### Produce the plots
The script [code_new/main.mlx](code_new/main.mlx) has many settings as well. You can define, which day, 
which basically means, which config file will be read from the tool, and which areas one want to analyse. 
Furthermore, you can choose, which plots should be created. There are also different settings for the plots.
Once all the settings are done, you can run the code.

## Contributors

* Arne Poggenpohl [@ArnePoggenpohl](https://github.com/ArnePoggenpohl)
