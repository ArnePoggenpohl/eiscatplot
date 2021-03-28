function parameterCheck(inputDay, inputArea, HR, parameter)
%PARAMETER_CHECK Checks if all chosen input parameter are valid
%   Detailed explanation goes here

% time format
if length(inputDay) == 10
    if ~isequal(isstrprop(inputDay, 'digit'), logical([1 1 1 1 0 1 1 0 1 1]))
        error("The format of the input day is incorrect. Please use the format 'YYYY MM DD' or 'all'.")
    end
else
    if ~isequal(inputDay, 'all')
        error("The format of the input day is incorrect. Please use the format 'YYYY MM DD' or 'all'.")
    end
end

% area format
valid_areas = ["all", "complete", "area1", "area2", "area3", "area4",...
    "area5", "area6", "area7", "area8", "area9"];
if ~(ismember(inputArea,valid_areas))
    error('The format of the input area is incorrect. Please use "all", "area1", "area2", ... "area9"')
end

% HR format
if ~ismember(HR,["on", "off"])
    error('The format of the input parameter HR is incorrect. Please select "on" or "off"')
end

if ~ismember(parameter.plot_select,["all", "select"])
    error('The format of the input parameter parameter_plot.plot_select is incorrect. Please select "all" or "select"')
end
if ~ismember(parameter.plot.overview,["on", "off"])
    error('The format of the input parameter parameter_plot.plot.overview is incorrect. Please select "on" or "off"')
end
if ~ismember(parameter.plot.histogram,["on", "off"])
    error('The format of the input parameter parameter_plot.plot.histogram is incorrect. Please select "on" or "off"')
end
if ~ismember(parameter.plot.scatter,["on", "off"])
    error('The format of the input parameter parameter_plot.plot.scatter is incorrect. Please select "on" or "off"')
end
if ~ismember(parameter.plot.detail_nel,["on", "off"])
    error('The format of the input parameter parameter_plot.plot.detail_nel is incorrect. Please select "on" or "off"')
end
if ~ismember(parameter.plot.temperature,["on", "off"])
    error('The format of the input parameter parameter_plot.plot.temperature is incorrect. Please select "on" or "off"')
end
if ~ismember(parameter.plot.temperature_line,["on", "off"])
    error('The format of the input parameter parameter_plot.plot.temperature_line is incorrect. Please select "on" or "off"')
end

if ~ismember(parameter.title,["on", "off"])
    error('The format of the input parameter parameter_plot.title is incorrect. Please select "on" or "off"')
end

if ~ismember(parameter.heater_lines,["on", "off"])
    error('The format of the input parameter parameter_plot.heater_lines is incorrect. Please select "on" or "off"')
end
if ~ismember(parameter.rectangle,["on", "off"])
    error('The format of the input parameter parameter_plot.rectangle is incorrect. Please select "on" or "off"')
end
if ~(isequal(parameter.c_range,"auto") || (length(parameter.c_range)==2 & isnumeric(parameter.c_range) & parameter.c_range(1)<parameter.c_range(2)))
    error('The format of the input parameter parameter_plot.c_range is incorrect. Please select "auto" or [X Y], where X is the lower and Y the upper limit')
end
if ~isnumeric(parameter.max_nel)
    error('The format of the input parameter parameter_plot.max_nel is not numueric. Only numeric values are accepted.')
end
if ~isnumeric(parameter.min_signal)
    error('The format of the input parameter parameter_plot.min_signal is not numueric. Only numeric values are accepted.')
end
if ~ismember(parameter.show_mean,["on", "off"])
    error('The format of the input parameter parameter_plot.show_mean is incorrect. Please select "on" or "off"')
end
if ~isnumeric(parameter.nel_min)
    error('The format of the input parameter parameter_plot.nel_min is not numueric. Only numeric values are accepted.')
end
if ~(isequal(parameter.nel_tiled,"off") || isnumeric(parameter.nel_tiled))
    error('The format of the input parameter parameter_plot.nel_tiled is incorrect. Please select "off" or integers')
end

end

