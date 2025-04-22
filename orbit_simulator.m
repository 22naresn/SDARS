% Orbit Simulator
clc;
clear;
close all;

% Initialisation
addpath('./conversions','./tle_data','./functions');
constants()

% TLE Data & Simulation Time
satTLE = deconstruct_TLE('OrbocommTLE.txt');
simTime = 172800;  % 2 days in seconds
%simTime = 86400;  % 1 day in seconds

% Simulate Orbit
[ECIPos,ECIVel,trueAnomaly] = orbitSimulate(satTLE,simTime);
fprintf('The orbital Period of the LEO Satellite is %.0f seconds \n', satTLE.orbitPeriod);

% ECEF and LLH
ECEFPos  = eci2ecef(ECIPos, 1:simTime);
LLHGDPos = ecef2llhgd(ECEFPos);

% Plot Initialization (get handles)
[fig3D, globe, plt, sat_lat, sat_long] = makePlot(ECIPos, LLHGDPos);

% Create Telemetry Window
figTelemetry = figure(3); set(figTelemetry, 'Units', 'normalized', 'Position', [0.0 0.0 0.5 0.5], 'MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off', 'Name', '', 'WindowStyle', 'normal');
altText   = uicontrol('Style', 'text', 'Position', [320 360 250 30], 'FontSize', 12);
latText   = uicontrol('Style', 'text', 'Position', [320 330 250 30], 'FontSize', 12);
lonText   = uicontrol('Style', 'text', 'Position', [320 300 250 30], 'FontSize', 12);
velText   = uicontrol('Style', 'text', 'Position', [320 270 250 30], 'FontSize', 12);
rhoText   = uicontrol('Style', 'text', 'Position', [320 240 250 30], 'FontSize', 12);
dragText  = uicontrol('Style', 'text', 'Position', [320 210 250 30], 'FontSize', 12);
tempText  = uicontrol('Style', 'text', 'Position', [320 180 250 30], 'FontSize', 12);
timeText  = uicontrol('Style', 'text', 'Position', [320 150 250 30], 'FontSize', 12);
testBox   = uicontrol('Style', 'text', 'Position', [320 120 250 30], 'FontSize', 12);

% Constants
omega_earth = 7.2921159e-5;
timeStep = 100;
angleRotate = rad2deg(omega_earth*timeStep);

%Deorbit parameters
deorbitTriggered = false;
deorbitTime = 86400;     % Trigger deorbit after 1 day (in seconds)
deltaV = 100;            % Retro-burn delta V in m/s

% Real-time update loop with MSIS density and visual deorbit after 1 day
burnTriggered = false;
f107Average = 150;
f107Daily = 150;
ap = double([4, 0, 0, 0, 0, 0, 0]);
flags = ones(1, 23);
year = 2024;
doy = 1;

% Constants for drag calculation
Cd = 2.2;       % Drag coefficient
A = 1;          % Cross-sectional area in m^2
m = 1;          % Satellite mass in kg

for i = 80000:timeStep:simTime
    % Get current position and velocity
    r_vec = ECIPos(:,i);
    v_vec = ECIVel(:,i);
    radius = norm(r_vec);
    velocity = norm(v_vec);

    % Convert position to LLH
    if burnTriggered
        % Decay position using simplified model
        Ae = A * Cd;  % Effective cross-section
        dt = timeStep;

        % Atmospheric density (already computed below)
        decayRate = 3 * pi * rho * radius * (Ae / m);  % decay per sec
        decayFactor = max(1 - decayRate * dt, 0.95);   % prevent negative growth

        % Apply decay to ECI position (radial shrinkage)
        ECIPos(:,i) = ECIPos(:,i) * decayFactor;

        % Recompute ECEF/LLH from updated ECI
        ECEF_current = eci2ecef(ECIPos(:,i), i);
        LLH_current = ecef2llhgd(ECEF_current);
    else
        LLH_current = LLHGDPos(:,i);
    end

    % Geodetic params
    latitude  = rad2deg(LLH_current(1));
    longitude = rad2deg(LLH_current(2));
    altitude  = LLH_current(3);

    % Solar/Universal Time
    UTseconds = mod(i, 86400);
    localApparentSolarTime = UTseconds/3600 + longitude/15;

    % Atmospheric Density from MSIS (use updated altitude)
    atmos = atmosnrlmsise00(altitude, latitude, longitude, ...
              year, doy, UTseconds, ...
              localApparentSolarTime, f107Average, f107Daily, ap, flags);
    rho = atmos(1) * 1e-3;

    % Drag force
    drag = 0.5 * rho * velocity^2 * Cd * A / m;

    % ISA Temperature
    [~, temp] = atmosisa(altitude);

    % Trigger deorbit burn
    if i >= deorbitTime && ~burnTriggered
        fprintf('Deorbit burn triggered at t = %.0f sec\n', i);
        burnTriggered = true;
        velocity = velocity - deltaV;  % Retro-burn
    end

    % Update Visualization
    set(plt.sats, 'XData', ECIPos(1,i), ...
                  'YData', ECIPos(2,i), ...
                  'ZData', ECIPos(3,i));

    if burnTriggered
        set(plt.ground_trace, 'XData', rad2deg(LLH_current(2)), ...
                              'YData', rad2deg(LLH_current(1)), ...
                              'CData', [0 1 0]);
    else
        set(plt.ground_trace, 'XData', rad2deg(LLH_current(2)), ...
                              'YData', rad2deg(LLH_current(1)));
    end

    % Earth rotation
    rotate(globe, [0 0 1], angleRotate);

    % Telemetry
    set(altText,  'String', sprintf('Altitude: %.1f km', altitude/1000));
    set(latText,  'String', sprintf('Latitude: %.2f°', latitude));
    set(lonText,  'String', sprintf('Longitude: %.2f°', longitude));
    set(velText,  'String', sprintf('Velocity: %.1f m/s', velocity));
    set(rhoText,  'String', sprintf('Density: %.2e kg/m³', rho));
    set(dragText, 'String', sprintf('Drag: %.2f N/kg', drag));
    set(tempText, 'String', sprintf('Temp: %.2f K', temp));
    set(timeText, 'String', sprintf('Sim Time: %.0f s', i));

    drawnow;
end
