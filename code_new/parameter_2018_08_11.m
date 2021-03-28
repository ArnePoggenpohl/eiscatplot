classdef parameter_2018_08_11
    %PARAMETER_2018_08_11 Summary of this class goes here
    %   Additional parameters for the data of the night 2020 August 5th
    %   Path:       location (folder) of the data
    %   Heater:     data of the heating during that night [start; end]
    %   Heater_int: intervall, in which the heater is turned on and off [on-phase in s; off-phase in s]
    %   Time0:      Complete observation time of this day [start; end]
    %   Altitude0:  Area where PMSE can accur [min. altitude; max. altitude]
    %   TimeN:      Begin and end of an individual selected area [start; end]
    %   AltitudeN:  Minimal and maximal altitude of this selected area
    %   T_LineN:    Choose coloums of the temperature plot, not dependent
    %               on the heating cycle. Just count the columns in the plot
    %
    % The parameters TimeN and AltitudeN are focusing on PMSE signal. If
    % more areas should be investigated, they can be added by
    % TimeN+1 and AltitudeN+1
    
    properties
        % General
        Path_hdf5 = ["..\data\NCAR_2018-08-11_manda_24_vhf.bin.hdf5",...
                     "..\data\NCAR_2018-08-12_manda_24_vhf.bin.hdf5"]
        Path = ["..\data\2018-08-11_manda_24@vhf\*.mat",...
                "..\data\2018-08-12_manda_24@vhf\*.mat"]
        Heater = [2018 08 11 20 32 00; 2018 08 12 02 00 00]
        Heater_int = [48, 168]
        % Complete signal
        Time0 = [2018 08 11 20 00 00; 2018 08 12 02 00 00]
        Altitude0 = [80; 110]
        % Area 1
        Time1 = [2018 08 11 21 36 24; 2018 08 11 22 42 36]
        Altitude1 = [83.4; 85.6]
        T_line1 = [10; 11; 12; 14; 15; 16; 17]
        % Area 2
        Time2 = [2018 08 11 23 06 24; 2018 08 12 01 17 24]
        Altitude2 = [86.3 90]
        % Area 3
        Time3 = [2018 08 12 00 00 24; 2018 08 12 01 28 12]
        Altitude3 = [83.4; 86.4]
        T_line3 = [4; 5; 6; 7; 8; 9]
    end
end

