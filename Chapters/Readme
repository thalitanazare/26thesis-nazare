# Model Identification and Pareto Analysis

This folder contains the main code used for system identification, model simulation, and Pareto-front analysis considering both prediction accuracy and computational/environmental cost.

The main script can be adapted and used for two different applications:

1. **Generator/Motor system**
2. **Wave Energy Converter (WEC)**

---

## Main Code

The main code evaluates several candidate model structures, estimates their parameters, validates their dynamic response, and compares the resulting models using:

* Normalised Root Mean Square Error (NRMSE)
* Estimated computational cost
* Equivalent CO₂ emissions
* Pareto-front analysis

The same workflow can be used for both the Generator/Motor case and the WEC case, provided that the correct input and output datasets are loaded.

---

## Datasets

### Generator/Motor Case

For the Generator/Motor system, the input and output data are:

* `u_cc` — input signal
* `y_cc` — output signal

These signals are loaded and processed in the main code before the identification and validation stages.

---

### WEC Case

For the Wave Energy Converter case, the corresponding signals are:

* `wave_surface` — input signal
* `body_float_velocity` — output signal

These variables should replace the Generator/Motor input and output variables in the main script when applying the methodology to the WEC system.

---

## Required Identification Functions

To run the full simulation and model identification process, additional system identification functions are required.

These functions include routines for:

* Generating candidate model terms
* Estimating model parameters
* Extracting model information
* Simulating the identified model
* Selecting non-dominated Pareto-front solutions

The functions used in this work can be adapted or replaced by the user’s own system identification routines.

However, the original identification functions are not included in this repository folder.

For access to the original code, please contact the author.

---

## Usage Notes

Before running the main script, make sure that:

1. The input and output data files are available in the working directory.
2. The correct variables are selected for the desired case.
3. The required system identification functions are available in the MATLAB path.
4. The plotting and Pareto-analysis routines are compatible with the selected dataset.

---

## Repository Structure

A typical folder structure may be organised as follows:

```text
folder_name/
│
├── main.m
├── README.md
├── data/
│   ├── u_cc.csv
│   ├── y_cc.csv
│   ├── wave_surface.csv
│   └── body_float_velocity.csv
│
└── results/
```

The structure can be adapted according to the user’s own dataset and workflow.

---

## Contact

For questions, clarifications, or access to the original system identification functions, please contact the author.

