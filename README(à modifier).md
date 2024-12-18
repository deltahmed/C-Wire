# C-Wire Project

## **Introduction**

C-Wire is an academic project aimed at analyzing and processing data about electricity distribution stations. It relies on the use of an **AVL tree** to dynamically model and balance data extracted from a CSV file, along with a Shell script to automate filtering and computation.

## **Features**

1. **CSV Data Reading**:

   - The program reads a CSV file containing information about stations (ID, capacity, load).

2. **Station Management with an AVL Tree**:

   - Inserting new stations.
   - Updating loads for existing stations.
   - Maintaining optimal balance in the AVL tree.

3. **Metric Calculation**:

   - Detecting overloaded stations.
   - Identifying underutilized stations (with an adjustable threshold).
   - Handling stations with zero capacity.

4. **Automation with a Shell Script**:

   - Filtering data from the CSV file by station type (HV-B, HV-A, LV) and consumer type (Company, Individual, All).
   - Running the C program with the filtered data.
   - Generating output files.

5. **Result Display and Export**:

   - List of stations sorted by ID.
   - List of overloaded or underutilized stations.

## **Project Structure**

### **Main Directories and Files**

- **`src/`**: Contains the C source code.

  - `main.c`: Main entry point of the program.
  - `AVL.c`: Implementation of AVL tree functions.
  - `AVL.h`: Header for the AVL tree structure and associated functions.

- **`scripts/`**: Contains the Shell script to automate the project.

  - `script.sh`: Automates filtering and running the C program.

- **`data/`**: Contains example CSV files.

  - `data.csv`: Example input file with station data.

- **`output/`**: Contains generated output files.

  - `results.csv`: Sorted list of stations.
  - `problems.csv`: Overloaded or underutilized stations.

- **`README.md`**: Project documentation.

## **Usage**

### **Compilation**

To compile the program in C, use the following command in the `src/` directory:

```bash
gcc main.c AVL.c -o programme_avl -Wall
```

### **Running the C Program Directly**

To run the program with a CSV file:

```bash
./programme_avl <path_to_csv>
```

Example:

```bash
./programme_avl ../data/data.csv
```

### **Automation with the Shell Script**

The `script.sh` script filters the data before processing.

#### **Usage**

```bash
./script.sh <csv_file> <station_type> <consumer_type> <output_file>
```

- **`<csv_file>`**: Path to the CSV file.
- **`<station_type>`**: Filter stations by type (`hvb`, `hva`, `lv`).
- **`<consumer_type>`**: Filter consumers (`comp`, `indiv`, `all`).
- **`<output_file>`**: Path to save the filtered results.

#### **Example**

```bash
./script.sh ../data/data.csv hvb comp ../output/results.csv
```

## **CSV File Format**

The CSV file should follow this structure:

```csv
id,capacity,load
1,1000,200
2,1500,300
3,2000,400
```

- **`id`**: Unique station identifier.
- **`capacity`**: Total station capacity (in kWh).
- **`load`**: Current load (in kWh).

## **Detailed Features**

### **1. Station Insertion and Updates**

Stations are inserted into an AVL tree in sorted order. If a station already exists, its load is updated.

### **2. Metric Calculation**

- **Overloaded Stations**:

  - Detected if `load > capacity`.

- **Underutilized Stations**:

  - Detected if `load < capacity * threshold` (default threshold: 50%).

- **Zero Capacity**:

  - Stations with a capacity of `0` are flagged as invalid.

### **3. Exporting Results**

Sorted results and anomalies are exported to CSV files.

## **Credits**

- **Authors**: Ahmed Amimi, Abdelwaheb Azmani, Remi Saouli
- **Year**: 2024

---

