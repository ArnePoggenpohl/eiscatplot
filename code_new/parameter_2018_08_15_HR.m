classdef parameter_2018_08_15_HR
    %PARAMETER_2018_08_15_HR Summary of this class goes here
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
<<<<<<< HEAD
        Path = "../../data/2018-08-15_manda_4.8@vhf/*.mat"
=======
        Path = "../data/2018-08-15_manda_4.8@vhf/*.mat"
>>>>>>> 83c167024b58da016175cec66ccf500c2668368b
        Heater = [2018 08 15 20 06 00; 2018 08 16 01 56 00]
        Heater_int = [48, 168]
        % Complete signal
        Time0 = [2018 08 15 20 00 00; 2018 08 16 02 00 00]
        Altitude0 = [80; 110]
        % Area 2
        Time2 = [2018 08 15 20 48 48; 2018 08 15 21 47 48]
        Altitude2 = [86.3; 88.5]
        T_line2 = [11; 15; 16]
    end
end