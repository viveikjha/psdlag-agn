#!/usr/bin/env bash

ywindow_of () {
    max=0
    min=-5
    while read line
#    for line in $(cat $1)
    do
        read xval yval xerr yerr <<< $line
        echo $xval $yval
        if (bc <<< "$yval > $max"); then max=$yval; fi
        if (bc <<< "$yval < $min"); then min=$yval; fi
#    done
    done < $1
    echo $(bc <<< "$min - 0.5") $(bc <<< "$max + 0.5")
}

mkdir -p analyses/tables
mkdir -p analyses/plots


# Restore the proper naming conventions for any files stripped
# of their unicode characters.
scripts/fix_thor_names.sh

# Create tables and plot the power spectra distributions and time lags.
for analysis in analyses/*
do
    # Grab and determine labels of analyses, skip if over the same band.
    ref_band=$(basename $analysis|sed 's|\([^≺]*\)[_ ]≺[_ ][^≺_ ]*[_ ]{[^_ ]*}|\1|')
    echo_band=$(basename $analysis|sed 's|[^≺]*[_ ]≺[_ ]\([^≺_ ]*\)[_ ]{[^_ ]*}|\1|')
    err_str=$(basename $analysis|sed 's|[^≺]*[_ ]≺[_ ][^≺_ ]*[_ ]{[^_ ]*;\(σ∊[CLM][MFC]\)}|\1|')

    # Prepare files
    echo "Plotting PSD and time lags for $echo_band, referred to ${ref_band}."
    echoPSD_tabfile=analyses/tables/PSD_${echo_band}_\{${err_str}\}.tab
    refPSD_tabfile=analyses/tables/PSD_${ref_band}_\{${err_str}\}.tab
    timelag_tabfile=analyses/tables/timelag_${ref_band}_≺_${echo_band}_\{${err_str}\}.tab
    PSD_plotfile=analyses/plots/PSD_${echo_band}_\{${err_str}\}.pdf
    timelag_plotfile=analyses/plots/timelag_${ref_band}_≺_${echo_band}_\{${err_str}\}.pdf

    # Output curves to temporary files using perl script, move tables to
    # permanent location. This just assumes there are no conflicts.
    scripts/extract_tables.pl $analysis > /dev/null
    mv tmp.echoPSD $echoPSD_tabfile
    mv tmp.refPSD $refPSD_tabfile
    mv tmp.timelag $timelag_tabfile


    # Plot PSD and save using gnuplot
#    read ymin ymax <<< $(ywindow_of $timelag_tabfile)
#    echo $ymin $ymax
    cat scripts/templates/psd.gp|
        sed "s|%TITLE%|Power Spectrum for Lightcurves $echo_band and $ref_band|"|
        sed "s|%SUBTITLE%|as reported by Fausnaugh et. al, STORM III, 2016|"|
        sed "s|%FILE1%|$echoPSD_tabfile|"|
        sed "s|%LABEL1%|${echo_band}|"|
        #sed "s|%FILE2%|$refPSD_tabfile|"|
        #sed "s|%LABEL2%|${ref_band}|"|
        sed "s|%YMIN%|$ymin|"|sed "s|%YMAX|$ymax|"|
        sed "s|%OUTPUTFILE%|$PSD_plotfile|" > tmp.gp
    gnuplot tmp.gp

    # Plot time lags and save using gnuplot
#    read ymin ymax <<< $(ywindow_of $timelag_tabfile)
    cat scripts/templates/timelag.gp|
        sed "s|%TITLE%|Time Lag for Lightcurve $echo_band relative to $ref_band|"|
        sed "s|%SUBTITLE%|as reported by Fausnaugh et. al, STORM III, 2016|"|
        sed "s|%FILE1%|$timelag_tabfile|"|
        sed "s|%LABEL1%|${echo_band}|"|
        sed "s|%YMIN%|$ymin|"|sed "s|%YMAX|$ymax|"|
        sed "s|%OUTPUTFILE%|$timelag_plotfile|" > tmp.gp
    gnuplot tmp.gp
done

rm tmp.*
