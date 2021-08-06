function [h,t,ne,Te,Ti,vi,dne,dTe,dTi,dvi,az,el,T,ranges] = guisdap_param2cell2regular(mat_files,time_limits)
% GUISDAP_PARAM2CELL2REGULAR reading of GUISDAP mat-files, 
% extracting time, altitude, electron concentration, electron and
% ion temperatures and ion velocities and their errors.
%
% Calling:
%  [h,t,ne,Te,Ti,vi,dne,dTe,dTi,dvi,az,el,T,ranges] = guisdap_param2cell2regular(mat_files[,time_limits])
% Input:
%  mat_files - list of mat-files as returned from DIR - that is a
%              struct array with fields 'name', 'date', 'bytes',
%              'isdir' and 'datenum', here only 'name' is used, so
%              any struct array with a field 'name' will work.
%  time_limits - [2*n x [yyyy mm dd hh mm ss]] array with start and
%                stop-times of periods of interest - only data from
%                files with names between the start and stop-times
%                will be read.
%  
% Output:
%  h   - Altitudes, array with altitudes (km)
%  t   - Time (unix time?), array with observation times [1 x n]
%  ne  - Electron density, array with electron density
%        profiles for each time-step (m^-3)
%  Te  - Electron temperature (K), array with Te altitude profiles
%  Ti  - Ion temperature (K), array with Ti altitude profiles
%  vi  - Ion velocities (m/s) along the beam
%  dne - standard deviation of electron densities
%  dTe - standard deviation of electron temperatures
%  dTi - standard deviation of ion temperatures
%  dvi - standard deviation of ion velocities
%  az  - azimuth angle of radar (degrees)
%  el  - elevation angle of radar (degrees)
%  T   - date and time array [YYYY,MM,DD,hh,mm,ss] [n_time x 6] (UT)
%  ranges - array with ranges (km)
%  
% Example,
%   q = dir('/dir/Dir/*.mat');
%   q = dir('../dir/05*.mat'); 
%   q = dir('./*.mat');  
%   [h,t,ne,Te,Ti,vi,dne,dTe,dTi,dvi,az,el,T] = guisdap_param2cell2regular(q,...
%                                           [2015 02 16 16 0 0;2015 02 16 17 0 0]);
%
%   subplot(3,1,1)
%   pcolor(rem(t/3600,24),h,log10(max(1e8,ne))),shading flat
%   caxis([9 12])    
%   timetick
%   colorbar_labeled('m^{-3}','log','fontsize',12)
%   ylabel('alt (km)')
%   ylabel('')        
%   subplot(3,1,2)
%   pcolor(rem(t/3600,24),h,Te),shading flat                
%   caxis([500 4500])
%   timetick
%   ylabel('altitude (km)')
%   colorbar_labeled('K','linear','fontsize',12)  
%   subplot(3,1,3)
%   pcolor(rem(t/3600,24),h,Ti),shading flat                
%   caxis([250 1500])
%   timetick
%   xlabel('Time (UT)')
%   colorbar_labeled('K','linear','fontsize',12)


% Copyright B. Gustavsson 20100527

if nargout
  OK = 0;
end


if nargin > 1 && ~isempty(time_limits)
  
  StrMat_w_t = char({mat_files.name});
  StrMat_w_t = StrMat_w_t(:,1:end-4);  
  data_times = str2num(StrMat_w_t);
  [t_start_stop] = tosecs(time_limits);
  idxInRange = [];
  for iR = 1:2:length(t_start_stop),
    idxInRange = [idxInRange(:);find(t_start_stop(iR)<=data_times & data_times <= t_start_stop(iR+1))];
  end
  mat_files = mat_files(idxInRange);
end

for i1 = length(mat_files):-1:1,
  
  % load(mat_files(i1).name)
  
  load(sprintf('%s/%s', mat_files(i1).folder, mat_files(i1).name))
  % changed the load, so it can be loaded from seperate folder
  try
    n_e{i1} = r_param(:,1);
    T_i{i1} = r_param(:,2);
    T_e{i1} = r_param(:,2).*r_param(:,3);
    v_i{i1} = r_param(:,5);
    dn_e{i1} = r_error(:,1);
    dT_i{i1} = r_error(:,2);
    dT_e{i1} = r_error(:,3);
    dv_i{i1} = r_error(:,5);
    az(i1) = r_az;
    el(i1) = r_el;
  catch
    error(['All files need to have the same altitude resolution of ne'])
  end
  t(i1) = date2unix(r_time(1,:));
  T(i1,:) = r_time(1,:);
  h{i1} = r_h;
  range_s{i1} = r_range;
end
% keyboard

for i1 = 1:length(t),
  ne(:,i1)  = interp1(h{i1},n_e{i1},h{1});
  Te(:,i1)  = interp1(h{i1},T_e{i1},h{1});
  Ti(:,i1)  = interp1(h{i1},T_i{i1},h{1});
  vi(:,i1)  = interp1(h{i1},v_i{i1},h{1});
  dne(:,i1) = interp1(h{i1},dn_e{i1},h{1});
  dTe(:,i1) = interp1(h{i1},dT_e{i1},h{1});
  dTi(:,i1) = interp1(h{i1},dT_i{i1},h{1});
  dvi(:,i1) = interp1(h{i1},dv_i{i1},h{1});
  ranges(:,i1) = interp1(h{i1},range_s{i1},h{1});
end

h = h{1};
dTe = dTi.*(Te./Ti);


function [unix_time]=date2unix(utc_date)

year = utc_date(1);
month = utc_date(2);
day = utc_date(3);
hour = utc_date(4);
minute = utc_date(5);
second = utc_date(6);
%Specify day 0 
number_of_day_before_day_one=datenum(1970,01,00); %Start time of
                                                  %unix time
absolute_number_of_day=datenum(year,month,day); %Default day one for datenum is january 1st of year 0
julian_day=absolute_number_of_day - number_of_day_before_day_one; %Number of day since day one

seconds_of_day = 3600*hour+60*minute+second;
unix_time = seconds_of_day + 24*3600*julian_day;
