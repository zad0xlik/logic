/*75 RANMDOM SAMPLE SELECTIONS - 30 ADDITIONAL ONES WILL BE BASED ON PROFILING ANALYTICS*/
%MACRO Read_data (in_file, out_file, sel, out_excel);

DATA &out_file (drop = rec_no);
   	RETAIN Sel_no &sel Rec_no;
   		IF _N_=1 THEN Rec_no=TOTAL;
   			SET &in_file NOBS=TOTAL;
  		IF RANUNI(4613) LE (Sel_no/Rec_no) THEN DO;
     		OUTPUT;
     		Sel_no=Sel_no-1;
      	  END;
  		 Rec_no=Rec_no-1;
  		IF Sel_no=0 THEN STOP;

				PROC EXPORT DATA=&Out_file
				            OUTFILE=&Out_excel
				            DBMS=EXCEL2000 REPLACE;

*****************************************************************************************;
%MEND Read_data;  *define population, out file, and selection num (105 as determined by audit);

	%Read_data (d02_met_pr, &voutds1, 40, &vOutx1);
	%Read_data (d02_mig, &voutds2, 40, &vOutx1);
	%Read_data (d02_metct, &voutds3, 25, &vOutx1);

*****************************************************************************************;
run;
