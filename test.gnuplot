# set terminal pngcairo  transparent enhanced font "arial,10" fontscale 1.0 size 600, 400 
# set output 'violinplot.4.png'
set border 2 front lt black linewidth 1.000 dashtype solid
unset key
set style data filledcurves 
unset xtics
set ytics border in scale 1,0.5 nomirror norotate  autojustify
set ytics  rangelimit autofreq 
set title "kdensity mirrored sideways to give a violin plot" 
set title  font ",15" norotate
set xrange [ -1.00000 : 5.00000 ] noreverse nowriteback
nsamp = 3000
y = 179.81901992101
DEBUG_TERM_HTIC = 119
DEBUG_TERM_VTIC = 119
J = 0.1
## Last datafile plotted: "$kdensity1"
plot 'violin_data.csv' using (1 + $2/20.):1 with filledcurve x=1 lt 10,      '' using (1 - $2/20.):1 with filledcurve x=1 lt 10,
