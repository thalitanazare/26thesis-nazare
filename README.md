# 26Thesis-Nazare

This repository centralises the data, scripts, simulation files, and auxiliary material used to generate the computational results presented in the PhD thesis:

**Energy-Aware Modelling of Nonlinear Dynamical Systems**  
Thalita Emanuelle de Nazaré  
Maynooth University, 2026


## Repository organisation

The repository is organised by thesis chapter. Each chapter folder contains the material required to reproduce, inspect, or support the corresponding analyses presented in the thesis. Depending on the chapter, this may include scripts, datasets, simulation outputs, figures, spreadsheets, or additional implementation files.

The thesis figures indicate which code should be used to reproduce each result. When a figure is generated from a single script, the figure caption identifies the corresponding code file. When a figure depends on more than one script, dataset, or auxiliary file, the caption refers to the folder where the relevant files are stored.

## Chapter structure

 `Chapter 1 — Introduction`

 `Chapter 2 — Global Energy Landscape and Its Evolution`

 `Chapter 3 — Nonlinear Dynamical Systems`

 `Chapter 4 — Historical Perspective on Wind and Wave Energy Systems`

 `Chapter 5 — Floating Inverted Pendulum Model for Analysing the Pitch Stability of Offshore Wind Turbines`

 `Chapter 6 — Data-driven modelling of the RM3 wave energy converter`

 `Chapter 7 — The Emergence of Energy Efficiency in Computing`

 `Chapter 8 — Green-Box System Identification`

 `Chapter 9 — Energy Efficiency in NARMAX Models for Reduced Carbon Footprint`

 `Chapter 10 — A Boolean-Driven Chaotic Framework for Lightweight Pseudo-Random Number Generation`

 `Chapter 11 — Circuit-Based Lower-Bound Error Framework for Lyapunov Exponent Estimation`

 `Chapter 12 — Conclusion and Future Perspectives`

## How to locate the code for a figure

To reproduce a figure from the thesis, locate the corresponding figure caption in the thesis. The caption indicates either the specific code file used to generate the figure or the folder where the required scripts, datasets, and auxiliary files are stored.

When a single code file is indicated, that file can be used directly. When a folder is indicated, the figure depends on more than one file, and the relevant material should be accessed from that folder.

The original folder structure should be preserved when running the scripts, since some routines may use relative paths to load data or save results.

## Notes on reproducibility

The files in this repository were organised to support transparency and reproducibility of the results presented in the thesis. Some scripts may require specific software versions, toolboxes, or simulation environments, such as MATLAB, Simulink, QBlade, WEC-Sim, or SPICE-like circuit simulation tools, depending on the chapter.

When using the material, please refer to the corresponding chapter, figure caption, and thesis description to understand the assumptions, parameters, and modelling context associated with each result.

## Citation

If you use this repository, please cite the thesis and, where applicable, the associated publications linked to each chapter.