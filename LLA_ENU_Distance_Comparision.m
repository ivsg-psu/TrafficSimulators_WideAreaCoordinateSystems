%%%%%%%%%%%%  Script   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose: this script is used to compare the geodesic distance under LLA coordinate and
% Euclidean distance under ENU coordinate 
% 
% Author:       Liming
% Created Date: 2020-07-11
% Modified: 2023-02-14 by SBrennan@psu.edu
% - Better comments
% - Better organization
%
% One of the distance() function errors should be caused by the MATLAB map toolbox: 
% To fix it, simply replace two places of
%  flat = ecc2flat(ellipsoid);
% into 
%  flat = ecc2flat(ellipsoid(2));
% in the  ~\"your matlab installation folder"\toolbox\map\map\private\geodesicinv.m
%
% To find this location, type "which distance" - it is likely in the same
% folder
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

addpath('Data')
addpath(genpath('Utilities'));

%% Load and generate some data 
LatLon = [];
load('LLData.mat'); % LL data of I99 segment from Altoona to State College, data
%interval is 0.1m
LatLon = LatLon(1:1000:end,:); % change the interval by jump selection
%
if isempty(LatLon) % generate some straight line data if there is no data loaded
    latTestTrack = 40.8623120388889;
    lonTestTrack = -77.8362701277778;
    altTestTrack = 0;
    
    latBedfold = 40.017296; % the end of I99
    lonBedfold = -78.502092;
    altBedfold = 0;
    
    % latBedfold = 33.755984; %Atlanta
    % lonBedfold = -84.393985;
    % altBedfold = 0;
    
    lanAtlanta = 33.755984; %Atlanta
    lonAtlanta = -84.393985;
    altAtlanta = 0;
    
    latTestTrack_to_Bedfold = linspace(latTestTrack,latBedfold,1000000)'; % 1 meter
    lonTestTrack_to_Bedfold = linspace(lonTestTrack,lonBedfold,1000000)';
    altTestTrack_to_Bedfold = linspace(altTestTrack,altBedfold,1000000)';
    
else
    latTestTrack = LatLon(1,1);  % alTOONA
    lonTestTrack = LatLon(1,2);
    altTestTrack = 0;
    
    latBedfold = LatLon(end,1); % State college
    lonBedfold = LatLon(end,2);
    altBedfold = 0;
    
    latTestTrack_to_Bedfold = LatLon(:,1); % 
    lonTestTrack_to_Bedfold = LatLon(:,2); % 
    altTestTrack_to_Bedfold = zeros(length(lonTestTrack_to_Bedfold),1);
    
end
% convert LLA to ENU
[xEast_TestTrack,yNorth_TestTrack,zUp_TestTrack] = geodetic2enu(latTestTrack,lonTestTrack,altTestTrack,latTestTrack,lonTestTrack,altTestTrack,wgs84Ellipsoid);

[xEast_Bedfold,yNorth_Bedfold,zUp_Bedfold] = geodetic2enu(latBedfold,lonBedfold,altBedfold,latTestTrack,lonTestTrack,altTestTrack,wgs84Ellipsoid);

[xEast_TestTrack_to_Bedfold,yNorth_TestTrack_to_Bedfold,zUp_TestTrack_to_Bedfold] = geodetic2enu(latTestTrack_to_Bedfold,lonTestTrack_to_Bedfold,altTestTrack_to_Bedfold,latTestTrack,lonTestTrack,altTestTrack,wgs84Ellipsoid);

% convert ENU back to LLA
[latTestTrack_to_Bedfold_reverse,lonTestTrack_to_Bedfold_reverse,altTestTrack_to_Bedfold_reverse] = enu2geodetic(xEast_TestTrack_to_Bedfold,yNorth_TestTrack_to_Bedfold,zUp_TestTrack_to_Bedfold,latTestTrack,lonTestTrack,altTestTrack,wgs84Ellipsoid);

% find ENU LLA transformation error
transformation_error = [latTestTrack_to_Bedfold_reverse,lonTestTrack_to_Bedfold_reverse,altTestTrack_to_Bedfold_reverse] - [latTestTrack_to_Bedfold,lonTestTrack_to_Bedfold,altTestTrack_to_Bedfold];
[max_transformation_error, index] = max(transformation_error)

%
figure(001) % plot the data trajectory
clf;
%geoplot([latTestTrack latBedfold lanAtlanta],[lonTestTrack lonBedfold lonAtlanta],'g-*','LineWidth',1);
%hold on
geoplot(latTestTrack_to_Bedfold,lonTestTrack_to_Bedfold,'r-','LineWidth',2)
% geolimits([33 41],[-85 -77])
geolimits([40 41],[-79 -77.5])
if isempty(LatLon)
    text(latTestTrack,lonTestTrack,'TestTrack');
    text(latBedfold,lonBedfold,'Bedfold-End of I99');
else
    text(latTestTrack,lonTestTrack,'Altoona');
    text(latBedfold,lonBedfold,'State College');
end
%text(lanAtlanta,lonAtlanta,'Atlanta');
%geobasemap colorterrain
%geobasemap landcover
geobasemap satellite

%% ----------------------------------------------------
% compare 1: Calculate the geodesic distance and Euclidean distance of start to end of
% the trajectory 
% 'gc' — Great circle distances are computed on a sphere and geodesic distances are computed on an ellipsoid.
% 
% 'rh' — Rhumb line distances are computed on either a sphere or ellipsoid.
%  On a Mercator projection map, any rhumb line is a straight line; a rhumb line can be drawn on such a map between any two points on Earth without going off the edge of the map

[GeoD_Testtrack_to_Bedfold,~] = distance('gc',latTestTrack,lonTestTrack,latBedfold,lonBedfold, referenceEllipsoid('wgs84'));

% refEllipse = referenceEllipsoid('wgs84','m');
% [GeoD_Testtrack_to_Bedfold,~] = distance(latTestTrack,lonTestTrack,latBedfold,lonBedfold,refEllipse);

% pos1     = [latTestTrack, lonTestTrack];
% pos2     = [latBedfold, lonBedfold];
% h        = 0;                                 % // altitude                         
% SPHEROID = referenceEllipsoid('wgs84', 'km'); % // Reference ellipsoid. You can enter 'km' or 'm'    
% [N, E]   = geodetic2ned(pos1(1), pos1(2), h, pos2(1), pos2(2), h, SPHEROID);
% GeoD_Testtrack_to_Bedfold = norm([N, E]); 

ENUD_Testtrack_to_Bedfold = sqrt((xEast_TestTrack-xEast_Bedfold).^2+(yNorth_TestTrack-yNorth_Bedfold).^2+(zUp_TestTrack-zUp_Bedfold).^2)
distance_diff = GeoD_Testtrack_to_Bedfold - ENUD_Testtrack_to_Bedfold
%----------------------------------------

%% compare 2: calculate the interval distance and the sum of them to get the station
[GeoInterval_Testtrack_to_Bedfold,~] = distance('gc',[latTestTrack_to_Bedfold(1:end-1) lonTestTrack_to_Bedfold(1:end-1)],[latTestTrack_to_Bedfold(2:end) lonTestTrack_to_Bedfold(2:end)]); %,wgs84Ellipsoid);
% [GeoInterval_Testtrack_to_Bedfold,~] = distance('gc',LatLon(1:end-1,:),LatLon(2:end,:),wgs84Ellipsoid);
GeoStation_Testtrack_to_Bedfold = [0; cumsum(GeoInterval_Testtrack_to_Bedfold)];

ENUInterval_Testtrack_to_Bedfold = sqrt((diff(xEast_TestTrack_to_Bedfold)).^2+(diff(yNorth_TestTrack_to_Bedfold)).^2+(diff(zUp_TestTrack_to_Bedfold)).^2);
ENUStation_Testtrack_to_Bedfold = [0 ; cumsum(ENUInterval_Testtrack_to_Bedfold)];

Interval_diff = (GeoInterval_Testtrack_to_Bedfold - ENUInterval_Testtrack_to_Bedfold);

figure(002)
plot(GeoStation_Testtrack_to_Bedfold,'b.','MarkerSIze',15)
hold on
plot(ENUStation_Testtrack_to_Bedfold,'r.')
legend('GeoStation_Testtrack_to_Bedfold','ENUStation_Testtrack_to_Bedfold')
hold off
grid on
xlabel('point Number')
ylabel('station')

figure(0021)
% plot(GeoStation_Testtrack_to_Bedfold,'b.','MarkerSIze',15)
% hold on
plot(ENUStation_Testtrack_to_Bedfold,[0; Interval_diff],'r.')
legend('Geo interval - ENU interval')
grid on
xlabel('point Number')
ylabel('Interval diff')
%
figure(003)
plot(ENUStation_Testtrack_to_Bedfold, (GeoStation_Testtrack_to_Bedfold - ENUStation_Testtrack_to_Bedfold)*1000,'b.','MarkerSIze',15)
hold on
% plot(ENUStation_Testtrack_to_Bedfold,'r.')
legend('GeoStation -  ENUStation')
hold off
grid on
xlabel('ENUStation [m]')
ylabel('station difference [mm]')
station_error = GeoStation_Testtrack_to_Bedfold(end) - ENUStation_Testtrack_to_Bedfold(end)

% compare 3: Geodecis distance and Euclidean distance from each point of
% the trajectory to the start point

[GeoDistance_Testtrack_to_Bedfold,~] = distance('gc',repmat([latTestTrack_to_Bedfold(1) lonTestTrack_to_Bedfold(1)],length(latTestTrack_to_Bedfold),1),[latTestTrack_to_Bedfold lonTestTrack_to_Bedfold]); %,wgs84Ellipsoid);

ENUDistance_Testtrack_to_Bedfold = sqrt((xEast_TestTrack_to_Bedfold-xEast_TestTrack_to_Bedfold(1)).^2+...
                                    (yNorth_TestTrack_to_Bedfold - yNorth_TestTrack_to_Bedfold(1)).^2+(zUp_TestTrack_to_Bedfold - zUp_TestTrack_to_Bedfold(1)).^2);

distanceDiff = (abs(GeoDistance_Testtrack_to_Bedfold - ENUDistance_Testtrack_to_Bedfold));
[min_distanceDiff, min_index] = min(distanceDiff(2:end))

figure(004)
plot(GeoDistance_Testtrack_to_Bedfold,'b.','MarkerSIze',15)
hold on
plot(ENUDistance_Testtrack_to_Bedfold,'r.')
legend('GeoDisatnce\_Testtrack\_to\_Bedfold','ENUDistance\_Testtrack\_to\_Bedfold')
hold off
grid on
xlabel('point Number')
ylabel('station')

figure(005)
plot(GeoDistance_Testtrack_to_Bedfold,GeoDistance_Testtrack_to_Bedfold - ENUDistance_Testtrack_to_Bedfold,'b.','MarkerSIze',15)
hold on
%plot(ENUDistance_Testtrack_to_Bedfold,'r.')
legend('GeoDistance -  ENUDistance')
hold off
grid on
xlabel('Geo distance [m]')
ylabel('distance difference [m]')


figure(006)
plot(GeoStation_Testtrack_to_Bedfold,GeoDistance_Testtrack_to_Bedfold - ENUStation_Testtrack_to_Bedfold,'b.','MarkerSIze',15)
hold on
%plot(ENUDistance_Testtrack_to_Bedfold,'r.')
legend('GeoDistance\_Testtrack\_to\_Bedfold - GeoStation\_Testtrack\_to\_Bedfold')
hold off
grid on
xlabel('Geo Station')
ylabel('distance difference [m]')

GeoDistance_Testtrack_to_Bedfold(end) - GeoD_Testtrack_to_Bedfold
%------------------------------------------------------------------
%% Compare 4: test the accuray of distance() function for two close points, which use Haversine formula to calculate the great circle distance, 
% The calculate accuracy of small range point is low
 %addpath('geographiclib_toolbox_1.50')

LatLonTwoPoint = LatLon([2,13],:)
% LatLonTwoPoint = [40 -77 ;40 -77.000001]
earth = referenceSphere('Earth');
[E_TwoPoint,N_TwoPoint,U_TwoPoint ]= geodetic2enu(LatLonTwoPoint(:,1),LatLonTwoPoint(:,2),zeros(size(LatLonTwoPoint(2,:)))',LatLonTwoPoint(1,1),LatLonTwoPoint(1,2),0,earth); %earth,,wgs84Ellipsoid
ENU_TwoPoint = [E_TwoPoint,N_TwoPoint,U_TwoPoint ];
[GeoD_TwoPoint_gc,~] = distance('gc',LatLonTwoPoint(1,:),LatLonTwoPoint(2,:),earth)
%GeoD_TwoPoint_lib = geoddistance(LatLonTwoPoint(1,1), LatLonTwoPoint(1,2), LatLonTwoPoint(2,1), LatLonTwoPoint(2,2))
ENUD_TwoPoint = sqrt(sum(diff(ENU_TwoPoint).^2))
% GeoD_TwoPoint - ENUD_TwoPoint
GeoD_TwoPoint_gc - ENUD_TwoPoint % GeoD_TwoPoint_gc is the sphere greate circle distance 
% GeoD_TwoPoint - GeoD_TwoPoint_lib
sind((LatLonTwoPoint(1,1)-LatLonTwoPoint(2,1))/2).^2
sind((LatLonTwoPoint(1,2)-LatLonTwoPoint(2,2))/2).^2

return 
figure(0100)
% Geographic tracks from starting and ending points
% Set up the axes.
axesm('mercator','MapLatLimit',[30 50],'MapLonLimit',[-40 40])

% Calculate the great circle track.
[lattrkgc,lontrkgc] = track2(40,-35,40,35);

% Calculate the rhumb line track.
[lattrkrh,lontrkrh] = track2('rh',40,-35,40,35);

% Plot both tracks.
plotm(lattrkgc,lontrkgc,'k','LineWidth',2)
plotm(lattrkrh,lontrkrh,'r','LineWidth',2)


%GeoD_Testtrack_to_Bedfold = [reckon('rh',P_CG(1),P_CG(2),arclen_RL,az_RL,wgs84Ellipsoid) P_CG(3)];
