# Satellite Deorbit and Atmospheric Reentry Simulation (SDARS)

This repository contains the MATLAB-based simulation framework described in the paper:

**Modelling Satellite Orbit Decay and Controlled Reentry Using Empirical Atmospheric Drag Models**  
_Presented at ITDECC 2025_
ISBN 978-93-7196-538-
---

## Overview
A lightweight MATLAB environment to simulate and visualize the post-mission orbital decay and controlled reentry of satellites in Low Earth Orbit (LEO). The simulator integrates TLE-based orbit initialization, empirical atmospheric density (NRLMSISE-00), a simple drag-induced decay model, and real-time visualization + telemetry.

---

## Features
- Initialize orbits from Two-Line Element (TLE) data
- NRLMSISE-00 atmospheric density integration for realistic drag
- Synthetic retrograde burn (deorbit) and drag-induced decay modelling
- 3D Earth-centered visualization and 2D ground track projection
- Live telemetry (altitude, velocity, density, drag) and time-series logs

---


## Getting started / Usage
1. Clone this repository onto your local machine.

2. Open the project in MATLAB. Locate the main simulation script (commonly named `main.m`, `run_simulation.m`, or similar) and run it. The project uses MATLAB functions to:
- parse TLEs;
- compute ECI↔ECEF↔LLH transforms;
- query an MSIS implementation for atmospheric density;
- propagate the orbit and visualize telemetry.

3. Adjust parameters (TLE, satellite mass/area/Cd, deorbit timing, solar indices) in the configuration script or top of the main file to experiment with different scenarios.

> Note: This repository assumes you have MATLAB installed. If the NRLMSISE-00 port is included, make sure it is on the MATLAB path (look for `atmosnrlmsise00` or similar).

---

## Authors
- Nilesh Naresh
- Dr. A. Srikrishnan
- Amuthanantham K 
- M Nithesh Narayana    
- Parella Balakrishna  
- Pravin Jayanth E  

---

## Citation
If you use this work, please cite the conference paper:

```bibtex
@inproceedings{naresh2025sdars,
  title={Modelling Satellite Orbit Decay and Controlled Reentry Using Empirical Atmospheric Drag Models},
  author={Naresh, Nilesh and Narayana, M Nithesh and Srikrishnan, A and Balakrishna, Parella and Amuthanantham, K and Jayanth, Pravin E},
  booktitle={International Conference on Innovations and Technological Development in Electronics, Computers and Communication (ITDECC)},
  year={2025}
}
```

---

## License
This project is released under the MIT License. See `LICENSE` for details.
