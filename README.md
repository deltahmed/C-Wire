﻿

<h1 align="center">⚡ C-Wire ⚡</h1>

</p>
<p align="center"> 
  <a href="https://github.com/deltahmed/C-Wire">
    <img src="https://img.shields.io/github/contributors/deltahmed/C-Wire.svg?style=for-the-badge" alt="deltahmed" /> </a>
  <a href="https://github.com/deltahmed/C-Wire">
    <img alt="" src="https://img.shields.io/github/issues/deltahmed/C-Wire.svg?style=for-the-badge">
    </a>
  <a href="https://github.com/deltahmed/C-Wire">
    <img alt="" src="https://img.shields.io/github/forks/deltahmed/C-Wire.svg?style=for-the-badge"></a>
  <a href="https://github.com/deltahmed/C-Wire">
    <img alt="" src="https://img.shields.io/github/stars/deltahmed/C-Wire.svg?style=for-the-badge"></a>
  <a href="https://raw.githubusercontent.com/deltahmed/C-Wire/master/LICENSE">
    <img src="https://img.shields.io/badge/License-BSD%202%20-blue?style=for-the-badge" alt="deltahmed" /> </a>
</p>



</p>
<p align="center"> 
  <a href="https://github.com/deltahmed/C-Wire">
    <img src="https://raw.githubusercontent.com/deltahmed/C-Wire/main/data/demo.gif" alt="deltahmed" /> </a>
</p>


## Table of Contents

* [About The Project](#about-the-project)
  * [Built With](#built-with)
* [Prerequisites](#prerequisites)
* [Environment](#environment)
* [Installation and Usage](#installation-and-usage)
  * [Installation](#installation)
  * [Parameters](#parameters)
  * [Rules](#rules)
  * [Examples](#examples)
  * [CSV format](#csv-format)
  * [Specificity :](#specificity)
    * [Exemple 1 :](#exemple-1)
    * [Exemple 2 :](#exemple-2)
  * [Contributors](#contributors)
  * [License](#licence)

<!-- ABOUT THE PROJECT -->

## About The Project

**C-Wire** is an academic project aimed at analyzing and processing data about electricity distribution stations. It relies on the use of an **AVL tree** to dynamically model and balance data extracted from a CSV file. A **Shell script** processes the .csv input file to extract relevant information, while the C program calculates the total load of consumers connected to each station using a balanced binary search tree for optimized performance.


### Built With

![GCC](https://img.shields.io/badge/-GCC-05122A?style=for-the-badge&logo=GNU)
![C](https://img.shields.io/badge/-C-05122A?style=for-the-badge&logo=C)
![Make](https://img.shields.io/badge/-make-05122A?style=for-the-badge&logo=C)
![Make](https://img.shields.io/badge/-linux-05122A?style=for-the-badge&logo=linux)
![Make](https://img.shields.io/badge/-Shell-05122A?style=for-the-badge&logo=linux)

## Prerequisites
- A recent version of the C compiler and make.
- gnuplot and bash


## Environment 
- This project was created in unix/linux environment.

## Installation and Usage
### Installation
1. Make sure you have installed `gnuplot`:
   ```sh
   sudo apt update && sudo apt install gnuplot
   ```
2. Clone this repository:
   ```sh
   git clone https://github.com/deltahmed/C-Wire.git
   ```
3. Navigate to the project directory:
   ```sh
   cd C-Wire
   ```
4. Run the project:
   ```sh
   bash c-wire.sh -h
   ```

### Usage
  ```sh
  bash c-wire.sh <path_to_csv> <station_type: hva hvb lv> <consumer_type: comp indiv all> [<plant_identifier>] [-h] [-r]
  ```
### Parameters
  - `<path_to_csv>`: Path to the CSV file containing the data. (mandatory)

  - `<station_type>`: Type of station to process (hvb, hva, lv). (mandatory)

  - `<consumer_type>`: Type of consumer to process (comp, indiv, all). (mandatory)

  - `<plant_identifier>`: Identifier of the plant (optional).

  - `-h`: Displays this help message and ignores all other parameters.

  - `-r`: force C compilation can only be the last parameter

### Rules
  - Forbidden combinations: `hvb all`, `hvb indiv`, `hva all`, `hva indiv`.
### Examples
  ```sh
  bash c-wire.sh data.csv hva comp
  bash c-wire.sh data.csv lv indiv 1
  ```
**Make sure your CSV file is correctly formatted to avoid errors.**

### CSV format

```sh
Power plant;HV-B Station;HV-A Station;LV Station;Company;Individual;Capacity;Load
```

### Specificity
- With the command `lv all` you have in addition to the classic output the 10 station with the lowest load and the 10 LV station with the most load (You also have the station Electrical efficiency displayed in this file), you have also a graph of this 20 LV stations

- Here some exemple of the additionnal calculations 

#### Exemple 1
  - `bash c-wire.sh c-wire_v25.dat lv all`

<p align="center"> 
  <a href="https://github.com/deltahmed/C-Wire">
    <img src="https://raw.githubusercontent.com/deltahmed/C-Wire/main/data/minmax_v25.png" alt="deltahmed" /> </a>
</p>

<p align="center"> 
  <a href="https://github.com/deltahmed/C-Wire">
    <img src="https://raw.githubusercontent.com/deltahmed/C-Wire/main/data/graph_v25.png" alt="deltahmed" /> </a>
</p>

#### Exemple 2
  - `bash c-wire.sh c-wire_v25.dat lv all 1`

<p align="center"> 
  <a href="https://github.com/deltahmed/C-Wire">
    <img src="https://raw.githubusercontent.com/deltahmed/C-Wire/main/data/minmax_v25_1.png" alt="deltahmed" /> </a>
</p>

<p align="center"> 
  <a href="https://github.com/deltahmed/C-Wire">
    <img src="https://raw.githubusercontent.com/deltahmed/C-Wire/main/data/graph_v25_1.png" alt="deltahmed" /> </a>
</p>



## Contributors

<a href="https://github.com/deltahmed/C-Wire/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=deltahmed/C-Wire" />
</a>


## Licence 
[![Licence](https://img.shields.io/badge/License-BSD%202%20-blue?style=for-the-badge)](https://raw.githubusercontent.com/deltahmed/C-Wire/refs/heads/main/LICENCE.txt)




