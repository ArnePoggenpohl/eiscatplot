function [area] = get_area(inDay, inArea, inHR)
%GET_AREA Function to handle the input 'all'-area
%   Detailed explanation goes here

if inArea == "all"
    if ~iscell(inDay)
        inDay = cellstr(inDay);
    end
    
    for i=1:length(inDay)
        Day = inDay{i};
        if inHR(i) == "off"
            c_name = "parameter_" + Day(1:4) + "_" + Day(6:7) +...
                "_" + Day(9:10);
            if exist(c_name) ~= 2
                error("The class containing the parameters for the requested day is not available. Please check if the file 'parameter_" +...
                    Day(1:4) + "_" + Day(6:7) + "_" + Day(9:10) + "' exists.")
            end
        else
            c_name = "parameter_" + Day(1:4) + "_" + Day(6:7) +...
                "_" + Day(9:10) + "_HR";
            if exist(c_name) ~= 2
                error("The class containing the parameters for the requested day is not available. Please check if the file 'parameter_" +...
                    Day(1:4) + "_" + Day(6:7) + "_" + Day(9:10) + "_HR" + "' exists.")
            end
        end
        para_class = eval(c_name);                  % NOT UNUSED! it is evaluated in eval(info_number)
        for j=0:99                                  % for up to 100 areas
            info_number = "para_class.Time" + j;    % create string to check for existance, could also use "para_class.Altitude"
            try
                dummy = eval(info_number);          % no evaluation -> catch -> no area assignment
                if j == 0
                    area(i,j+1) = "complete";
                else
                    area(i,j+1) = "area" + j;
                end
            catch
            end
        end
    end
else
    area = inArea;
end

end

