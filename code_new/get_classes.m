function [day, area, HR] = get_classes(inDay, inArea, inHR)
%GET_CLASSES Function to handle the input 'all'-days
%   Searching for all available classes in this folder and returning
%   arrays with the day, area and high resolution information

if inDay == "all"
    area = "all";
    classes = dir('**/parameter_*');
    for i=1:length(classes)
        name = classes(i).name;
        name = name(11:end-2);
        if name(end-1:end) == "HR"
            HR(i) = "on";
            name = name(1:end-3);
        else
            HR(i) = "off";
        end
        day{i} = strrep(name, '_', ' ');
    end
else
    day = cellstr(inDay);
    area = inArea;
    HR = inHR;
end
end
