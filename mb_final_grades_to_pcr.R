library(gdata)
library(plyr)
library(stringr)

# The four imported spreadsheets come from ManageBAC -> Groups -> Plans -> Export Excel
# They likely need to be re-saved as .xlsx files, because they are in excel xml format
# These are where we link PA student number to IBIS personal code / session no

cls <- c("Student.ID"="factor", 
         "IBIS.Personal.Code"="character", 
         "Candidate.Session.No."="character")
dp12 <- read.xls("dp-12.xlsx", skip=3, colClasses=cls, na.strings=c("", "NA"))
dp11 <- read.xls("dp-11.xlsx", skip=3, colClasses=cls, na.strings=c("", "NA"))
cs12 <- read.xls("course-12.xlsx", skip=3, colClasses=cls, na.strings=c("", "NA"))
cs11 <- read.xls("course-11.xlsx", skip=3, colClasses=cls, na.strings=c("", "NA"))

students <- rbind(dp12, dp11, cs12, cs11)
rm(cs11, cs12, dp11, dp12)
students <- students[,c(1, 2, 3)]
students <- students[complete.cases(students), ]

# The next spreadsheet comes from ManageBAC's Report -> Export CSV.
# It is the TERM 3 grades for both grade 11 and 12 students.  Could probably be T4, 
# as we're not getting marks from it - just the enrollments

courses <- read.csv("mb-t3-grades.csv")
courses$Student.ID <- as.factor(courses$Student.ID)
courses$Class.ID <- sub(format(Sys.Date(), "%Y"), "12", courses$Class.ID)
courses$Class.ID <- sub(format(Sys.Date() + 365, "%Y"), "11", courses$Class.ID)
courses$Class.ID <- sub("IBFRS 11", "IBFRS 12", courses$Class.ID)
courses <- merge(courses, students, by="Student.ID")

# Then, the course sections from PCR

secs <- read.csv("course-sections.csv", colClasses = c("character", "character", "character"))
colnames(secs) <- c("Section", "Short", "Id")
secs$Section <- as.integer(secs$Section)
secs$Id <- as.integer(secs$Id)
secs <- secs[!is.na(secs["Section"]), c("Section", "Short", "Id")]

# remove trailing letters from course TRAX codes
secs$Short <- sub("1([12])[A-Z]", "1\\1", secs$Short)

secs$Class.ID <- as.factor(paste(secs$Short, sprintf("%02.f", secs$Section), sep = " "))
secs <- secs[,c(1, 3, 4)]

# Last spreadsheet to import is the marks csv from IBIS:

marks <- read.csv("ibis-marks.csv", skip=1, na.strings=c("", "EE", "TK"))
marks <- marks[!is.na(marks$Level),]
marks$Course.Id.Str <- as.factor(paste(word(marks$Subject), marks$Level))

# Conversion lookup table

conversions <- data.frame(Current.Grade = c("1", "2", "3", "4", "5", "6", "7", "A", "B", "C", "D", "E"), Mark = c(50, 65, 73, 80, 88, 93, 98, 100, 100, 100, 100, 100))


out <- merge(courses, secs, by="Class.ID", all.y=TRUE, all.x=TRUE)
out$Course.Id.Str <- as.factor(paste(toupper(word(out$Subject)), out$Level))
out <- rename(out, c("Student.ID"="Student_Id", "Id"="Course_id", "IBIS.Personal.Code"="Personal.code"))
out <- merge(out, marks, by=c("Personal.code", "Course.Id.Str"))
out <- merge(out, conversions, by="Current.Grade")
out$Marking_Period <- c(4)
out$Mark_Type_Id <- c(11)
out$Gradebook_Mark <- c("")
out$Gradebook_Letter_Mark <- c("")
out$Current_GB_Mark <- c("")
out$Current_GB_Letter_Mark <- c("")

out <- out[!is.na(out["Current.Grade"]), c("Student_Id", "Course_id", "Section", "Marking_Period", "Mark_Type_Id", "Mark", "Gradebook_Mark", "Gradebook_Letter_Mark", "Current_GB_Mark", "Current_GB_Letter_Mark")]
# out <- merge(out, marks, by="Current.Grade")

out <- arrange(out, Student_Id)


# out <- out[, c(1, 2, 7, 8, 9, 16, 15)]
out$Section <- sprintf("%02.f", out$Section)
write.csv(out, "pcr_grade_import.csv", row.names=FALSE)
