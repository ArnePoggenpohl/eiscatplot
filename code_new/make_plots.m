function make_plots(data, parameter)
%MAKE_PLOTS Function to produce all the plots
%   Detailed explanation goes here

load_figure_config

if parameter.plot_select == "all"
    overview_plot(data, parameter)
    histogram_plot(data, parameter)
    scatter_plot(data,parameter)
    detail_nel_plot(data,parameter)
    temperature_plot(data,parameter)
    temperature_line_plot(data,parameter)
else
    if parameter.plot.overview == "on"
        overview_plot(data, parameter)
    end
    if parameter.plot.histogram == "on"
        histogram_plot(data,parameter)
    end
    if parameter.plot.scatter == "on"
        scatter_plot(data,parameter)
    end
    if parameter.plot.detail_nel == "on"
        detail_nel_plot(data,parameter)
    end
    if parameter.plot.temperature == "on"
        temperature_plot(data,parameter)
    end
    if parameter.plot.temperature_line == "on"
        temperature_line_plot(data,parameter)
    end
end
end

function overview_plot(data, parameter)
%OVERVIEW_PLOT Creates the 'map-like' overview of the area.

[time, nel] = overview_time_preparation(data);  % mostly to insert gaps where data is missing
nel(nel < parameter.max_nel) = NaN;             % delete the nel values below the limit for the plot

f=figure('visible','off','units','centimeters','position',[0,0,19,8],'PaperSize',[19,8]);
colormap(myb(200,1));  % EISCAT colormap
pcolor(time, data.altitude, log10(nel)), shading flat;  % -12 seconds so the data is centered over the time measurement and not shifted
hold on
if parameter.heater_lines == "on"
    if data.area_info.area ~= "complete"
        lower_gap = 0.15;    % 15%
        ylim([data.area_info.altitude(1)-lower_gap*diff(data.area_info.altitude)...
            data.area_info.altitude(2)]);
        [line1, line2] = overview_heater(data);
        L=legend([line1;line2],"On for 48 s","Off for 168 s",'Orientation','horizontal');
        L.ItemTokenSize(1)=14;
        set(L.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.9;.9;.9;.8]));  % [.9,.9,.9] is light gray; 0.8 means 20% transparent
    else
        ylim([data.area_info.altitude(1) data.area_info.altitude(2)]);
    end
end

if parameter.title == "on"
    if data.area_info.area == "complete"
        title("EISCAT VHF Observation");
    else
        inputArea = char(data.area_info.area);
        area_num = inputArea(end);
        heater_num_start = (tosecs(data.area_info.time(1,:))...
            - tosecs(data.area_info.heater(1,:))) / sum(data.area_info.heater_int);
        heater_num_end = (tosecs(data.area_info.time(2,:))...
            - tosecs(data.area_info.heater(1,:))) / sum(data.area_info.heater_int);
        heater_num_start = ceil(heater_num_start+1);
        heater_num_end = floor(heater_num_end);
        if heater_num_start <= 1
            heater_num_start = 1;
        elseif heater_num_end <= 1
            heater_num_end = 1;
            warning("It seems like an area without heating is selected. Check the parameter class.")
        end
        title("PMSE signal during heater intervals " +...
            heater_num_start + '$-$' + heater_num_end +...
            " in area " + area_num);
    end
end
if data.area_info.area == "complete" & parameter.rectangle == "on"
    overview_rectangle(data);
end

xlim_start = datetime(str2double(data.area_info.day(1:4)),1,1) +...
    seconds(tosecs(data.area_info.time(1,:)));
xlim_stop = datetime(str2double(data.area_info.day(1:4)),1,1) +...
    seconds(tosecs(data.area_info.time(2,:)));
xlim([xlim_start xlim_stop])
xtickformat('HH:mm:ss');

if isequal(parameter.c_range,"auto")  % auto is the default
    caxis([9 13]);
else
    caxis(parameter.c_range);
end

cbh = colorbar;
cbh.Location='southoutside'; cbh.TickLabelInterpreter='latex';
ylabel(cbh, '$\log_{10}$ of equivalent electron density per m$^3$','Interpreter','latex');
xlabel('Time [UT]'); ylabel('Altitude [km]');
hold off
ax=gca; ax.FontSize=9;
safe_plot(f, "overview", data)
end

function histogram_plot(data, parameter)

[R0, R1, R2, R3, R4] = get_Rs(data);

ratios = cat(3, rdivide(R1,R0), rdivide(R1,R2), rdivide(R2,R3), rdivide(R4,R3), rdivide(R0,R3));
x_label = ["$R_1$ / $R_0$"; "$R_1$ / $R_2$"; "$R_2$ / $R_3$"; "$R_4$ / $R_3$"; "$R_0$ / $R_3$"];
f_title = ["Decline"; "Heating"; "Recovery"; "Relaxation"; "Overshoot"];

mean_arr = zeros(length(x_label),4);        % 4: mean & std, inverse mean & std
for i=1:size(ratios,3)
    f=figure('visible','off','units','centimeters','position',[0,0,9,7],'PaperSize',[9,7]);
    ratio = ratios(:,:,i);
    ratio = ratio(R0 > parameter.min_signal);
    % ratio = ratio(ratio>0.01);  % >0.01: outliers, no physical sense (el. dens. would have to change 2 magnitutes in 24 seconds)
    histogram(ratio(~isnan(ratio)),0:0.1:3,'Normalization','probability')
    hold on
    xline(1,'LineWidth', 1.5,'Color', 'r');
    R = ratio(ratio<1);      % <1: only build mean for ratios smaller 1
    M = mean(R,'omitnan');
    mean_arr(i,:) = [M std(R,1,'omitnan') mean(1./R,'omitnan') std(1./R,1,'omitnan')];
    if ~isnan(M)
        xline(M,'LineWidth', 1.5,'Color', 'g');
    end
    xlim([0 3]);
    ylim([0 0.4]);
    yticklabels(yticks*100);
    text(0.67,0.36,strcat(sprintf('%2.0f',sum(ratio<1,'all')/sum(ratio>0,'all')*100),' \%'),'FontSize',9);
    text(1.05,0.36,strcat(sprintf('%2.0f',(1-sum(ratio<1,'all')/sum(ratio>0,'all'))*100),' \%'),'FontSize',9);
    text(M+0.015,0.31, sprintf('$<$%.2f$>$', M),'FontSize',9);
    %text(M+0.015,0.31, sprintf('$\overline{%.2f}$', M),'FontSize',9);
    text(1.9,0.36,get_date_string(data),'FontSize',7);
    xlabel(x_label(i));
    ylabel('Number per 100 events');
    if parameter.title == "on"
        title(f_title(i));
    end
    ax=gca; ax.FontSize=9;
    safe_plot(f, "histogram" + "_" + f_title(i), data);
end

if parameter.show_mean == "on"
    table = array2table(mean_arr, 'VariableNames',...
        {'Mean','Std','Inverse Mean','Inv. Std'},'RowNames',f_title);
    disp(table)
end

end

function scatter_plot(data ,parameter)
%SCATTER_PLOT Creates the scatter plots. A different way to show the
%ratios
% The variables on the x-axis are choose in such a way, that they should be
% larger than the variables on the y-axis, when we have an overshoot curve.
% An exeption is R0-R4: It's more dependent on the external condtions than
% on the heating.

[R0, R1, R2, R3, R4] = get_Rs(data);
x_label = ["$R_0$"; "$R_3$"; "$R_0$"; "$R_2$"; "$R_3$"; "$R_3$"];
x_data = log10(cat(3, R0, R3, R0, R2, R3, R3));
y_label = ["$R_1$"; "$R_0$"; "$R_4$"; "$R_1$"; "$R_2$"; "$R_4$"];
y_data = log10(cat(3, R1, R0, R4, R1, R2, R4));
f_title = ["Decline"; "Overshoot"; "Subsequent cycles"; "Heating"; "Recovery"; "Relaxation"];

% single plots
for i=1:length(x_label)
    f=figure('visible','off','units','centimeters','position',[0,0,9,7],'PaperSize',[9,7]);
    x = x_data(:,:,i);
    y = y_data(:,:,i);
    
    plot(x(R1>=R0),y(R1>=R0),'x','MarkerEdgeColor',[0,0.2,1],'MarkerSize',6,'LineWidth',0.6,'DisplayName','$R_1$ $\geq$ $R_0$');
    hold on
    plot(x(R1<R0),y(R1<R0),'o','MarkerEdgeColor',[0,0.7,0],'MarkerSize',6,'LineWidth',0.6,'DisplayName','$R_1$ $<$ $R_0$');
    % in case if values of R1 or R0 are missing:
    plot(x(~(R1<R0 | R1>=R0)),y(~(R1<R0 | R1>=R0)),'s','MarkerSize',6,'LineWidth',0.6,'DisplayName','other');
    plot([0:100], [0:100], 'r-','LineWidth',0.6,'HandleVisibility','off');
    L=legend('Location','southeast');
    L.ItemTokenSize(1)=14;
    set(L.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.9;.9;.9;.8]));  % [.9,.9,.9] is light gray; 0.8 means 20% transparent
    if parameter.title == "on"
        title(f_title(i));
    end
    xlim([8.5 13.5]);
    ylim([8.5 13.5]);
    xticks([9 10 11 12 13])
    xticklabels({'$10^9$','$10^{10}$','$10^{11}$','$10^{12}$','$10^{13}$'})
    yticks([9 10 11 12 13])
    yticklabels({'$10^9$','$10^{10}$','$10^{11}$','$10^{12}$','$10^{13}$'})
    xlabel(x_label(i));
    ylabel(y_label(i));
    text(8.9,12.8,get_date_string(data),'FontSize',7);
    grid on
    ax = gca; ax.FontSize = 9;
    
    safe_plot(f, "scatter" + "_" + f_title(i), data);
end

% all scatter plots in one figure
f=figure('visible','off','units','centimeters','position',[0,0,19,27],'PaperSize',[19,27]);
for i=1:length(x_label)
    subplot(3,2,i);
    x = x_data(:,:,i);
    y = y_data(:,:,i);
    
    plot(x(R1>=R0),y(R1>=R0),'x','MarkerEdgeColor',[0,0.2,1],'MarkerSize',6,'LineWidth',0.6,'DisplayName','$R_1$ $\geq$ $R_0$');
    hold on
    plot(x(R1<R0),y(R1<R0),'o','MarkerEdgeColor',[0,0.7,0],'MarkerSize',6,'LineWidth',0.6,'DisplayName','$R_1$ $<$ $R_0$');
    % in case if values of R1 or R0 are missing:
    plot(x(~(R1<R0 | R1>=R0)),y(~(R1<R0 | R1>=R0)),'s','MarkerSize',6,'LineWidth',0.6,'DisplayName','other');
    plot([0:100], [0:100], 'r-','LineWidth',0.6,'HandleVisibility','off');
    L=legend('Location','southeast');
    L.ItemTokenSize(1)=14;
    set(L.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.9;.9;.9;.8]));  % [.9,.9,.9] is light gray; 0.8 means 20% transparent
    if parameter.title == "on"
        title(f_title(i));
    end
    xlim([8.5 13.5]);
    ylim([8.5 13.5]);
    xticks([9 10 11 12 13])
    xticklabels({'$10^9$','$10^{10}$','$10^{11}$','$10^{12}$','$10^{13}$'})
    yticks([9 10 11 12 13])
    yticklabels({'$10^9$','$10^{10}$','$10^{11}$','$10^{12}$','$10^{13}$'})
    xlabel(x_label(i));
    ylabel(y_label(i));
    text(8.9,12.8,get_date_string(data),'FontSize',7);
    grid on
    ax = gca; ax.FontSize = 9;
end
safe_plot(f, "scatter_all", data);

end

function detail_nel_plot(data, parameter)
%DETAIL_NEL_PLOT Gives a detailed view on the equivalent electron density
%for each altitude

[time, nel] = overview_time_preparation(data);  % mostly to insert gaps where data is missing

for i=1:size(data.nel,1)-1      % -1, because the highest altitude cannot be seen in the overview figure
    f=figure('visible','off','units','centimeters','position',[0,0,19,6],'PaperSize',[19,6]);
    colormap(myb(200,1));  % EISCAT colormap
    y = log10(nel(i,:));
    mask = y <= log10(parameter.nel_min);
    y(mask) = [];
    x = time;
    x(mask) = [];
    %plot(x, y,'b.-','MarkerSize',5,'Linewidth',0.5,'HandleVisibility','off'); % plot electron density
    hold on;
    %h = detail_nel_fit(x, y);
    if parameter.heater_lines == "on"
        if data.area_info.area ~= "complete"
            [line1, line2] = detail_nel_heater(data);
            %L=legend([h;line1;line2],"Fitted Model","On for 48 s","Off for 168 s",'Orientation','horizontal');
            L=legend([line1;line2],"On for 48 s","Off for 168 s",'Orientation','horizontal');
            L.ItemTokenSize(1)=14;
            set(L.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.9;.9;.9;.8]));  % [.9,.9,.9] is light gray; 0.8 means 20% transparent
        end
    end
    sz = 60/log(length(data.t));
    scatter(x,y,sz,y,'filled','MarkerEdgeColor','k','HandleVisibility','off');
    xlim_start = datetime(str2double(data.area_info.day(1:4)),1,1) +...
        seconds(tosecs(data.area_info.time(1,:)));
    xlim_stop = datetime(str2double(data.area_info.day(1:4)),1,1) +...
        seconds(tosecs(data.area_info.time(2,:)));
    xlim([xlim_start xlim_stop]);
    xtickformat('HH:mm:ss');
    %ylim([min(log10(nel),[],'all','omitnan')-0.2 max(log10(nel),[],'all','omitnan')+1]);
    ylim([8.5 13.5])
    
    if isequal(parameter.c_range,"auto")  % auto is the default
        caxis([9 13]);
    else
        caxis(parameter.c_range);
    end
    if parameter.title == "on"
        title("PMSE backscattering at " + round(data.altitude(i),1) + " km; " + data.area_info.area);
    end
    xlabel('Time [UT]');
    ylabel('$\log_{10}$ power [arb. unit.]');
    hold off;
    ax=gca;
    ax.FontSize=9;
    safe_plot(f, "detail_nel_" + round(data.altitude(i)*1000), data)
end

% make tiled nel plots
if isnumeric(parameter.nel_tiled)
    tiled = parameter.nel_tiled;
    if max(tiled) > size(data.nel,1)-1
        error('Number choosen for parameter_plot.nel_tiled are exceeding the available number of altitudes in the choosen area.')
    end
    
    f=figure('visible','off','units','centimeters','position',[0,0,19,1+5*size(tiled,2)],'PaperSize',[19,1+5*size(tiled,2)]);
    t=tiledlayout(size(tiled,2),1);
    for i=1:size(tiled,2)
        ax = nexttile;
        colormap(myb(200,1));  % EISCAT colormap
        y = log10(nel(tiled(i),:));
        mask = y <= log10(parameter.nel_min);
        y(mask) = [];
        x = time;
        x(mask) = [];
        hold on;
        if parameter.heater_lines == "on"
            if data.area_info.area ~= "complete"
                [line1, line2] = detail_nel_heater(data);
                L=legend([line1;line2],"On for 48 s","Off for 168 s",'Orientation','horizontal');
                L.ItemTokenSize(1)=14;
                set(L.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.9;.9;.9;.8]));  % [.9,.9,.9] is light gray; 0.8 means 20% transparent
            end
        end
        sz = 60/log(length(data.t));
        scatter(x,y,sz,y,'filled','MarkerEdgeColor','k','HandleVisibility','off');
        xlim_start = datetime(str2double(data.area_info.day(1:4)),1,1) +...
            seconds(tosecs(data.area_info.time(1,:)));
        xlim_stop = datetime(str2double(data.area_info.day(1:4)),1,1) +...
            seconds(tosecs(data.area_info.time(2,:)));
        xlim([xlim_start xlim_stop]);
        xtickformat('HH:mm:ss');
        if i==size(tiled,2)
            xticklabels(ax);
        else
            xticklabels({});
        end
        %ylim([min(log10(nel),[],'all','omitnan')-0.2 max(log10(nel),[],'all','omitnan')+1]);
        ylim([8.5 13.5])
        
        if isequal(parameter.c_range,"auto")  % auto is the default
            caxis([9 13]);
        else
            caxis(parameter.c_range);
        end
        if parameter.title == "on"
            title("PMSE backscattering at " + round(data.altitude(tiled(i)),1) + " km; " + data.area_info.area);
        end
        hold off;

    end
    xlabel(t,'Time [UT]','Interpreter','latex');
    ylabel(t,'$\log_{10}$ power [arb. unit.]','Interpreter','latex');
    t.TileSpacing = 'compact';
    ax=gca;
    ax.FontSize=9;
    safe_plot(f, "detail_nel_tiled_" + round(data.altitude(min(tiled))*1000) + "-"...
        + round(data.altitude(max(tiled))*1000), data)
end
end

function temperature_plot(data, parameter)
%TEMPERATURE_PLOT gives an overview of the calculated temperature in
%the area. The calculation is based on the values of R0 and R1

[T_ehot, x] = calc_temperature(data);
%x = tosecs(data.area_info.heater(1,:)):...
%    sum(data.area_info.heater_int):tosecs(data.area_info.heater(2,:));
%x = x(x >= tosecs(data.area_info.time(1,:)) & x <= tosecs(data.area_info.time(2,:)));
x = datetime(str2double(data.area_info.day(1:4)),1,1) + seconds(x);
x = x(1:size(T_ehot,2));
y = data.altitude;


f=figure('visible','off','units','centimeters','position',[0,0,9,7],'PaperSize',[9,7]);
colormap(jet);
pcolor(x, y, T_ehot),shading flat;
hold on
if parameter.heater_lines == "on"
    if data.area_info.area ~= "complete"
        lower_gap = 0.15;    % 15%
        ylim([data.area_info.altitude(1)-lower_gap*diff(data.area_info.altitude)...
            data.area_info.altitude(2)]);
        line1 = temperature_heater(data);
        L=legend(line1,"Full heating cycle");
        L.ItemTokenSize(1)=14;
        set(L.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.9;.9;.9;.8]));  % [.9,.9,.9] is light gray; 0.8 means 20% transparent
    else
        ylim([data.area_info.altitude(1) data.area_info.altitude(2)]);
    end
end
if parameter.title == "on"
    inputArea = char(data.area_info.area);
    if isnumeric(inputArea(end))
        area_num = inputArea(end);
    else
        area_num = " " + inputArea;
    end
    title("Calculated temperature in " + area_num);
end
xlim_start = datetime(str2double(data.area_info.day(1:4)),1,1) +...
    seconds(tosecs(data.area_info.time(1,:)));
xlim_stop = datetime(str2double(data.area_info.day(1:4)),1,1) +...
    seconds(tosecs(data.area_info.time(2,:)));
xlim([xlim_start xlim_stop])
xtickformat('HH:mm:ss');
if max(T_ehot,[],'all','omitnan') > 800
    caxis([min(T_ehot,[],'all','omitnan') 800]);
end

cbh = colorbar;
cbh.Location='southoutside'; cbh.TickLabelInterpreter='latex';
ylabel(cbh, 'Temperature [K]','Interpreter','latex');
xlabel('Time [UT]'); ylabel('Altitude [km]');
hold off
ax = gca;
ax.FontSize = 9;
safe_plot(f, "temperature", data)
end

function temperature_line_plot(data,parameter)
%TEMPERATURE_LINE_PLOT displays selected coloums of the temperature plot

% if no T_lines are defined for the area, do nothing
try
    idx_lines = data.area_info.T_line;
    if length(idx_lines) > 5
        warning('off','all')    % following gives a warning, if the length is uneven, e.g. end/2 = 3.5; But it is not a problem
        idx_lines1 = idx_lines(1:end/2);
        idx_lines2 = idx_lines(end/2:end);
        warning('on','all')
    end
catch
    return
end

[T_ehot, T_time] = calc_temperature(data);

% Remove highest altitude, because it is not shown in the overview Temp. plot
y = data.altitude(1:end-1);
T_ehot = T_ehot(1:end-1,:);

T_time = datetime(str2double(data.area_info.day(1:4)),1,1) + seconds(T_time);

marker = ["o-"; 'x-'; 's-'; 'd-'; '*-'];

if length(idx_lines) <= 5
    f=figure('visible','off','units','centimeters','position',[0,0,9,7],'PaperSize',[9,7]);
    for i=1:length(idx_lines)
        x = T_ehot(:,idx_lines(i));
        idx = ~any(isnan(x),2);
        plot(x(idx),y(idx),marker(i),'MarkerSize',6,'LineWidth',0.6,'DisplayName',datestr(T_time(idx_lines(i)),'HH:MM:SS'))
        hold on
    end
    L=legend('Location','southeast');
    L.ItemTokenSize(1)=14;
    set(L.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.9;.9;.9;.8]));  % [.9,.9,.9] is light gray; 0.8 means 20% transparent
    ylabel('Altitude [km]'); xlabel('Temperature [K]');
    y_diff = max(y,[],'all') - min(y,[],'all');
    ylim([min(y,[],'all')-y_diff*0.2 max(y,[],'all')+y_diff*0.1]);
    
    if max(T_ehot(:,idx_lines),[],'all','omitnan') > 800
        xlim([min(T_ehot,[],'all','omitnan')-10 800]);
        text(min(T_ehot,[],'all','omitnan')+30,min(y,[],'all')-y_diff*0.12,get_date_string(data),'FontSize', 7);
    else
        xlim([min(T_ehot,[],'all','omitnan')-10 max(T_ehot(:,idx_lines),[],'all','omitnan')+20]);
        text(min(T_ehot,[],'all','omitnan')+10,min(y,[],'all')-y_diff*0.12,get_date_string(data),'FontSize', 7);
    end
    
    hold off
    if parameter.title == "on"
        title('Temperature profile at selected times');
    end
    ax = gca;
    ax.FontSize = 9;
    grid('on');
    safe_plot(f, "temperature_line", data)
else
    f=figure('visible','off','units','centimeters','position',[0,0,9,7],'PaperSize',[9,7]);
    ax = gca;
    ax.FontSize = 9;
    tiled = tiledlayout(1,2);
    
    ax1 = nexttile;
    for i=1:length(idx_lines1)
        x = T_ehot(:,idx_lines1(i));
        idx = ~any(isnan(x),2);
        plot(x(idx),y(idx),marker(i),'MarkerSize',6,'LineWidth',0.6,'DisplayName',datestr(T_time(idx_lines1(i)),'HH:MM:SS'))
        hold on
    end
    L=legend('Location','northeast');
    L.ItemTokenSize(1)=14;
    set(L.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.9;.9;.9;.8]));  % [.9,.9,.9] is light gray; 0.8 means 20% transparent
    y_diff = max(y,[],'all') - min(y,[],'all');
    ylim([min(y,[],'all')-y_diff*0.2 max(y,[],'all')+y_diff*0.1]);
    if max(T_ehot(:,idx_lines1),[],'all','omitnan') > 800
        xlim([min(T_ehot,[],'all','omitnan')-10 800]);
        text(min(T_ehot,[],'all','omitnan')+30,min(y,[],'all')-y_diff*0.12,get_date_string(data),'FontSize', 7);
    else
        xlim([min(T_ehot,[],'all','omitnan')-10 max(T_ehot(:,idx_lines1),[],'all','omitnan')+20]);
        text(min(T_ehot,[],'all','omitnan')+10,min(y,[],'all')-y_diff*0.12,get_date_string(data),'FontSize', 7);
    end
    ax = gca;
    ax.FontSize = 9;
    grid('on')
    hold off
    
    ax2 = nexttile;
    for i=1:length(idx_lines2)
        x = T_ehot(:,idx_lines2(i));
        idx = ~any(isnan(x),2);
        plot(x(idx),y(idx),marker(i),'MarkerSize',6,'LineWidth',0.6,'DisplayName',datestr(T_time(idx_lines2(i)),'HH:MM:SS'))
        hold on
    end
    L=legend('Location','northeast');
    L.ItemTokenSize(1)=14;
    set(L.BoxFace, 'ColorType','truecoloralpha', 'ColorData',uint8(255*[.9;.9;.9;.8]));  % [.9,.9,.9] is light gray; 0.8 means 20% transparent
    ylim([min(y,[],'all')-y_diff*0.2 max(y,[],'all')+y_diff*0.1]);
    if max(T_ehot(:,idx_lines),[],'all','omitnan') > 800
        xlim([min(T_ehot,[],'all','omitnan') 800]);
        text(min(T_ehot,[],'all','omitnan')+30,min(y,[],'all')-y_diff*0.12,get_date_string(data),'FontSize', 7);
    else
        xlim([min(T_ehot,[],'all','omitnan') max(T_ehot(:,idx_lines),[],'all','omitnan')+20]);
        text(min(T_ehot,[],'all','omitnan')+10,min(y,[],'all')-y_diff*0.12,get_date_string(data),'FontSize', 7);
    end
    ax = gca;
    ax.FontSize = 8;
    grid('on')
    hold off
    
    % Link the axes. Add title and labels.
    linkaxes([ax1,ax2],'y');
    xlabel(tiled,'Temperature [K]','FontSize',9,'Interpreter','latex')
    ylabel(tiled,'Altitude [km]','FontSize',9,'Interpreter','latex')
    title(tiled,'Temperature profile at selected times','FontWeight','bold','FontSize',10,'Interpreter','latex');
    yticklabels(ax2,{})
    tiled.TileSpacing = 'compact';
    
    safe_plot(f, "temperature_line", data)
end
end

% Help functions:
function safe_plot(figure, figure_type, data)
%SAFE_PLOT Safe the plot in a folder

if data.area_info.HR == "off"
    directory_name = "figures/" + data.area_info.day(1:4) + "_" +...
        data.area_info.day(6:7) + "_" + data.area_info.day(9:10);
    if ~exist(directory_name, 'dir')
        mkdir(directory_name)          % make a new directory for this area where plots are saved in
    end
    file_name = data.area_info.day(1:4) + "_" + data.area_info.day(6:7) +...
        "_" + data.area_info.day(9:10) + "_" + data.area_info.area +...
        "_" + figure_type;
else
    directory_name = "figures/" + data.area_info.day(1:4) + "_" +...
        data.area_info.day(6:7) + "_" + data.area_info.day(9:10) + "_HR";
    if ~exist(directory_name, 'dir')
        mkdir(directory_name)          % make a new directory for this area where plots are saved in
    end
    file_name = data.area_info.day(1:4) + "_" + data.area_info.day(6:7) +...
        "_" + data.area_info.day(9:10) + "_HR_" + data.area_info.area +...
        "_" + figure_type;
end
print(figure, directory_name + "/" + file_name, '-dpdf', '-r300');
end

function load_figure_config
%LOAD_FIGURE_CONFIG A funtion to set general figure configs such as
%layout or interpreter for all figures

set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
end

function [time, nel] = overview_time_preparation(data)
%OVERVIEW_TIME_PREPARATION Function to have a steady time axis. Without
%it, time gaps in the measurement will be filled with colour.

diff = zeros(length(data.t)-1,1);
for i=1:length(data.t)-1
    diff(i) = round(data.t(i+1)-data.t(i),1);
end

t_diff = mode(diff);    % find the most common time difference within the dataset

if rem(data.area_info.heater_int(1),t_diff) ~= 0
    error("It seems like the time intervals in the data set does not match the time intervals of the heater. Please control the heater information and the time data.")
end

time = data.t;
nel = data.nel;
gaps = find(diff>60);
if ~isempty(gaps)
    for i=1:length(gaps)
        time = cat(1,time(1:gaps(i)+i-1), time(gaps(i)+i-1)+t_diff, time(gaps(i)+i-1+1:end));   % +i, because in each loop one element is added
        nel = cat(2, nel(:,1:gaps(i)+i-1), NaN(size(nel,1),1), nel(:,gaps(i)+i-1+1:end));
    end
end
time = datetime(str2double(data.area_info.day(1:4)),1,1) + seconds(time);

end

function [line1, line2] = overview_heater(data)
%OVERVIEW_HEATER Function to display heater lines. Returns the line
%so they can be labeled

lower_gap = 0.15;

heater_on_s = tosecs(data.area_info.heater(1,:)):...
    sum(data.area_info.heater_int):tosecs(data.area_info.heater(2,:));
heater_off_s = tosecs(data.area_info.heater(1,:)) + data.area_info.heater_int(1):...
    sum(data.area_info.heater_int):tosecs(data.area_info.heater(2,:));

heater_on_alt_start = repmat(data.area_info.altitude(1)-...
    lower_gap*diff(data.area_info.altitude)-1,1,length(heater_on_s));
heater_on_alt_stop = repmat(data.area_info.altitude(2)+1,1,length(heater_on_s));
heater_off_alt_start = repmat(data.area_info.altitude(1)-...
    lower_gap*diff(data.area_info.altitude)-1,1,length(heater_off_s));
heater_off_alt_stop = repmat(data.area_info.altitude(2)+1,1,length(heater_off_s));

x1 = [heater_on_s;heater_on_s;nan(1,length(heater_on_s))];
x2 = [heater_off_s;heater_off_s;nan(1,length(heater_off_s))];

y1 = [heater_on_alt_start;heater_on_alt_stop;nan(1,length(heater_on_s))];
y2 = [heater_off_alt_start;heater_off_alt_stop;nan(1,length(heater_off_s))];
heater_on = datetime(str2double(data.area_info.day(1:4)),1,1) + seconds(x1);
heater_off = datetime(str2double(data.area_info.day(1:4)),1,1) + seconds(x2);

line1 = plot(heater_on(:), y1(:), '--k', 'lineWidth',0.6);      % heating-on line
line2 = plot(heater_off(:), y2(:), ':k', 'lineWidth',0.6);      % heating-off line

if data.area_info.area ~= "complete"
    for i=1:length(heater_on_s)
        if rem(i,2) == 1
            txt = text(heater_on(1,i) + seconds(sum(data.area_info.heater_int)*1/3),...
                data.area_info.altitude(1) - lower_gap*diff(data.area_info.altitude)*1/2,...
                sprintf('%i',i),'FontSize',8);      % display heating period number
            set(txt,'Clipping','on');               % need to be done so the text stays inside the 'xlim'
        end
    end
end

end

function overview_rectangle(data)

% Initialise x and y
x = zeros(size(data.area_info.all_times,1,2));
y = zeros(size(data.area_info.all_altitudes,1,2));
% fill them with data
for i=1:size(data.area_info.all_times,1)
    for j=1:size(data.area_info.all_times,2)
        x(i,j) = tosecs(data.area_info.all_times(i,j,:));
    end
end
for i=1:size(data.area_info.all_altitudes,1)
    for j=1:size(data.area_info.all_altitudes,2)
        y(i,j) = data.area_info.all_altitudes(i,j,:);
    end
end
% remove first data, because it refers to whole area. We only want the "small" areas
x(1,:) = [];
y(1,:) = [];
% bring x into correct time format
x = datetime(str2double(data.area_info.day(1:4)),1,1) + seconds(x);
% plot the rectangles
for i=1:size(x,1)
    plot([x(i,1) x(i,2)], [y(i,1) y(i,1)], 'w-', 'lineWidth',1.5)
    plot([x(i,1) x(i,2)], [y(i,2) y(i,2)], 'w-', 'lineWidth',1.5)
    plot([x(i,1) x(i,1)], [y(i,1) y(i,2)], 'w-', 'lineWidth',1.5)
    plot([x(i,2) x(i,2)], [y(i,1) y(i,2)], 'w-', 'lineWidth',1.5)
    plot([x(i,1) x(i,2)], [y(i,1) y(i,1)], 'r-', 'lineWidth',0.6)
    plot([x(i,1) x(i,2)], [y(i,2) y(i,2)], 'r-', 'lineWidth',0.6)
    plot([x(i,1) x(i,1)], [y(i,1) y(i,2)], 'r-', 'lineWidth',0.6)
    plot([x(i,2) x(i,2)], [y(i,1) y(i,2)], 'r-', 'lineWidth',0.6)
    text(mean(x(i,:)), y(i,2)+1.6, sprintf('%i',i), 'FontSize',9,'Color','k','BackgroundColor','w','HorizontalAlignment', 'Center')
end

end

function [line1, line2] = detail_nel_heater(data)
%DETAIL_NEL_HEATER Function to display heater lines. Returns the line
%so they can be labeled

heater_on_s = tosecs(data.area_info.heater(1,:)):...
    sum(data.area_info.heater_int):tosecs(data.area_info.heater(2,:));
heater_off_s = tosecs(data.area_info.heater(1,:)) + data.area_info.heater_int(1):...
    sum(data.area_info.heater_int):tosecs(data.area_info.heater(2,:));

heater_on_start = repmat(min(log10(data.nel),[],'all','omitnan')-5,1,length(heater_on_s));
heater_on_stop = repmat(max(log10(data.nel),[],'all','omitnan')+5,1,length(heater_on_s));
heater_off_start = repmat(min(log10(data.nel),[],'all','omitnan')-5,1,length(heater_off_s));
heater_off_stop = repmat(max(log10(data.nel),[],'all','omitnan')+5,1,length(heater_off_s));

x1 = [heater_on_s;heater_on_s;nan(1,length(heater_on_s))];
x2 = [heater_off_s;heater_off_s;nan(1,length(heater_off_s))];

y1 = [heater_on_start;heater_on_stop;nan(1,length(heater_on_s))];
y2 = [heater_off_start;heater_off_stop;nan(1,length(heater_off_s))];
heater_on = datetime(str2double(data.area_info.day(1:4)),1,1) + seconds(x1);
heater_off = datetime(str2double(data.area_info.day(1:4)),1,1) + seconds(x2);

line1 = plot(heater_on(:), y1(:), '--k', 'lineWidth',0.6);      % heating-on line
line2 = plot(heater_off(:), y2(:), ':k', 'lineWidth',0.6);      % heating-off line

if data.area_info.area ~= "complete"
    for i=1:length(heater_on_s)
        if rem(i,2) == 1
            txt = text(heater_on(1,i) + seconds(sum(data.area_info.heater_int)*1/5),...    %min(log10(data.nel),[],'all','omitnan')+0.5,...
                8.7,...
                sprintf('%i',i),'FontSize',8);      % display heating period number
            set(txt,'Clipping','on');               % need to be done so the text stays inside the 'xlim'
        end
    end
end

end

function [line] = temperature_heater(data)
%TEMPERATURE_HEATER Function to display heater lines. Returns the line
%so they can be labeled

lower_gap = 0.15;

heater_on_s = tosecs(data.area_info.heater(1,:)):...
    sum(data.area_info.heater_int):tosecs(data.area_info.heater(2,:));

heater_on_alt_start = repmat(data.area_info.altitude(1)-...
    lower_gap*diff(data.area_info.altitude)-1,1,length(heater_on_s));
heater_on_alt_stop = repmat(data.area_info.altitude(2)+1,1,length(heater_on_s));

x = [heater_on_s;heater_on_s;nan(1,length(heater_on_s))];

y = [heater_on_alt_start;heater_on_alt_stop;nan(1,length(heater_on_s))];
heater_on = datetime(str2double(data.area_info.day(1:4)),1,1) + seconds(x);
line = plot(heater_on(:), y(:), '-k', 'lineWidth',0.6);      % heating-on line

if data.area_info.area ~= "complete"
    for i=1:length(heater_on_s)
        if rem(i,2) == 1
            txt = text(heater_on(1,i) + seconds(sum(data.area_info.heater_int)*1/6),...
                data.area_info.altitude(1) - lower_gap*diff(data.area_info.altitude)*1/2,...
                sprintf('%i',i),'FontSize',8);      % display heating period number
            set(txt,'Clipping','on');               % need to be done so the text stays inside the 'xlim'
        end
    end
end
end

function [R0, R1, R2, R3, R4] = get_Rs(data)
%GET_RS Function to get the values needed to build the ratios
%Needed for histograms and compare plots

heater_on_s = tosecs(data.area_info.heater(1,:)):...
    sum(data.area_info.heater_int):tosecs(data.area_info.heater(2,:));
heater_off_s = tosecs(data.area_info.heater(1,:)) + data.area_info.heater_int(1):...
    sum(data.area_info.heater_int):tosecs(data.area_info.heater(2,:));
heater_on_s = heater_on_s(heater_on_s > data.t(1) & heater_on_s < data.t(end));
heater_off_s = heater_off_s(heater_off_s > data.t(1) & heater_off_s < data.t(end));

for i=1:length(heater_on_s)     % get the indices where the heater is turned on
    [~,idx] = min(abs(data.t - heater_on_s(i)));
    idx_on_arr(i) = idx;
end
for i=1:length(heater_off_s)     % get the indices where the heater is turned off
    [~,idx] = min(abs(data.t - heater_off_s(i)));
    idx_off_arr(i) = idx;
end
if idx_on_arr(1) == 1
    idx_on_arr(1) = []; idx_off_arr(1) = [];
elseif idx_on_arr(1) > idx_off_arr(1)
    idx_off_arr(1) = [];
end
R0 = data.nel(:,idx_on_arr-1);      % R0 is the value before the heater is turned on
R1 = data.nel(:,idx_on_arr);        % R1 is the value where the heater is turned on
R2 = data.nel(:,idx_off_arr-1);     % R2 is the value before the heater is turned off
R3 = data.nel(:,idx_off_arr);       % R3 is the value where the heater is turned off
R4 = data.nel(:,idx_on_arr-1);      % R4 is the value before the heater is turned on for the next period
R4(:,1) = [];                         % delete first element of R4, because this element it belongs to next heating period

R_min_size = min([size(R0,2) size(R1,2) size(R2,2) size(R3,2) size(R4,2)]);

R0 = R0(:,1:R_min_size);
R1 = R1(:,1:R_min_size);
R2 = R2(:,1:R_min_size);
R3 = R3(:,1:R_min_size);
R4 = R4(:,1:R_min_size);

% Delete highest altitude of the data (not seen in the 'overview' plot ->
% don't want to analyse it
R0 = R0(1:end-1,:);
R1 = R1(1:end-1,:);
R2 = R2(1:end-1,:);
R3 = R3(1:end-1,:);
R4 = R4(1:end-1,:);
end

function [date_str] = get_date_string(data)
%GET_DATE_STRING Function to get the date of the area in a nice format
%for the figures

date_str = datestr(data.T(1,:), 'dd mmm yyyy') +...
    "; " + data.area_info.area;
end

function [T_ehot, heater_on_s] = calc_temperature(data)
%CALC_TEMPRATURE is a function to calculate the temperature based on the
%ratio R0 and R1

T_i=135;    % ~average temperature
%T_i=[141.5 139.5 137.5 136 134.5 132.5 131];        % temperature in lower atmosphere was higher

heater_on_s = cat(2, ...
    flip(tosecs(data.area_info.heater(1,:))-sum(data.area_info.heater_int):-sum(data.area_info.heater_int):data.t(1)),...
    tosecs(data.area_info.heater(1,:)):sum(data.area_info.heater_int):tosecs(data.area_info.heater(2,:)),...
    tosecs(data.area_info.heater(2,:))+sum(data.area_info.heater_int):sum(data.area_info.heater_int):data.t(end));

heater_on_s = heater_on_s(heater_on_s > data.t(1) & heater_on_s < data.t(end));

for i=1:length(heater_on_s)     % get the indices where the heater is turned on
    [diff,idx] = min(abs(data.t - heater_on_s(i)));
    idx_on_arr(i) = idx;
    diff_arr(i) = diff;
end

if idx_on_arr(1) == 1
    idx_on_arr(1) = [];
end
R0 = data.nel(:,idx_on_arr-1);      % R0 is the value before the heater is turned on
R1 = data.nel(:,idx_on_arr);        % R1 is the value where the heater is turned on

R_min_size = min([size(R0,2) size(R1,2)]);

R0 = R0(:,1:R_min_size);
R1 = R1(:,1:R_min_size);

% Delete highest altitude of the data (not seen in the 'overview' plot ->
% don't want to analyse it
R0 = R0(1:end-1,:);
R1 = R1(1:end-1,:);

R1R0 = rdivide(R1,R0);
R1R0_T=R1R0.*(R1<R0);       % only use ratios, where we can see a decline (R1<R0)
R1R0_T(R1R0_T==0)=NaN;      % use NaN instead of 0 for the plot


T_ehot=((2-sqrt(R1R0_T))./sqrt(R1R0_T)).*T_i;
T_ehot=cat(1, T_ehot, repmat(T_i(1),1,size(T_ehot,2)));                    % add one row, so last row will be plotted
T_ehot=cat(2, T_ehot, repmat(T_i(1),size(T_ehot,1),1));                    % add one column, so last row will be plotted

gaps = diff_arr>60;
T_ehot(:,gaps) = NaN;

heater_on_s=cat(2, heater_on_s, heater_on_s(end));                         % add one row, so last row will be plotted
end
