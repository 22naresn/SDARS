altitude = 300000;
latitude = 90;
longitude = 120;
year = 2024;
doy = 1;
UTseconds = 0;
localApparentSolarTime = UTseconds/3600 + longitude/15;
f107Average = 150;
f107Daily = f107Average;
ap = double([4, 0, 0, 0, 0, 0, 0]); % 1×7 numeric
flags = ones(1, 23);  % Must be 1×23, not 23×1

% Call the MSIS model
atmos = atmosnrlmsise00(altitude, latitude, longitude, year, doy, UTseconds, localApparentSolarTime, f107Average, f107Daily, ap, flags);
disp(atmos)
