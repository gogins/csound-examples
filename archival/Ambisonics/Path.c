

/* Simple path generator for use with B-format Encoding Orchestra
   - Richard W.E. Furse 1995 (richard@muse.demon.co.uk) */

/* This simple program outputs lines of text that can be redirected into a
   Csound score for use with my B-format Encording Orchestra. It expects
   an instrument which moves a sound in a straight line between two points
   and approximates the path given with these straight lines.

   To compile this program type 'cc path.c -lm'. To run it and add its
   output to score 't.sco' type 'a.out >> t.sco'.

   Also when I say simple I MEAN simple. This is a program to develop and
   tailor to your needs. */

#include <stdio.h>
#include <math.h>

/* These macros control how much detail is written out to the Csound
   orchestra. MIN_STEP is the minimum length in time of a straight line
   segment making up part of the path, MAX_STEP is the maximum length in
   time and MAX_DISTANCE is the maximum length in space of a straight
   line segment (subject to MIN_STEP.) */
#define MIN_STEP 0.01
#define MAX_STEP 0.1
#define MAX_DISTANCE .05

#define PI 3.1415926535




/* USER AREA OF THE PROGRAM: 
   This section should be changed to make the program write out a different
   path or a path for a different instrument. */

/* The text is written out for instrument 2. For a different instrument
   number change the following: */
#define INSTRUMENT_NUMBER 2
/* Change this to alter the overall length of the path or its start time: */
#define START 0
#define LENGTH (9.35*4)
/* To change the path of the instrument over time change this function so
   that <*x,*y,*z> follows a different path as time varies: */
void function(double time,double *x,double *y,double *z)
{

#define CIRCLES 30

	double factor_through,centre_x,centre_y;

	factor_through=time/LENGTH;

	centre_x=4-8*factor_through;
	centre_y=2-4*factor_through;
	
	*x=-cos(factor_through*2*PI*CIRCLES)*1+centre_x;
	*y=sin(factor_through*2*PI*CIRCLES)*1+centre_y;
	*z=0.5;

}




/* Here are the internals of the program: */
double metric(double x1,double y1,double z1,double x2,double y2,double z2)
/* ie distance between two points */
{
	return(sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2)));
}

void write_path(double start,double end,
		double x1,double y1,double z1,
		double x2,double y2,double z2)
/* Expects the instrument to move whatever sound it is controlling from
   <p4,p5,p6> to <p7,p8,p9>. */
{
	printf("i%d %f %f\t%f %f %f\t%f %f %f\n",
		INSTRUMENT_NUMBER,
		start,end-start,
		x1,y1,z1,
		x2,y2,z2);
}

void write_section(double start,double end)
/* Print out a section of score from 'start' to 'end' using function(). */
{
	double last_time,time;
	double last_x,last_y,last_z,x,y,z;

	function(start,&last_x,&last_y,&last_z);
	last_time=0;
	
	for(time=start;time<end;time+=MIN_STEP)
	{
		function(time,&x,&y,&z);
		if (	  metric(x,y,z,last_x,last_y,last_z)>=MAX_DISTANCE
			||time-last_time>=MAX_STEP	)
		{
			write_path(last_time,time,last_x,last_y,last_z,x,y,z);
			last_x=x;
			last_y=y;
			last_z=z;
			last_time=time;
		}
	}
	
	function(end,&x,&y,&z);
	write_path(last_time,end,last_x,last_y,last_z,x,y,z);
}

int main()
{
	write_section(START,LENGTH);
	return(0);
}
