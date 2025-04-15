function D = calculate_drag(eciPos, eciVel, time, Ae, mass)
    % Calculate atmospheric density using atmosnrlmsise00 and compute drag force
    % Inputs:
    % eciPos - Position vector in ECI frame [x; y; z] (meters)
    % eciVel - Velocity vector in ECI frame [vx; vy; vz] (m/s)
    % time   - MATLAB datetime object representing current time
    % Ae     - Effective cross-sectional area (A * Cd) in m^2
    % mass   - Mass of the satellite in kg
    % Output:
    % D      - Drag force vector in ECI frame (Newtons)

    % Convert ECI position to ECEF
    ecefPos = eci2ecef(time, eciPos);
    
    % Convert ECEF to latitude, longitude, and altitude
    llh = ecef2llhgd(ecefPos);
    latitude = rad2deg(llh(1)); % Convert to degrees
    longitude = rad2deg(llh(2)); % Convert to degrees
    altitude = llh(3); % Altitude in meters
    
    % Extract time parameters
    year = year(time);
    dayOfYear = day(time, 'dayofyear');
    UTseconds = hour(time) * 3600 + minute(time) * 60 + second(time);
    
    % Get atmospheric density
    rho = atmosnrlmsise00(altitude, latitude, longitude, year, dayOfYear, UTseconds);
    
    % Compute speed of the satellite
    v = norm(eciVel);
    
    % Compute drag force magnitude
    D_mag = 0.5 * rho * v^2 * Ae;
    
    % Compute drag force vector (opposite to velocity direction)
    D = -D_mag * (eciVel / v);
end
