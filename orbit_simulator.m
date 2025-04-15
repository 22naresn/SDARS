% Orbit Simulator
clc;
clear;
close all;

%% Initialisation
addpath('./module_conversion','./tle_data','./functions');
constants()

% TLE Data & Simulation Time
satTLE = deconstruct_TLE('OrbocommTLE.txt');
simTime = 172800;

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
timeText  = uicontrol('Style', 'text', 'Position', [20 30  250 30], 'FontSize', 12);


% Constants
omega_earth = 7.2921159e-5;
timeStep = 100;
angleRotate = rad2deg(omega_earth*timeStep);

%Deorbit parameters
deorbitTriggered = false;
deorbitTime = 86400;     % Trigger deorbit after 1 day (in seconds)
deltaV = 100;            % Retro-burn delta V in m/s

% Real-time update loop with visual deorbit after 1 day
burnTriggered = false;
for i = 1:timeStep:simTime
    % Convert to ECEF and LLH from ECI
    ecefNow = eci2ecef(ECIPos(:,i), i);
    llhgdNow = ecef2llhgd(ecefNow);

    % Real-time geodetic position
    altitude = llhgdNow(3) / 1000;                 % km
    latitude = rad2deg(llhgdNow(1));               % deg
    longitude = rad2deg(llhgdNow(2));              % deg

    % MSIS Input params
    year = 2023;
    doy = floor(i / 86400) + 1;
    UTseconds = mod(i, 86400);
    f107 = 150; f107Daily = 150;
    ap = double([4 0 0 0 0 0 0]);
    flags = ones(1, 23);

    % Call MSIS Model
    atmos = atmosnrlmsise00(altitude * 1000, latitude, longitude, year, doy, UTseconds);
    rho = atmos(1) / 1000;                         % g/m³ → kg/m³
    temp = atmos(2) - 273.15;                      % Kelvin → °C

    % Velocity & Drag
    velocity = norm(ECIVel(:,i));                  % m/s
    Cd = 2.2; A = 1; m = 1;
    drag = 0.5 * rho * velocity^2 * Cd * A / m;    % N/kg

    % Trigger burn after 1 day
    if i >= 86400 && ~burnTriggered
        fprintf('Deorbit burn triggered at t = %.0f sec\n', i);
        burnTriggered = true;
        velocity = velocity - 200;  % ΔV
    end

    % Simulate decay after burn
    if burnTriggered
        decayFactor = 1 - 0.000002 * (i - 86400);
        ECIPos(:,i) = ECIPos(:,i) * decayFactor;
    end

    % Update satellite
    set(plt.sats, 'XData', ECIPos(1,i), ...
                  'YData', ECIPos(2,i), ...
                  'ZData', ECIPos(3,i));

    % Ground trace
    if burnTriggered
        plot(rad2deg(llhgdNow(2)), rad2deg(llhgdNow(1)), 'rx', ...
             'Parent', plt.ground_trace.Parent);
    else
        set(plt.ground_trace, 'XData', rad2deg(LLHGDPos(2,i)), ...
                              'YData', rad2deg(LLHGDPos(1,i)));
    end

    % Earth rotation
    rotate(globe, [0 0 1], angleRotate);

    % Update telemetry window
    set(altText,  'String', sprintf('Altitude: %.1f km', altitude));
    set(latText,  'String', sprintf('Latitude: %.2f°', latitude));
    set(lonText,  'String', sprintf('Longitude: %.2f°', longitude));
    set(velText,  'String', sprintf('Velocity: %.1f m/s', velocity));
    set(rhoText,  'String', sprintf('Density: %.2e kg/m³', rho));
    set(dragText, 'String', sprintf('Drag: %.2f N/kg', drag));
    set(tempText, 'String', sprintf('Temp: %.2f °C', temp));
    set(timeText, 'String', sprintf('Sim Time: %.0f s', i));

    drawnow;
end
