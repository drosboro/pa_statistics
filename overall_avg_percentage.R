# overall_avg_percentage
#
# Author: Dave Rosborough
# Date  : June 16, 2016
#
# Description:
# Given a spreadsheet (from PCR) of term 2 FINAL and term 3 COURSE WORK marks, 
# and a CSV export of Term 3 reports from ManageBac, this script calculates an 
# overall average percentage for each student for use in determining academic 
# awards.
# 
# Input files (located in working directory):
#    1. "grades.csv" is the PCR export.
#      - required columns: student id, student * name, grade level, topic, mark, grade type, marking period
#    2. "ib_grades.csv" is the ManageBAC export.
#      - required columns: subject, level, grade level, student id, last name, first name, current grade
# Required column names are case-insensitive.

library(dplyr)

gpa_lookup <- matrix(c(0, 49, 0, 50, 59, 1.67, 60, 66, 2, 67, 72, 2.33, 73, 85, 3, 86, 100, 4), ncol=3, byrow=TRUE)
ib_to_mark <- matrix(c(7, 98, 6, 93, 5, 88, 4, 80, 3, 73, 2, 65, 1, 50), byrow=TRUE, ncol=2)
raw_data <- read.csv("grades.csv", na.strings=c("NA", "IP", "I", "RM", "SG", "TS", ""), stringsAsFactors = FALSE)
names(raw_data) <- tolower(names(raw_data))
raw_data <- raw_data %>%
  rename(student.first.name = student.nickname)

ib_data <- read.csv("ib_grades.csv", na.strings=c("NA", "N/A"), stringsAsFactors = FALSE)
names(ib_data) <- tolower(names(ib_data))
ib_data$grade.level <- as.integer(sub(ib_data$grade.level, pattern = "Grade ", replacement = ""))
ib_data$current.grade <- suppressWarnings(as.numeric(ib_data$current.grade))
ib_data$mark <- c(as.integer(0))
ib_data$topic <- c("Term 3")
ib_data$grade.type <- c("Course Work")
ib_data$course.name <- paste("IB", ib_data$subject, ib_data$level)
ib_data$marking.period <- c(as.integer(3))

dp_students <- ib_data %>%
  filter(grepl("Theory of Knowledge", course.name)) %>%
  select(student.id)

ib_data <- ib_data %>%
  filter(!is.na(current.grade))
for (i in 1:nrow(ib_data)) {
  ib_data[i, "mark"] <- as.integer(ib_to_mark[ib_to_mark[,1] == ib_data[i,]$current.grade, 2])
}
ib_data <- ib_data %>%
  rename(student.last.name = last.name, student.first.name = first.name) %>%
  select(student.id, student.last.name, student.first.name, mark, topic, grade.level, course.name, grade.type, marking.period)

raw_data <- rbind(raw_data, ib_data)

for (grade in c(9, 10, 11, 12)) {
  data <- raw_data %>%
    filter(grade.level == grade) %>%
    filter(topic == "Final" | topic == "School Final" | topic == "Term 3")

  data$student.id <- as.factor(data$student.id)
  
  data <- group_by(data, student.id)
  ids <- levels(data$student.id)
  
  out <- data.frame(id=as.numeric(ids), name=c(""), programme=c("BC"), percentage=c(0.0), stringsAsFactors = FALSE)
  
  for (id in ids) {
    s <- data %>% filter(student.id == id, !is.na(mark)) %>% ungroup()
    if (nrow(s) > 0) {
      out[out$id == id, "percentage"] <- mean(s$mark)
      out[out$id == id, "name"] <- paste(s[1,grep("student.*name", names(raw_data))], collapse=" ")
    }
    if (id %in% dp_students$student.id) {
      out[out$id == id, "programme"] <- "IBDP"
    }
  }
  
  out <- out[order(-out$percentage),]
  
  fname = paste("grade-", as.character(grade), ".csv", sep="") 
  write.table(out, file=fname, row.names=FALSE, col.names=FALSE, sep=",")
}

