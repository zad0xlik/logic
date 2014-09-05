
/*SPLIT THE OUTPUT PROGRAM INTO MULTIPLE PARTS TO FIT INTO EXCEL 2000*/
/*EXPORT THE FUND EXPANSION DETAILS BASED ON THE AUDIT TEAM'S REQUEST*/

***************************************************************************************;
%macro split_ds(in_ds, tbl, out_file);

	data _null_;
		set &in_ds.;
		call symputx("ds_cnt", ceil(_n_/65000));
	run;

	%do i = 1 %to &ds_cnt.;

		data &tbl._&i.;
				set &in_ds.;
			if ((65000 * &i.) - 65000 + 1) <= _n_ <= (65000 * &i.) then output;
		run;

    PROC EXPORT DATA=&tbl._&i.
    OUTFILE=&out_file
    DBMS=EXCEL2000 REPLACE;

	%end;

%mend;
/*	%split_ds(&vOutds5., set, &vOutX2.);*/
/*	%split_ds(&vOutds5._summ, summ, &vOutX2.);*/
run;
