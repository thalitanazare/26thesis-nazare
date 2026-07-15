## Reproducibility Files

The files required to reproduce the results are also available in the [Open Science Framework repository](https://osf.io/p3f59).

The specifications used in each part of the work are detailed below.

## Simulink Parameters

Both models used the **variable-step `ode45` solver (Dormand–Prince)**.

### Jerk Circuits

#### Solver Configuration

* **Maximum step size:** `1e-4 s`
* **Relative tolerance:** `1e-6`
* **Minimum step size:** `auto`
* **Initial step size:** `auto`
* **Absolute tolerance:** `auto`

#### Finite-Gain Operational Amplifiers

* **Open-loop gain (`A`):** `1000`
* **Input resistance (`Rin`):** `1e6 Ω`
* **Output resistance (`Rout`):** `100 Ω`
* **Minimum output voltage (`Vmin`):** `-12 V`
* **Maximum output voltage (`Vmax`):** `12 V`
* **Noise:** disabled

### Chua Circuits

#### Solver Configuration

* **Maximum step size:** `1e-5 s`
* **Relative tolerance:** `1e-3`
* **Minimum step size:** `auto`
* **Initial step size:** `auto`
* **Absolute tolerance:** `auto`
* **Shape preservation:** disabled
* **Number of consecutive minimum steps:** `1`

#### Finite-Gain Operational Amplifiers

* **Open-loop gain (`A`):** `1000`
* **Input resistance (`Rin`):** `1e6 Ω`
* **Output resistance (`Rout`):** `100 Ω`
* **Minimum output voltage (`Vmin`):** `-15 V`
* **Maximum output voltage (`Vmax`):** `15 V`
* **Noise:** disabled

## Bill of Materials

### Chua 1 and Chua 2

| Component type       |   Specification | Quantity |
| -------------------- | --------------: | -------: |
| Ceramic resistor, 5% |           100 Ω |        2 |
| Ceramic resistor, 5% |           220 Ω |        4 |
| Ceramic resistor, 5% |           700 Ω |        1 |
| Ceramic resistor, 5% |            1 kΩ |        4 |
| Ceramic resistor, 5% |          1.1 kΩ |        1 |
| Ceramic resistor, 5% |          1.8 kΩ |        3 |
| Ceramic resistor, 5% |          2.2 kΩ |        2 |
| Ceramic resistor, 5% |          3.3 kΩ |        2 |
| Ceramic resistor, 5% |           22 kΩ |        4 |
| Capacitor            | `.1J63`, 100 nF |        4 |
| Capacitor            |       `10nJ100` |        1 |
| Capacitor            |       `10nK100` |        1 |
| Integrated circuit   |       `LM324AN` |        2 |

### Jerk 1 and Jerk 2

| Component type       | Specification | Quantity |
| -------------------- | ------------: | -------: |
| Ceramic resistor, 5% |         100 Ω |        1 |
| Ceramic resistor, 5% |         900 Ω |        1 |
| Ceramic resistor, 5% |          1 kΩ |        9 |
| Ceramic resistor, 5% |        2.2 kΩ |        2 |
| Capacitor            |       `1µJ63` |        3 |
| Capacitor            |    `1µK63 LN` |        3 |
| Integrated circuit   |     `TL082IP` |        4 |
| Diode                |      `1N4007` |        2 |

### LBE

| Component type       | Specification | Quantity |
| -------------------- | ------------: | -------: |
| Ceramic resistor, 5% |          1 kΩ |        4 |
| Integrated circuit   |     `LM324AN` |        1 |
| Analog switch        |     `MAX4544` |        2 |

## Cross-Method Validation

For the cross-method validation, the same measured time series used in the proposed LBE-based procedure were also processed using the **Wolf** and **Rosenstein** methods.

### Wolf Method

#### Chua Circuit

* **Input file:** `Chua_ai0.dat`
* **Sampling time:** `0.0001 s`
* **Embedding dimension:** `7`
* **Embedding delay:** `3`
* **Evolution time per length element:** `11`

#### Jerk Circuit

* **Input file:** `Jerk_ai0.dat`
* **Sampling time:** `0.0001 s`
* **Embedding dimension:** `7`
* **Embedding delay:** `8`
* **Evolution time per length element:** `9`

### Rosenstein Method

The Rosenstein estimates were obtained using the Python library [`nolds`](https://github.com/CSchoel/nolds).

#### Chua Circuit

* **Input file:** `Chua_ai0.dat`
* **Embedding dimension:** `7`
* **Lag:** `3`
* **Minimum temporal separation:** `6 samples`
* **Trajectory length:** `22`
* **Sampling frequency:** `10 kHz`

#### Jerk Circuit

* **Input file:** `Jerk_ai0.dat`
* **Embedding dimension:** `9`
* **Lag:** `10`
* **Minimum temporal separation:** `5 samples`
* **Trajectory length:** `15`
* **Sampling frequency:** `10 kHz`
