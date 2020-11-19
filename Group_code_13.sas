libname mylib "~/project";

/* import */
FILENAME REFFILE1 '~/project/2018_ratings_fixed.csv';
FILENAME REFFILE2 '~/project/2018-personality-data_fixed.csv';
PROC IMPORT DATAFILE=REFFILE1
	DBMS=CSV
	REPLACE
	OUT=mylib.ratings;
	GETNAMES=YES;
	DATAROW=2;
	GUESSINGROWS=5000;
RUN;
PROC IMPORT DATAFILE=REFFILE2
	DBMS=CSV
	REPLACE
	OUT=mylib.personality;
	GETNAMES=YES;
	DATAROW=2;
	GUESSINGROWS=5000;
RUN;

/* sort */
proc sort data= mylib.personality;
	by userid;
run;
proc sort data= mylib.ratings (rename=(useri=userid));
	by userid;
run;

/* proc means to dataset by user */
proc means data=mylib.ratings;
	class userid;
	var rating;
	output out=work.user;
run;
data mylib.usermeans (rename=(rating=mean_user_rating));
	set work.user;
	drop _TYPE_ _STAT_;
	if _STAT_ ~= "MEAN" then delete;
	if userid = "" then delete;
run;
data mylib.userstddev (rename=(rating=stddev_user_rating));
	set work.user;
	drop _TYPE_ _STAT_;
	if _STAT_ ~= "STD" then delete;
	if userid = "" then delete;
	var_user_rating = (rating)*(rating);
run;

/* merge data */
data mylib.main;
	merge mylib.personality mylib.usermeans mylib.userstddev;
/* 	merge mylib.ratings mylib.personality mylib.usermeans mylib.userstddev; */
	by userid;
run;

proc contents data= mylib.main;
run;
