#!/bin/bash
#echo \#!/bin/bash >> .sh
#echo \#PBS -l nodes=5:ppn=8 >> test.sh
#echo \#PBS -l walltime=16:00:00 >> test.sh

# Information on Executable Binary and Output Log Files
PAR_DIR=/scratch/s/sjohn/alrashid/runs/2014.11.08~SLS
EXEC_NAME=SLS_RT0.x
STAG_CONFIG=B\[W\]T
if [ -a $PAR_DIR/$EXEC_NAME ]
then
	if  [ -a $PAR_DIR/"logQSUB_$STAG_CONFIG.txt" ]
	then
		rm $PAR_DIR/"logQSUB_$STAG_CONFIG.txt"
	fi
	
	# Update of Requisite Dynamically Linked Library Paths
	MEEP_LIB_DIR=/scinet/gpc/Applications6/meep-1.1.1.openmpi-shdf5/lib
	HDF5_LIB_DIR=/scinet/gpc/Libraries/HDF5-1.8.7/v16-serial-intel/lib
	GSL_LIB_DIR=/scinet/gpc/Libraries/gsl-1.15-intel-12.1/lib
	HARMINV_LIB_DIR=/scinet/gpc/Applications6/harminv-1.3.1/lib
	FFTW3_LIB_DIR=/scinet/gpc/Libraries/fftw-3.3.0-intel-openmpi/lib
	MKL_LIB_DIR=/scinet/gpc/intel/ics/composer_xe_2011_sp1.9.293/mkl/lib/intel64
	
	L=4	
	for ANALYTE_COATING in wvgd sfgb sfgt sfgd cmbb cmbt cmbd
	do
		for T in 0.000 0.025 0.050 0.075 0.100
		do
			JOB_NAME=$STAG_CONFIG\__$ANALYTE_COATING\_t$T
			PARAMS="eps_sq 11.56 eps_bg 1.8225 eps_an 2.1025 eps_sg 11.56 eps_su 2.25 w 0.4 w_wg 0.25 del_w 0.05 del_w_wg 0.10 t $T h_sep 1.0 h_PML_factor 2.0 res 40.0 y_shift 0.0 freq_start 0.281 freq_end 0.284 pw_freq_width 0.008 theta_degrees 0.0 calc_time_factor 3.5 tau_sub 0.5 tau_sup 0.5 alpha 2 num_freqs 751 l $L source_pol tm analyte_coating $ANALYTE_COATING index_pert_sb 1 index_pert_wg 0 index_pert_st 1"
			#PARAMS="l $L t $T w 0.4 del_w 0.05 tau_sup 0.5 tau_sub 0.5 w_wg 0.25 del_w_wg 0.1 analyte_coating wvgd freq_start 0.281 freq_end 0.284 pw_freq_width 0.008 num_freqs 501 calc_time_factor 8.0 h_sep 0.75 h_PML_factor 2.0 res 40.0"
			if [ -a $PAR_DIR/$JOB_NAME ]
			then
				rm -r $PAR_DIR/$JOB_NAME
			fi

			mkdir $PAR_DIR/$JOB_NAME
			cp $PAR_DIR/$EXEC_NAME $PAR_DIR/$JOB_NAME
			cd $PAR_DIR/$JOB_NAME
			
			echo \#!/bin/bash >> scheduler.sh
			echo \#PBS -l nodes=5:ppn=8 >> scheduler.sh
			echo \#PBS -l walltime=24:00:00 >> scheduler.sh

			echo export LD_LIBRARY_PATH=$MEEP_LIB_DIR:$HDF5_LIB_DIR:$GSL_LIB_DIR:$HARMINV_LIB_DIR:$FFTW3_LIB_DIR:$MKL_LIB_DIR:$LD_LIBRARY_PATH >> scheduler.sh

			echo cd \$PBS_O_WORKDIR >> scheduler.sh
			echo mpirun -n 40 ./$EXEC_NAME $PARAMS \> $JOB_NAME.out >> scheduler.sh

			echo JOB_NAME=$JOB_NAME >> $PAR_DIR/"logQSUB_$STAG_CONFIG.txt"
			echo qsub scheduler.sh >> $PAR_DIR/"logQSUB_$STAG_CONFIG.txt"
			qsub scheduler.sh >> $PAR_DIR/"logQSUB_$STAG_CONFIG.txt"
		done
	done

else
	echo Error: Executable file $PWD/$EXEC_NAME not found!
fi
