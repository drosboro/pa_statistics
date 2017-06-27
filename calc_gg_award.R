require(dplyr)

# Load data from csv file
# Sample data file format (exported from Excel report as CSV):
#   student id,student first name,student last name,year grad,bc trax course code,bc trax course level,final mark,credits per semester
#   1001,John,Doe,2015,DFT,11,87,2

csv_data <- read.csv("gg_data.csv", as.is=TRUE, na.strings=c("RM", "TS", "SG", ""))
csv_data$final.mark <- as.numeric(csv_data$final.mark)

name_lookup <- function(id, df=csv_data) {
  name_data <- df[df$student.id==id, c("student.first.name", "student.last.name")]
  return(paste(name_data[1,] , collapse=" "))
}

csv_data <- csv_data[complete.cases(csv_data),]
by_id <- group_by(csv_data, student.id)
results <- summarise(by_id, av=mean(final.mark))
results$name <- sapply(results$student.id, name_lookup)
results <- arrange(results, desc(av))

write.csv(results, "gg_results.csv", row.names=FALSE)
