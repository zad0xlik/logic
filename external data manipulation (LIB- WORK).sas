/*CHECKING FOR ALL NECESSARY TABLES THAT ARE REQUIRED FOR TESTING*/
data _null_;
	if ^(exist('Fx_revcurr_fin')) or ^(exist('Fx_rev_0305')) or ^(exist('Fx_rev_0607'))  then do;
		call symputx('msg', PUT("&PATHNAME.\PROGRAMS\CMRST.5.E.ii - FX-Rate Analysis.sas", $200.));
	end;
	else do;
		call symputx('msg', PUT("&PATHNAME.\PROGRAMS\EMPTY.sas", $200.));
	end;
run;

%include "&msg.";

/*CHECK WORK DATASETS*/
data _null_;
	w = getoption('work');
	put w=;
run;


/*USING SELECT STATEMENT/WHEN STATEMENTS WITHIN A DATA STEP*/
data func_curr_0305;
	keep order Product company currency func_curr MIN_SHIPDT MIN_INVOICE_DT Date LineType Currencyamount DollarAmount;
	set trans_amort_2;
	select(company);
		when('Amarex','CNS ECC','CNS Exalink Israel','CNS Israel','CNS Netonomy US', 'CNSI (NY)',
		'CNSI WK','CTI','KBS Software Inc (US)','Odigo Inc.') func_curr = 'USD';
		otherwise func_curr = 'Currency';
	end;

	IF '31JAN03'D < Date < '01FEB06'D THEN OUTPUT func_curr_0305;
run;

