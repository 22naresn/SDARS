% Orbit Simulator
clc;
clear;
close all;

% Initialisation
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
figTelemetry = figure(3); set(figTelemetry, 'Units', 'normalized', 'Position', [0.0 0.0 0.5 0.5], 'MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off', 'Name', '', 'WindowStyle', 'normal');
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

% Real-time update loop with MSIS density and visual deorbit after 1 day
burnTriggered = false;
f107Average = 150;
f107Daily = 150;
ap = double([4, 0, 0, 0, 0, 0, 0]);
flags = ones(1, 23);
year = 2024;
doy = 1;

for i = 1:timeStep:simTime
    % Simulated decay after burn
    if burnTriggered
        Ae = A * Cd;  % Effective area
        radius = norm(ECIPos(:,i));  % Orbital radius from Earth's center (m)
        dt = timeStep;  % Simulation time step (s)
    
        decayRate = 3 * pi * rho * radius * (Ae / m);  % decay per second
        decayFactor = 1 - decayRate * dt;
    
        % Prevent decayFactor from going negative or blowing up
        decayFactor = max(decayFactor, 0.95);
    
        ECIPos(:,i) = ECIPos(:,i) * decayFactor;

        % Recalculate LLH from decayed ECI
        ECEF_current = eci2ecef(ECIPos(:,i), i);
        LLH_current = ecef2llhgd(ECEF_current);
    else
        LLH_current = LLHGDPos(:,i);  % use precomputed value before deorbit
    end
    
    % Telemetry Parameters
    % Use LLH_current (updated if decayed, else original)
    latitude = rad2deg(LLH_current(1));
    longitude = rad2deg(LLH_current(2));
    altitude = LLH_current(3);  % meters above MSL

    velocity = norm(ECIVel(:,i));  % m/s (decay affects pos, not vel in this toy model)
    UTseconds = mod(i, 86400);  % seconds in day
    localApparentSolarTime = UTseconds/3600 + longitude/15;

    % MSIS Density (kg/m³)
    atmos = atmosnrlmsise00(altitude, latitude, longitude, ...
              year, doy, UTseconds, ...
              localApparentSolarTime, f107Average, f107Daily, ap, flags);
    rho = atmos(1) * 1e-3;  % convert g/m³ to kg/m³

    % Drag Force Estimate
    Cd = 2.2; A = 1; m = 1;
    drag = 0.5 * rho * velocity^2 * Cd * A / m;

    % Temperature from atmosisa model
    [~, temp] = atmosisa(LLHGDPos(3,i));  % temp in Kelvin

    % Trigger deorbit after 1 day
    if i >= 86400 && ~burnTriggered
        fprintf('Deorbit burn triggered at t = %.0f sec\n', i);
        burnTriggered = true;
        velocity = velocity - 200;  % retrograde burn ΔV
    end
    
    % Update 3D Satellite
    set(plt.sats, 'XData', ECIPos(1,i), ...
                  'YData', ECIPos(2,i), ...
                  'ZData', ECIPos(3,i));

    % Update Ground Trace (you can change color/shape post-burn here)
    if burnTriggered
        set(plt.ground_trace, 'XData', rad2deg(LLHGDPos(2,i)), ...
                              'YData', rad2deg(LLHGDPos(1,i)), ...
                              'CData', [0 1 0]);  % RGB for green
    else
        set(plt.ground_trace, 'XData', rad2deg(LLHGDPos(2,i)), ...
                              'YData', rad2deg(LLHGDPos(1,i)));
    end

    % Rotate Earth
    rotate(globe, [0 0 1], angleRotate);

    % Update Telemetry UI
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