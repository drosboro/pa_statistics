library(xlsx)
library(plyr)

ex_raw <- read.xlsx("excused_absence.xls", 1)
un_raw <- read.xlsx("unexcused_absence.xls", 1)
el_raw <- read.xlsx("excused_late.xls", 1)
ul_raw <- read.xlsx("unexcused_late.xls", 1)

ex_raw <- rename(ex_raw, c("count"="excused.absence.count"))
un_raw <- rename(un_raw, c("count"="unexcused.absence.count"))
el_raw <- rename(el_raw, c("count"="excused.late.count"))
ul_raw <- rename(ul_raw, c("count"="unexcused.late.count"))
# merged <- merge(ex_raw, un_raw, el_raw, ul_raw, all.x=TRUE, all.y=TRUE)

merged <- Reduce(function(x,y) merge(x, y, all=TRUE), list(ex_raw, un_raw, el_raw, ul_raw))


merged$excused.absence.div.4 <- merged$excused.absence.count / 4
merged$unexcused.absence.div.4 <- merged$unexcused.absence.count / 4
merged$excused.late.div.4 <- merged$excused.late.count / 4
merged$unexcused.late.div.4 <- merged$unexcused.late.count / 4

# fill in all NAs as zeros
merged[is.na(merged)] <- 0

write.xlsx(merged, "merged.xlsx", row.names=FALSE)

