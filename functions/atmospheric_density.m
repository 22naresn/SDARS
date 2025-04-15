% ATMOSPHERIC_DENSITY Computes density using MSIS-00 model
%
% Inputs:
%   altitude - Altitude above Earth’s surface (m)
%   lat, lon - Satellite latitude/longitude (degrees)
%   doy - Day of the year (1-365)
%   f107 - 10.7 cm solar flux
%   ap - Geomagnetic index
%
% Output:
%   rho - Atmospheric density (kg/m^3)

function rho = atmospheric_density()

    %{if altitude > 1000e3
    %    rho = 0; % No significant drag above 1000 km
    %    return;
    %end

    % Define input conditions for MSIS model
    %height_km = altitude / 1000; % Convert meters to km
    %alt_input = height_km * ones(1,7); % MSIS needs 7 altitude values
    %lat_input = lat * ones(1,7);
    %lon_input = lon * ones(1,7);

    altitude = 10000;
    latitude = 90;
    longitude = 180;
    year = 2023;
    doy = 1;
    UTseconds = 0;
    localApparentSolarTime = UTseconds/3600 + longitude/15;
    f107 = 150;
    f107Daily = f107;
    ap = 4;
    apDaily = ap;

    % Call the MSIS model
    atmos = atmosnrlmsise00(altitude, latitude, longitude, year, doy, UTseconds, localApparentSolarTime, f107, f107Daily, ap, apDaily);
    disp(atmos)
    % Extract density (4th column in output)
    rho = atmos(4) * 1e3; % Convert g/cm³ to kg/m³
    disp(rho)
end
