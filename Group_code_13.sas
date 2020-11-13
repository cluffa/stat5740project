libname project "~/project";

/* import */
FILENAME REFFILE1 '~/project/2018_ratings_fixed.csv';
FILENAME REFFILE2 '~/project/2018-personality-data_fixed.csv';
PROC IMPORT DATAFILE=REFFILE1
	DBMS=CSV
	REPLACE
	OUT=project.ratings;
	GETNAMES=YES;
	DATAROW=2;
	GUESSINGROWS=5000;
RUN;
PROC IMPORT DATAFILE=REFFILE2
	DBMS=CSV
	REPLACE
	OUT=project.personality;
	GETNAMES=YES;
	DATAROW=2;
	GUESSINGROWS=5000;
RUN;

/* sort */
proc sort data= project.personality;
	by userid;
run;
proc sort data= project.ratings (rename=(useri=userid));
	by userid;
run;

/* proc means to dataset by user */
proc means data=project.ratings;
	class userid;
	var rating;
	output out=work.user;
run;
data project.usermeans (rename=(rating=mean_user_rating));
	set work.user;
	drop _TYPE_ _STAT_;
	if _STAT_ ~= "MEAN" then delete;
	if userid = "" then delete;
run;
data project.userstddev (rename=(rating=stddev_user_rating));
	set work.user;
	drop _TYPE_ _STAT_;
	if _STAT_ ~= "STD" then delete;
	if userid = "" then delete;
run;

/* merge data */
data project.main;
	merge project.personality project.usermeans project.userstddev;
/* 	merge project.ratings project.personality project.usermeans project.userstddev; */
	by userid;
run;

proc contents data= project.main;
run;