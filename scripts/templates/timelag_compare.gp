set terminal png
set termoption dash
set output "%OUTPUTFILE"
set encoding utf8

set title "%TITLE\n{/*0.7 %SUBTITLE}"
set xlabel "Temporal Frequency [days^{-1}]"
set xrange [0.005:0.620]
set logscale x

set ylabel "Lag [days]"
#set yrange [%YMIN:%YMAX]

set key outside
set key center bottom

# Draw line at origin
set arrow from 0.005,0 to 0.620,0 nohead lt 3 lc rgb 'black'
set pointsize 0
plot '%FILE1' using 1:2:3:4 with xyerrorbars title "%LABEL1", \
"%FILE2" using 1:2:3:4 with xyerrorbars title "%LABEL2"
