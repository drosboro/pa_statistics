# PA Statistics

This is a collection of scripts I use to help manage student data and calculate various statistics.  They are likely of little value to anyone outside of our organization.

## Fall

`report_card_tracking.Rmd`: Tracks how anticipated grade correlate with final awarded grades for last year's grad class.

## Winter

`calc_gg_award.R`: Given last year's final marks, calculates average percentages and ranks students for Governer General Award.

## Spring

`overall_average_percentage.R`: given Semester 1 and Term 3 grades, calculates overall average percentage (GPA) for students.  Used for providing data for scholarship awards.

`mb_t4_gr11_grades_to_pcr.R`: takes course section info from PCR, and T4 grade 11 grades from ManageBAC, and prepares a CSV import file to bring Grade 11 IB grades into PCR at the end of the year.

## Summer

`mb_final_grades_to_pcr.R`: takes course section info from PCR, student data from ManageBac, and final results from IBIS, and prepares a CSV import file to bring final IB results into PCR.

`combine_absence_counts.R`: merges four separate attendance exports from PCR into a single table, and calculates per-term averages for each type of attendance record.

`analysis.Rmd`: given each year's IB stats report (downloaded as a CSV from IBIS), calculates and graphs a variety of descriptive statistics to compare this year's results to historical averages. 
