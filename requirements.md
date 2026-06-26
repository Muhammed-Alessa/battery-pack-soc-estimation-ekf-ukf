# Requirements

This project was developed using MATLAB/Simulink for battery State of Charge (SOC) estimation with Coulomb Counting, Extended Kalman Filter (EKF), and Unscented Kalman Filter (UKF).

## Required Software

The following software is required to run the Simulink model and MATLAB scripts:

- MATLAB
- Simulink
- Simscape
- Simscape Electrical

## Recommended MATLAB Version

The project should run on recent MATLAB releases that support Simscape Electrical battery modeling and MATLAB Function blocks.

The project was developed and tested using a MATLAB/Simulink environment with Simscape Electrical.

Recommended version:

```text
MATLAB R2023b or newer
```

## Required MATLAB Products

The main required MATLAB products are:

```text
MATLAB
Simulink
Simscape
Simscape Electrical
```

## Optional MATLAB Products

The following products may be useful, but are not strictly required for the basic project workflow:

```text
Control System Toolbox
Signal Processing Toolbox
MATLAB Coder
Embedded Coder
Simscape Battery
```

Notes:

- Control System Toolbox can be useful for control and estimation analysis.
- MATLAB Coder and Embedded Coder are useful only if the estimator is later prepared for embedded implementation.
- Simscape Battery is optional because the current project uses a Simscape Electrical table-based battery model.

## Project Files Needed to Run

Make sure the following files and folders exist in the repository:

```text
models/battery_soc_estimation_ekf_ukf.slx
scripts/BatterySOCEstimationData.m
scripts/compute_metrics.m
src/estimators/ekf_soc.m
src/estimators/ukf_soc.m
```

## How to Run the Project

1. Open MATLAB.

2. Clone or download this repository.

3. Add the repository folder to the MATLAB path.

4. Run the battery parameter setup script:

```matlab
run("scripts/BatterySOCEstimationData.m")
```

5. Open the Simulink model:

```matlab
open_system("models/battery_soc_estimation_ekf_ukf.slx")
```

6. Run the simulation from Simulink.

7. After the simulation finishes, run the metrics script:

```matlab
run("scripts/compute_metrics.m")
```

## Expected Outputs

After running the simulation and metrics script, the project should produce:

- SOC comparison plots
- SOC estimation error plots
- RMSE values
- Maximum absolute SOC error values
- EKF and UKF convergence time values

The expected output signals from Simulink are:

```text
soc_true
soc_ekf
soc_ukf
soc_cc
```

The `compute_metrics.m` script uses these signals to calculate the final performance metrics.

## Operating System

The project was prepared on Windows, but it should also work on other operating systems supported by MATLAB and Simulink.

Recommended operating system:

```text
Windows 10 or Windows 11
```

## Hardware Requirements

No special hardware is required because this is a simulation-based project.

Recommended minimum computer specifications:

```text
8 GB RAM
Modern multi-core CPU
At least 2 GB free disk space
```

A stronger computer is recommended for smoother Simulink and Simscape simulation performance.

## Notes

- This is a simulation-only project.
- No physical battery hardware is required.
- No external dataset is required for the basic simulation.
- The EKF and UKF estimators are implemented inside MATLAB Function blocks in the Simulink model.
- Readable copies of the EKF and UKF code are provided in `src/estimators/`.
- The battery parameter script should be run before starting the simulation.

## Troubleshooting

If the Simulink model does not run, check the following:

1. Make sure Simscape and Simscape Electrical are installed.
2. Make sure `BatterySOCEstimationData.m` was run before the simulation.
3. Make sure the repository folder is added to the MATLAB path.
4. Make sure the output signal names match the names used in `compute_metrics.m`.
5. Make sure the Simulink model file path matches the path written in the README.

