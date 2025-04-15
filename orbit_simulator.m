% Orbit Simulator
clc;
clear;
close all;

%% Initialisation
addpath('./module_conversion','./tle_data','./functions');
constants()

% TLE Data & Simulation Time
satTLE = deconstruct_TLE('OrbocommTLE.txt');
simTime = 86400;

% Simulate Orbit
[ECIPos,ECIVel,trueAnomaly] = orbitSimulate(satTLE,simTime);
fprintf('The orbital Period of the LEO Satellite is %.0f seconds \n', satTLE.orbitPeriod);

% ECEF and LLH
ECEFPos  = eci2ecef(ECIPos, 1:simTime);
LLHGDPos = ecef2llhgd(ECEFPos);

% Plot Initialization (get handles)
[fig3D, globe, plt, sat_lat, sat_long] = makePlot(ECIPos, LLHGDPos);

% Create Telemetry Window
figTelemetry = figure('Name', 'Telemetry', 'NumberTitle', 'off', 'Position', [1200, 300, 300, 300]);
altText   = uicontrol('Style', 'text', 'Position', [20 240 250 30], 'FontSize', 12);
latText   = uicontrol('Style', 'text', 'Position', [20 210 250 30], 'FontSize', 12);
lonText   = uicontrol('Style', 'text', 'Position', [20 180 250 30], 'FontSize', 12);
velText   = uicontrol('Style', 'text', 'Position', [20 150 250 30], 'FontSize', 12);
rhoText   = uicontrol('Style', 'text', 'Position', [20 120 250 30], 'FontSize', 12);
dragText  = uicontrol('Style', 'text', 'Position', [20 90  250 30], 'FontSize', 12);
tempText  = uicontrol('Style', 'text', 'Position', [20 60  250 30], 'FontSize', 12);


% Constants
omega_earth = 7.2921159e-5;
timeStep = 100;
angleRotate = rad2deg(omega_earth*timeStep);

% Real-time update loop
for i = 1:timeStep:simTime
    % Update 3D Satellite
    set(plt.sats, 'XData', ECIPos(1,i), ...
                  'YData', ECIPos(2,i), ...
                  'ZData', ECIPos(3,i));
    
    % Update Ground Trace
    set(plt.ground_trace, 'XData', rad2deg(LLHGDPos(2,i)), ...
                          'YData', rad2deg(LLHGDPos(1,i)));
    
    % Rotate Earth
    rotate(globe, [0 0 1], angleRotate);
    
    % Real-time telemetry values
    altitude = LLHGDPos(3,i) / 1000;               % km
    latitude = rad2deg(LLHGDPos(1,i));             % deg
    longitude = rad2deg(LLHGDPos(2,i));            % deg
    velocity = norm(ECIVel(:,i));                  % m/s
    rho = 1.225 * exp(-altitude / 7.64);           % kg/m³, exponential density
    Cd = 2.2; A = 1; m = 1;
    drag = 0.5 * rho * velocity^2 * Cd * A / m;    % N/kg
    temp = 15 + 10 * sin(i/10000);                 % dummy temp °C

    % Update UI
    set(altText,  'String', sprintf('Altitude: %.1f km', altitude));
    set(latText,  'String', sprintf('Latitude: %.2f°', latitude));
    set(lonText,  'String', sprintf('Longitude: %.2f°', longitude));
    set(velText,  'String', sprintf('Velocity: %.1f m/s', velocity));
    set(rhoText,  'String', sprintf('Density: %.2e kg/m³', rho));
    set(dragText, 'String', sprintf('Drag: %.2f N/kg', drag));
    set(tempText, 'String', sprintf('Temp: %.2f °C', temp));
    
    drawnow;
end