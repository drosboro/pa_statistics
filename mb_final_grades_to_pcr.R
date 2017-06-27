library(gdata)
library(plyr)

# The four imported spreadsheets come from ManageBAC -> Groups -> Plans -> Export Excel
# They likely need to be re-saved as .xlsx files, because they are in excel xml format
# These are where we link PA student number to IBIS personal code / session no

cls <- c("Student.ID"="character", 
         "IBIS.Personal.Code"="character", 
         "Candidate.Session.No."="character")
dp12 <- read.xls("dp-12.xlsx", skip=3, colClasses=cls, na.strings=c("", "NA"))
dp11 <- read.xls("dp-11.xlsx", skip=3, colClasses=cls, na.strings=c("", "NA"))
cs12 <- read.xls("course-12.xlsx", skip=3, colClasses=cls, na.strings=c("", "NA"))
cs11 <- read.xls("course-11.xlsx", skip=3, colClasses=cls, na.strings=c("", "NA"))

students <- rbind(dp12, dp11, cs12, cs11)
students <- students[,c(1, 2, 3)]
students <- students[complete.cases(students), ]

# The next spreadsheet comes from ManageBAC's Report -> Export CSV.
# It is the TERM 3 grades for both grade 11 and 12 students.  Could probably be T4, 
# as we're not getting marks from it - just the enrollments

courses <- read.csv("mb-t3-grades.csv")

# Then, the course sections from PCR

secs <- read.csv("course-sections.csv", colClasses = c("numeric", "numeric", "numeric", "character", "factor", "factor", "character", "character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "factor"))
secs <- rename(secs, c("S"="Section"))
secs <- secs[!is.na(secs["Section"]), c("Section", "Short", "Id")]
secs$Class.ID <- as.factor(paste(secs$Short, as.character(secs$Section), sep = " "))
secs <- secs[,c(1, 3, 4)]

# Last spreadsheet to import is the marks csv from IBIS:

marks <- read.csv("ibis-marks.csv")

# Conversion lookup table

conversions <- data.frame(Current.Grade = c("1", "2", "3", "4", "5", "6", "7", "A", "B", "C", "D", "E"), Mark = c(50, 65, 73, 80, 88, 93, 98, 100, 100, 100, 100, 100))

out <- merge(courses, secs, by="Class.ID", all.y=TRUE, all.x=TRUE)
out <- out[, c(1, 2, 7, 8, 9, 16, 15)]
out <- rename(out, c("Student.ID"="Student_Id", "Id"="Course_id"))
out$Marking_Period <- c(4)
out$Mark_Type_Id <- c(11)
out$Section <- sprintf("%02d", out$Section)
write.csv(out, "pcr_grade_import.csv", row.names=FALSE)
