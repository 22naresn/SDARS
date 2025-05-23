# SDARS
## Description
The purpose of the SDARS is to simulate a satellite orbit above the earth and it's consequent deorbit. The input of the orbit simulator is TLE data for any satellite. TLE stands for `two line element` that details the orbital elements of a satellite at a given time. The output is two graphs and a telemetry window, one graph for displaying the 3D plot of the satellite orbit and the other for displaying the groundtrace.

## File Structure
`orbit_simulator.m` is the main file to be run. `/functions/` contains all relevant functions to calculate the orbit trajectory. `/conversions/` is a directory of all coordinate transformation functions. `/TLE_Data/` contains satellite specific tle data.

## Running the simulator
1. Add TLE Data file to `TLE_Data/`
2. Edit the initialise segment of `orbit_simulator.m` to include the new TLE Data filename.
3. Change simulation duration if needed, it's defaulted to 1 day (86400s)
4. Run `orbit_simulator.m`

## TLE Data
TLE Data is to be obtained from https://www.celestrak.com/NORAD/elements/