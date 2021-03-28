function [data] = parameter4analysis(inputDay, inputArea, HR)
%PARAMETER4ANALYSIS Summary of this function goes here
%   Detailed explanation goes here

class_name = get_class_name(inputDay, HR);  % get class name from input day
para_class = eval(class_name);              % initialise class with paramters
<<<<<<< HEAD
=======
files = get_mat_files(para_class.Path);     % get directory of all files
>>>>>>> 83c167024b58da016175cec66ccf500c2668368b

data.area_info = get_area_info(inputArea, para_class, HR);
data.area_info.day = inputDay;
data.area_info.area = inputArea;

<<<<<<< HEAD

if isprop(para_class, 'Path_hdf5')
    "true"
    [ne, h, T] = read_hdf5(para_class.Path_hdf5);
else
    "false"
    [ne, h, T] = read_matfiles(para_class.Path, data);

    %files = get_mat_files(para_class.Path);     % get directory of all files
    %[h,t,ne,Te,Ti,vi,dne,dTe,dTi,dvi,az,el,T] = ...
    %    guisdap_param2cell2regular(files,...
    %    [data.area_info.time(1,:); data.area_info.time(2,:)]);
end
ne
h
unique(h)
T
unique(T)
=======
[h,t,ne,Te,Ti,vi,dne,dTe,dTi,dvi,az,el,T] = ...
    guisdap_param2cell2regular(files,...
    [data.area_info.time(1,:); data.area_info.time(2,:)]);
>>>>>>> 83c167024b58da016175cec66ccf500c2668368b

[data.nel, data.altitude] = remove_altitude(ne, h, data.area_info);
data.T = T; data.t = guisdap_tosecs(T);
end

function [c_name] = get_class_name(inputDay, HR)
%GET_CLASS_NAME This function creates the name of the class 
%in which the paramters for the date should be safe. It also
%creates an error, if the class does not exist.

if HR == "off"
    c_name = "parameter_" + inputDay(1:4) + "_" + inputDay(6:7) +...
        "_" + inputDay(9:10);
else
    c_name = "parameter_" + inputDay(1:4) + "_" + inputDay(6:7) +...
        "_" + inputDay(9:10) + "_HR";
end
end

function [mat_files] = get_mat_files(path)
%GET_MAT_FILES Function to concatenated files from more 
%than one directory

<<<<<<< HEAD

end

function [ne, h, T] = read_hdf5(path)
%READ_HDF5 Function to read data saved in hdf5 format
%ne : equivalent electron density
%h : (ground) altitude
%T : time of measurement
ne = []; h = []; T = [];
for i_path=1:length(path)
    hdf5_data = h5read(path(i_path),'/Data/Table Layout');
    ne = [ne; hdf5_data.nel];
    h = [h; hdf5_data.gdalt];
    Time = [hdf5_data.year hdf5_data.month hdf5_data.day...
            hdf5_data.hour hdf5_data.min hdf5_data.sec];
    T = [T; Time];
end
end

function [ne, h, T] = read_matfiles(path, data)
%READ_HDF5 Function to read data saved in multiple .m files
%each time step has its own file
%ne : equivalent electron density
%h : (ground) altitude
%T : time of measurement

=======
>>>>>>> 83c167024b58da016175cec66ccf500c2668368b
mat_files = [];
for i=1:length(path)
    mat_files = cat(1,mat_files,dir(path(i)));
end
<<<<<<< HEAD
[h,t,ne,Te,Ti,vi,dne,dTe,dTi,dvi,az,el,T] = ...
    guisdap_param2cell2regular(mat_files,...
    [data.area_info.time(1,:); data.area_info.time(2,:)]);
=======
>>>>>>> 83c167024b58da016175cec66ccf500c2668368b
end

function [area_info] = get_area_info(inputArea, para_class, HR)
%GET_AREA_INFO filters the selected area information out
%of the parameter class

area_info.heater = para_class.Heater;
area_info.heater_int = para_class.Heater_int;
area_info.HR = HR;

if inputArea == "complete"
    area_info.time = para_class.Time0;
    area_info.altitude = para_class.Altitude0;
else
    inputArea = char(inputArea);
    area_num = inputArea(end);
    time_str = "para_class.Time" + area_num;
    altitude_str = "para_class.Altitude" + area_num;
    try
        T_line_str = "para_class.T_line" + area_num;
        area_info.T_line = eval(T_line_str);
    catch
    end
    area_info.time = eval(time_str);
    area_info.altitude = eval(altitude_str);
end

area_info.all_times = zeros(10,2,6);
area_info.all_altitudes = zeros(10,2);
no_area = [];
for i=0:9
    try
        area_info.all_times(i+1,:,:) = eval("para_class.Time" + i);
        area_info.all_altitudes(i+1,:) = eval("para_class.Altitude" + i);
    catch
        no_area = [no_area i+1];
    end
end
area_info.all_times(no_area,:,:) = [];
area_info.all_altitudes(no_area,:,:) = [];

end

function [nel, altitude] = remove_altitude(ne, h, area_info)
%REMOVE_ALTITUDE The altitude range of the data goes from 20-200km.
%This function removes the altitudes, which are unnessesary for the
%analysis.

bool_altitude = h < area_info.altitude(1) |...
                h > area_info.altitude(2);      % boolian
            
h(bool_altitude) = [];      % delete all that doesn't match the boolian
ne(bool_altitude,:) = [];   % delete all that doesn't match the boolian
altitude = h; nel = ne;     % create output variable
<<<<<<< HEAD
end

=======
end
>>>>>>> 83c167024b58da016175cec66ccf500c2668368b