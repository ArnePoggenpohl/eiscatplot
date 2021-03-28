classdef parameter_2020_08_05
    %PARAMETER_2020_08_05 Summary of this class goes here
    %   Additional parameters for the data of the night 2020 August 5th
    %   Path:       location (folder) of the data
    %   Heater:     data of the heating during that night [start; end]
    %   Heater_int: intervall, in which the heater is turned on and off [on-phase in s; off-phase in s]
    %   Time0:      Complete observation time of this day [start; end]
    %   Altitude0:  Area where PMSE can accur [min. altitude; max. altitude]
    %   TimeN:      Begin and end of an individual selected area [start; end]
    %   AltitudeN:  Minimal and maximal altitude of this selected area
    %   T_LineN:    Choose coloums of the temperature plot
    %
    % The parameters TimeN and AltitudeN are focusing on PMSE signal. If
    % more areas should be investigated, they can be added by
    % TimeN+1 and AltitudeN+1
    
    properties
        % General
        Path_hdf5 = ["..\data\NCAR_2020-08-05_manda_24_vhf.bin.hdf5",...
                     "..\data\NCAR_2020-08-06_manda_24_vhf.bin.hdf5"]
        Path = ["..\data\2020-08-05_manda_24@vhf\*.mat",...
                "..\data\2020-08-06_manda_24@vhf\*.mat"]
        Heater = [2020 08 05 20 46 48; 2020 08 06 00 00 00]
        Heater_int = [48, 168]
        % Complete signal
        Time0 = [2020 08 05 20 25 00; 2020 08 06 00 01 00]
        Altitude0 = [80; 110]
        % Area 1
        Time1 = [2020 08 05 21 25 00; 2020 08 05 22 50 00]
        Altitude1 = [82; 88]
        % Area 2
        Time2 = [2020 08 05 22 50 00; 2020 08 05 23 50 00]
        Altitude2 = [83; 87]
        % Area 3
        Time3 = [2020 08 05 22 45 00; 2020 08 06 00 01 00]
        Altitude3 = [90; 100]
    end
end

