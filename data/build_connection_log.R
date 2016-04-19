require(dplyr)

wiring_log <- read.csv("data/wiring_log.csv")

connection_log <- wiring_log %>%
	filter(event_type == "connection_complete", duration > 1.0) %>%
	filter(duration < 140.0) %>%
	mutate(connection_type=ifelse(sc != dc, "inter-cabinet",
	                       ifelse(sf != df, "inter-frame",
	                                        "intra-frame")))

connection_log$connection_type = factor(connection_log$connection_type)

max_duration <- max(connection_log$duration)
# print("Max connection duration")
# print(max_duration)

num_bins <- 25
bins <- seq(0, max_duration, length.out=num_bins)

d <- data.frame(duration=head(bins, -1))

d$inter_cabinet <- hist(filter(connection_log, connection_type=="inter-cabinet")$duration, bins, plot=FALSE)$counts
d$inter_frame <- hist(filter(connection_log, connection_type=="inter-frame")$duration, bins, plot=FALSE)$counts
d$intra_frame <- hist(filter(connection_log, connection_type=="intra-frame")$duration, bins, plot=FALSE)$counts

write.csv(d, commandArgs(TRUE)[1], quote=FALSE)
