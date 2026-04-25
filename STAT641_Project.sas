/*
daily_screen_time_min = Total daily screen time
num_app_switches = Number of times the user switched apps in a day
sleep_hours	= Number of hours slept per day
notification_count = Number of notifications received
social_media_time_min = Time spent on social media platforms
focus_score = Self-reported focus score (1-10)
mood_score = Self-reported mood score (1–10)
anxiety_level =	Self-reported anxiety level (1–10)
digital_wellbeing_score	= Calculated score based on focus, sleep, and anxiety levels
*/
OPTIONS VALIDVARNAME=ANY;

PROC IMPORT OUT=health 
		DATAFILE="/home/u63946554/mental_health_digital_behavior_data.csv" DBMS=CSV 
		REPLACE;
	GETNAMES=YES;
RUN;

/*Reviewing the contents of the dataset*/
proc contents data=health;
run;

/*Descriptive statistics of dataset
Mean, median, standard deviation, and mode*/
/*proc univariate data = health;
var digital_wellbeing_score daily_screen_time_min social_media_time_min notification_count num_app_switches;
run;*/
proc means data=health mean median mode min max stddev range q1 q3 cv skewness 
		kurtosis;
	var digital_wellbeing_score daily_screen_time_min social_media_time_min 
		notification_count num_app_switches;
run;

/*Scatter plot for the variables*/
proc sgplot data=health;
	scatter x=daily_screen_time_min y=digital_wellbeing_score;
	title "Appendix A.1";
run;

proc sgplot data=health;
	scatter x=social_media_time_min y=digital_wellbeing_score;
	title "Appendix A.2";
run;

proc sgplot data=health;
	scatter x=notification_count y=digital_wellbeing_score;
	title "Appendix A.3";
run;

proc sgplot data=health;
	scatter x=num_app_switches y=digital_wellbeing_score;
	title "Appendix A.4";
run;

/*****Part B: Perform Statistical Analysis******/
/*Testing the significance of the model*/
/**which specific predictors matter, and how...**/
proc reg data=health;
	model digital_wellbeing_score=daily_screen_time_min social_media_time_min 
		notification_count num_app_switches;
	title "Appendix B.1";
	run;

	/*Calculation of confidence intervals*/
proc reg data=health;
	model digital_wellbeing_score=daily_screen_time_min social_media_time_min 
		notification_count num_app_switches/VIF clb;
	title "Appendix B.2";
	run;

	/*****Part C: Check Validity of Model*****/
	/* Test for Lack of Fit*/
proc reg data=health;
	model digital_wellbeing_score=daily_screen_time_min social_media_time_min 
		notification_count num_app_switches/lackfit;
	title "Appendix C.1";
	run;

	/*Test for Multicollinearity, Outliers, and Influential Observations*/
proc reg data=health;
	model digital_wellbeing_score=daily_screen_time_min social_media_time_min 
		notification_count num_app_switches/VIF r influence;
	output out=diag h=leverage r=resid cookd=cookd rstudent=rstudent dffits=dffits;
	title "Appendix C.2";
	run;

proc print data=diag;
run;

proc print data=diag;
	where dffits > 0.2;
	var digital_wellbeing_score daily_screen_time_min social_media_time_min 
		notification_count num_app_switches dffits;
run;

proc print data=diag;
	where cookd > 4/500;
	var digital_wellbeing_score daily_screen_time_min social_media_time_min 
		notification_count num_app_switches cookd;
	title "Appendix C.3";
run;

*DFBETAS score > 2/sqr(n) = 0.0894427191;
*DFFITS score > 2sqr(p/n) = 0.2;

Proc reg data=health plots(only)=(dfbetas dffits);
	model digital_wellbeing_score=daily_screen_time_min social_media_time_min 
		notification_count num_app_switches;
	title "Appendix C.4";
	run;

	/* Remdial Measure for Outliers and Influential Points*/
proc robustreg data=diag method=m;
	model digital_wellbeing_score=daily_screen_time_min social_media_time_min 
		notification_count num_app_switches;
	output out=diag_valid;
	title "Appendix C.5";
run;