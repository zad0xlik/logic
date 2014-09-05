DM LOG 'CLEAR' LOG;
*----------------------------------------------------------------------------------------------;
*	DATA PROCESSING FOLDER PATH																   ;
*----------------------------------------------------------------------------------------------;
%LET PATHNAME=X:XXXX;
		LIBNAME SASDATA "&PATHNAME.\SASDATA";

/*RUN A PROGRAM BEFORE AMORTIZATION LOGIC*/
%INCLUDE "&PATHNAME.\PROGRAMS\SOME PROGRAM.SAS";



/*AMORTIZATION CODE TO FIND REVENUE PERIOD BASED ON DATE MATRIX AND SEGREGATE CURRENCY AMOUNTS BETWEEN PCS AND PRODUCT*/
%macro trans_amort_tbl(in_ds, out_ds);

	data &out_ds.;
		set &in_ds.;

		%do	i = 2000 %to 2026;
		 	%do n = 1 %to 4;

				if index(upcase(LineType), 'WARR') > 0 or Order_Line_Description = 'Service during Warranty' then do;

					Q&n._&i._Product = 0;

/*					IF FISCAL_YEAR = &I. AND SUBSTR(FISCAL_QUARTER, 3, 1) = &N. THEN Q&N._&I._PCS = CURRENCYAMOUNT;*/
					if Fiscal_Year = &i. and substr(Fiscal_Quarter, 3, 1) = &n. then Q&n._&i._PCS = DollarAmount;
					else Q&n._&i._PCS = 0;				

				end;

				if index(upcase(LineType), 'WARR') = 0 and Order_Line_Description ^= 'Service during Warranty' then do;

					Q&n._&i._PCS = 0;

/*					if Fiscal_Year = &i. and substr(Fiscal_Quarter, 3, 1) = &n. then Q&n._&i._Product = CurrencyAmount;*/
					if Fiscal_Year = &i. and substr(Fiscal_Quarter, 3, 1) = &n. then Q&n._&i._Product = DollarAmount;
					else Q&n._&i._Product = 0;

				end;

			%end;
	 	%end;
	run;

	proc sort data = &out_ds.; by order; quit;	

%mend;
	%trans_amort_tbl(trans_amort_2, trans_amort_3_curr);
	%trans_amort_tbl(trans_amort_2, trans_amort_3_usd);
run;


