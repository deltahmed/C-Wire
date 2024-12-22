filename = sprintf("%s", ARG)

set terminal pngcairo size 1000,600 enhanced font 'Arial,12'
set output "graphs/graph.png"

set title "Graph MinMax" font ",14"
set xlabel "LV Id" font ",12"
set ylabel "Energy in kWh" font ",12"

set xtics rotate by -45 font ",10"

set style data histogram
set style histogram cluster gap 1
set style fill solid 0.7 border -1
set boxwidth 0.9

set key outside top center horizontal

set datafile separator ":"

# Plots with color conditions
plot filename using (column(4) < 0 ? $4 : 1/0):xtic(1) title "Negative Values" linecolor rgb "red", \
     filename using (column(4) >= 0 ? $4 : 1/0):xtic(1) title "Positive Values" linecolor rgb "green"
