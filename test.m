altitude = 10000;
latitude = 90;
longitude = 180;
year = 2023;
doy = 1;
UTseconds = 0;
localApparentSolarTime = UTseconds/3600 + longitude/15;
f107 = 150;
f107Daily = f107;
ap = double([4, 0, 0, 0, 0, 0, 0]); % 1×7 numeric
flags = ones(1, 23);  % Must be 1×23, not 23×1

% Call the MSIS model
atmos = atmosnrlmsise00(altitude, latitude, longitude, year, doy, UTseconds, localApparentSolarTime, ap, flags, 'Oxygen');
disp(atmos)
