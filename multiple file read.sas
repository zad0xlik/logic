DM log 'clear' log;

*****************************************************************************************;
*****   multiple file read-in							    *****;
*****   xxxx.sas							            *****;
*****   Last Modified: xx/xx/xxxx by zad0xli	                                    *****;
*****************************************************************************************;

*Define path for processing files;
%LET PATHNAME=X:XXXX;

LIBNAME SASDATA "&PATHNAME.\SASDATA";

/*DELETE PERMAMENT DATASET SO THE READ-IN WON'T CREATE DUPLICATE RECORDS*/
PROC DATASETS LIBRARY=SASDATA KILL NOLIST; QUIT;
PROC DATASETS LIBRARY=WORK KILL NOLIST; QUIT;

*DEFINE INPUT FILES TO CONTAIN LISTING OF FILES TO BE READ IN;
%let vInfile = "&PATHNAME\RAWDATA\XXXX\*.txt";


**************************Read in data*********************************;
/*CMD COMMAND TO LIST ALL FILES IN A FOLDERS*/
filename indata pipe 'dir "X:XXXX\*.txt" /b';

data file_list;
/*	INFILE STATEMENT FOR FILE NAMES*/
	infile indata truncover;
/*	READ THE FILE NAMES FROM DIRECTORY*/
	input fname $100.;
	call symput ('num_files',_n_);
run;


%Macro Read_data;
/*THIS IS A LOOP TO RUN THROUGH ALL FILES THAT WILL BE READ IN*/
%do j=1 %to &num_files;

/*CALL NAME OF FILE IN A LIST DEPENDING ON JTH ITERATION*/
	data _null_;
		set file_list;
		if _n_=&j.;
		call symput ('filein', fname);
	run;

/*READ IN FILE SELECTED*/
	Data d&j._detail;

	Infile "&PATHNAME.\RAWDATA\ALL\&filein." lrecl = 600 DLM = '|' dsd missover firstobs=3;

		Input
	          Eff_dt                     :                yymmdd10.
	          SA_ID                      :                $10.
	          SA_ID1                     :                $10.
	          SA_nme                     :                $105.
	          Class_ID                   :                $10.
	          Class_ID1                  :                $10.
	          Class_nme                  :                $105.
	          Trust_ID                   :                $10.
	          Trust_nme                  :                $105.
	          Net_Asset_Val              :			8.                
	          Pur_Dollar_Amt             :			8.
	          Pur_Share_Amt              :			8.
	          Sale_Dollar_Amt            :			8.
	          Sale_Share_Amt             :			8.
	          Div_Share_Amt              :			8.
	          Div_Dollar_Amt             :                	8.
		  VI_I		 	     :                $10.;

		format Eff_dt yymmdd10.;

		src_file = "&filein.";

		if Net_Asset_Val eq "." then Net_Asset_Val = 0;
	;
		drop SA_ID1 Class_ID1;

	run;

/*	CONSOLIDATE ALL DATASETS WITH RAWDATA INTO SINGLE ONE: ALL_DETAIL*/
	proc append base = all_detail data = d&j._detail force; quit;

%end;

*************Reading in files and setting them as temporary datasets*********;
%MEND Read_data;
	%Read_data;
RUN;
