library(plyr)

# This is a raw CSV export from ManageBAC, of just the GRADE 11 final marks in T4
d <- read.csv("managebac_import.csv", na.strings = c("N/A", "NA"))

# This file is from PCR, and lists sections, short codes, and IDs.
secs <- read.csv("pcr_courses.csv", stringsAsFactors = FALSE)
secs$Id <- as.character(secs$Course.Id)
# secs <- rename(secs, c("S"="Section"))
secs <- rename(secs, c("Short.Course.Name"="Short"))
secs <- secs[!is.na(secs["Section"]), c("Section", "Short", "Id")]
secs$Class.ID <- as.factor(paste(secs$Short, sprintf("%02d", secs$Section), sep = " "))
secs <- secs[,c(1, 3, 4)]

marks <- data.frame(Current.Grade = c("1", "2", "3", "4", "5", "6", "7", "A", "B", "C", "D", "E"), Mark = c(50, 65, 73, 80, 88, 93, 98, 100, 100, 100, 100, 100))

# clean up Class.ID in managebac file to reflect new naming conventions
gr11Year <- format(Sys.Date() + 365, "%Y")
gr12Year <- format(Sys.Date(), "%Y")
levels(d$Class.ID) <- gsub(gr11Year, "11", levels(d$Class.ID))
levels(d$Class.ID) <- gsub(gr12Year, "12", levels(d$Class.ID))

out <- d[!is.na(d["Current.Grade"]), c(1, 7, 12)]
out <- merge(out, secs, by="Class.ID")
out <- merge(out, marks, by="Current.Grade")
out <- out[, c(3, 4, 5, 6)]

out <- rename(out, c("Student.ID"="Student_Id", "Id"="Course_id"))
out$Marking_Period <- c(4)
out$Mark_Type_Id <- c(11)
out$Section <- sprintf("%02d", out$Section)
out <- out[,c(1, 3, 2, 5, 6, 4)]
out <- arrange(out, Course_id, Section)
out <- unique(out)
write.csv(out, "pcr_grade_import.csv", row.names=FALSE)
# Student_Id  Course_id	Section	Marking_Period	Mark_Type_Id	Mark	Gradebook_Mark	Gradebook_Letter_Mark	Current_GB_Mark	Current_GB_Letter_Mark
