DM LOG 'CLEAR' LOG;

/*PROC DATASETS LIBRARY=WORK KILL NOLIST; QUIT;*/
*----------------------------------------------------------------------------------------------;
*	DATA PROCESSING FOLDER PATH																   ;
*----------------------------------------------------------------------------------------------;
%LET PATHNAME=H:\metropolitanlife\FEDOR\Comverse\Comverse_Restatement FY08\PROFILING;
		LIBNAME SASDATA "&PATHNAME.\SASDATA";

DATA _NULL_;
	CALL SYMPUT("TD",PUT(TODAY(),YYMMDD10.));
RUN;

/*PROC PRINTTO LOG = "&PATHNAME.\LOGS\CMVRST_Profiling results &TD..log";*/
/*QUIT;*/

DATA VariableList;
	LENGTH Variable $ 50; 
	INPUT Variable $ PatternCheck $ DateCheck $ Shortname $;
	DATALINES;

		AutoNumber					Y   N       AutoNumber
		Project						Y   N       Project
		CustomerPO					Y	N		CustomerPO
		Order						Y	N		Order
		Product						Y	N		Product
		DIVISION_GROUP				Y	N		DIVISION_GROUP
		DIVISION					Y	N		DIVISION
		REGION						Y	N		REGION
		Project_OG					Y	N		Project_OG
		SubProject					Y	N		SubProject
		SubProject_OG				Y	N		SubProject_OG
		Customer					Y	N		Customer
		Customer_OG					Y	N		Customer_OG
		CustomerPO_OG				Y	N		CustomerPO_OG
		Channel						Y	N		Channel
		Country						Y	N		Country
		Class						Y	N		Class
		ProdGroup					Y	N		ProdGroup
		LineBusiness				Y	N		LineBusiness
		BusinessUnits				Y	N		BusinessUnits
		ProdPlace					Y	N		ProdPlace
		Company						Y	N		Company
		InterCompany_Order			Y	N		IntrCmp_Order
		SoNum						Y	N		SoNum
		CIR							Y	N		CIR
		OpportunityNo				Y	N		OpportunityNo
		Delivery_terms				Y	N		Delivery_terms
		FOB_point					Y	N		FOB_point
		Schedule_Date				Y	Y	    Schedule_Date
		Trigger_date				Y	Y	    Trigger_date
		Risk						Y	N		Risk
		Sale_Type					Y	N		Sale_Type
		ExpectedDate				Y	Y	    ExpectedDate
		QuarterExpected				Y	N		QuarterExpected
		Certain						Y	N		Certain
		Currency					Y	N		Currency
		CurrencyAmount				Y	N		CurrencyAmount
		DollarAmount				Y	N		DollarAmount
		Invoice						Y	N		Invoice
		Invoice_Date				Y	Y	    Invoice_Date
		Invoice_Quarter				Y	N		Invoice_Quarter
		Invoice_Amount_Dollar		Y	N		Inv_Amt_Dlr
		Invoice_Amount_Currency		Y	N		Inv_Amt_Cur
		ExternalInvoice				Y	N		ExtInvoice
		ShipDate					Y	N		ShipDate
		QuarterShip					Y	N		QuarterShip
		Maintenance					Y	N		Maintenance
		DeferralNum					Y	N		DeferralNum
		ExpInstallDate				Y	Y	    ExpInstallDate
		ActualInstallDate			Y	Y	    ActInstallDate
		ExpWarrDate					Y	N		ExpWarrDate
		ActualWarrlDate				Y	Y	    ActualWarrlDate
		WarrType					Y	N		WarrType
		WarrPeriod					Y	N		WarrPeriod
		Follow_Up					Y	N		Follow_Up
		Project_Manager				Y	N		Project_Manager
		Production_Flag				Y	N		Production_Flag
		LineType					Y	N		LineType
		NewSale						Y	N		NewSale
		NewBusiness					Y	N		NewBusiness
		NewSys						Y	N		NewSys
		Port						Y	N		Port
		MBox						Y	N		MBox
		BHSM						Y	N		BHSM
		Competitor					Y	N		Competitor
		OrderStatus					Y	N		OrderStatus
		RevenueStatus				Y	N		RevenueStatus
		Revenue_Reversal			Y	N		Revn_Rev
		ACCOUNT_MANAGER				Y	N		ACCOUNT_MANAGER
		Order_Line_Description		Y	N		Ordr_Ln_Desc
		BudgetCode					Y	N		BudgetCode
		Reason						Y	N		Reason
		Note						Y	N		Note
		Booking_Amount				Y	N		Booking_Amount
		Booking_Date				Y	Y	    Booking_Date
		Booking_Quarter				Y	N		Booking_Quarter
		PlanetInstalExpectedDate	Y	Y	    PlntInstExpDt
		PlanetInstalActualDate		Y	Y	    PlntInstActDt
		PlanetWarrantyExpectedDate	Y	Y	    PlntWntyExpDt
		PlanetWarrantyActualDate	Y	Y	    PlntWntyActDt
		Cogs_Tpec					Y	N		Cogs_Tpec
		PRC_Margin					Y	N		PRC_Margin
		SST_Line_No					Y	N		SST_Line_No
		DB_Dump_File				Y	N		DB_Dump_File
		Pipeline_Excess_Records		Y	N		Pipexc_Rec
		Superseded_Records			Y	N		Sprsd_Rec
		Q1_2008_No_Ship_Date		Y	N		Q108NoShpDt

RUN;

%MACRO ProfileData (SourceFile = Cmrst);
	DATA _NULL_;
		CALL SYMPUT("NumProf",PUT(Count,8.));
		SET VariableList NOBS=Count;
		STOP;
	RUN;
		
	%DO I = 1 %TO &NumProf;
	%IF &I = 1 %THEN %DO;		
		DATA ValueStatsAll&SourceFile;
			LENGTH VariableName $50 Invaliddates $20;
			FORMAT MaxLength AverageLength MissingValues Frequency COMMA22.
				   Percentage PERCENT12.; *MinimumValue 8. MaximumValue 8.;
			STOP;
		RUN;
*** Creates a blank table where its running the append to. ***;
		DATA PatternFrequencyAll&SourceFile;
			LENGTH VariableName OriginalValue Pattern $50;
			FORMAT Frequency COMMA22. Percentage PERCENT12.;
			STOP;
		RUN;
		**THIS SAME STEP HAS TO HAPPEN FOR DATE**;
	%END;
	DATA _NULL_;
		SET VariableList;
		IF _N_ = &I;
		CALL SYMPUT("PatternCheck",PatternCheck);
		CALL SYMPUT("DateCheck",Datecheck);
		CALL SYMPUT("Variable",Variable);
		CALL SYMPUT("Shortname",TRIM(LEFT(Shortname)));
		*CALL SYMPUT("MinValCheck",MinValCheck);
	RUN;

***Identify High frequency of values within each variable***;
***Checks for missing values***;
DATA _NULL_;
***Creates the total number of variables - NumVars***;
	CALL SYMPUT("NumVars",PUT(Count,8.));
	SET &SourceFile NOBS=Count;
	STOP;
RUN;

DATA Temp;
	LENGTH VariableName $50;
	SET &SourceFile (KEEP=&Variable);  *Project_ID Case_ID Src_File);
	IF _N_ =  1 THEN MissingValues = 0;
	VariableName = "&Variable";
	LengthVariable = LENGTH(&Variable);
	IF MISSING(&Variable) THEN MissingValues = 1;
RUN;

/*MIN(&Variable) = MinimumValue Max(&Variable) = MaximumValue*/
PROC SUMMARY DATA = Temp NWAY MISSING;
	CLASS VariableName;
	VAR LengthVariable MissingValues;* &Variable;
	OUTPUT OUT = &Shortname.ValueStats (DROP=_TYPE_ RENAME=_FREQ_=Frequency)
	MAX(LengthVariable) = MaxLength MEAN(LengthVariable)=AverageLength 
	SUM(MissingValues)=MissingValues;
QUIT;


PROC SUMMARY DATA = Temp NWAY MISSING;
	CLASS &Variable VariableName;
	OUTPUT OUT = &Shortname.ValueFrequency (DROP=_TYPE_ RENAME=_FREQ_=Frequency);
QUIT;

PROC SORT DATA = &Shortname.ValueFrequency;
	BY DESCENDING Frequency; 
RUN;

/*%IF vtype(&Variable) = "N" %THEN %DO;*/
/*%END;*/

%IF &PatternCheck = Y %THEN %DO;
**Identify patterns within data - Used for dates & Ids**;
***Pulls tha value from the table and sorts it.***;
DATA &Shortname.Pattern;
	LENGTH Pattern VariableName OriginalValue $50;
	SET &SourceFile;
	VariableName = "&Variable";
	OriginalValue=&Variable;
	IF MISSING(&Variable) THEN Pattern = "NULL";
	ELSE Pattern = TRANSLATE(&Variable,"##########","1234567890");
RUN;

***Calculates the frequency coulmn for PatternFrequency table.***;
PROC SUMMARY DATA = &Shortname.Pattern NWAY MISSING;
	CLASS VariableName Pattern;
	ID OriginalValue;
	OUTPUT OUT = &Shortname.PatternFrequency (DROP=_TYPE_ RENAME=(_FREQ_=Frequency ));
QUIT;

*** Calculates Percentage for Pattern Frequency table ***;
DATA &Shortname.PatternFrequency ;
	SET &Shortname.PatternFrequency;
	Percentage = SUM(Frequency/"&NumVars");
RUN;

PROC SORT DATA = &Shortname.PatternFrequency;
	BY DESCENDING Frequency;
RUN;

*** Appending each value from SASDATA.&Shortname.PatternFrequency to the blank skeleton table ***;
*** created above -- PatternFrequencyAll&SourceFile***;
PROC APPEND BASE = PatternFrequencyAll&SourceFile DATA = &Shortname.PatternFrequency (OBS=5);
QUIT;
	
%END;
%IF &DateCheck = Y %THEN %DO;

**Identify invalid dates**;
	DATA &Shortname.InvalidDates;
		FORMAT DATECONVERT YYMMDD10.;   
		INFORMAT DATECONVERT YYMMDD10.;
		RETAIN MissingValues 0;

		SET TEMP;

		if vformat(&Variable) = 'MMDDYY8.' then DATECONVERT = &Variable;
		if vformat(&Variable) = 'DATETIME19.' then DATECONVERT = &Variable;
		if vformat(&Variable) = 'YYMMDD10.' then DATECONVERT = &Variable;
		*if vformat(&Variable) = '$10.' then DATECONVERT = (INPUT(trim(compbl(left(PUT(&Variable,10.)))), YYMMDD10.);
		*if vformat(&Variable) ^= 'MMDDYY8.' then DATECONVERT = INPUT(trim(compbl(left(&Variable))), YYMMDD10.);


		FORMAT DATECONVERT YYMMDD10.;  

		IF TRIM(LEFT(&Variable)) ^= . AND DATECONVERT ^= . THEN MissingValues = 0;
		IF TRIM(LEFT(&Variable)) = . AND DATECONVERT = . THEN MissingValues = 1;
		SumMissV + MissingValues;
		CALL SYMPUTX('SumMissV', PUT(SumMissV,10.));

		***create date constraints below***;
		IF Schedule_Date ^= . AND (Schedule_Date <= '30SEP1998'd OR Schedule_Date > '01JAN2008'd) THEN DO;
		InvalidDate = 1;
		SumInvDt + InvalidDate;
		CALL SYMPUTX('SumInvDt',PUT(SumInvDt,10.));
		END;

		ELSE DO;
		InvalidDate = 0;
		CALL SYMPUTX('SumInvDt',PUT(SumInvDt,10.));
		END;
	
	RUN; 

	***Calculates the MissingValues coulmn for ValueStats table.***;
	PROC MEANS DATA = &Shortname.InvalidDates;
		BY VariableName;
		Var MissingValues InvalidDate;
		OUTPUT OUT = &Shortname.InvalidDatesSUM sum=;
	RUN;

	DATA &Shortname.ValueStats;
		LENGTH InvalidDates $20.;

		SET &Shortname.ValueStats;
		InvalidDates = "miss: " || TRIM(LEFT(PUT(&SumMissV,10.))) || " inv: " || TRIM(LEFT(PUT(&SumInvDt,10.)));

		Percentage = SUM(TRIM(LEFT(PUT(&SumMissV,10.)))/Frequency);
	RUN;

%END;
%ELSE %DO;
	DATA &Shortname.ValueStats;
		LENGTH InvalidDates $20.;
		SET &Shortname.ValueStats;
		InvalidDates = "N/A";
		Percentage = SUM(MissingValues/Frequency);
	RUN;
%END;
	PROC APPEND BASE = ValueStatsAll&SourceFile DATA=&Shortname.ValueStats;
	QUIT;
%END;

ODS HTML FILE= "&OUTPATH\&Sourcefile._Profiling results v&TD..XLS";
TITLE "Value statistics - &Sourcefile";
PROC REPORT DATA = ValueStatsAll&SourceFile  SPLIT='*' NOWD  
    STYLE(Report)=[font=(Verdana, 10pt)] ;
RUN;

TITLE "Pattern Frequency - &Sourcefile";
PROC REPORT DATA = PatternFrequencyAll&SourceFile  SPLIT='*' NOWD  
    STYLE(Report)=[font=(Verdana, 10pt)] ;
RUN;

ODS HTML CLOSE;
OPTIONS MISSING = .;


%MEND;

%ProfileData;

run;


