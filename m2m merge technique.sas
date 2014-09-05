data file1;
input 
	account 	: $10.
	orderid		: $10.
	amount			  ;

datalines;

asd123	098	10
qwe432	763	25
qwe432	763	25
poi098	890	12
poi098	890	12
poi098	890	12
;
run;

data file2;
input 
	account 	: $10.
	orderid		: $10.
	amount			  
	something 	: $10.;

datalines;

asd123	098	10	x
qwe432	763	25	x
qwe432	763	25	x
qwe432	763	25	x
poi098	890	12	x
poi098	890	12	x
;
run;

proc sort data = file1; by account; quit;
proc sort data = file2; by account; quit;

data set1;
account = '                ';
orderid	= '                ';	
amount = .;		
something = '                ';	

	merge file1 (in=a)
		  file2 (in=b);
		  by account;
	if a and b then output set1;
run;


data set2;
	merge file1 (in=a)
		  file2 (in=b);
		  by account;
	if (a and b) or a then output set2;
run; 

proc sql noprint;
create table set3 as 
	select *
		from file1 as a left outer join file2 as b 
		on a.account = b.account;

quit;

