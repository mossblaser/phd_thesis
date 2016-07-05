require(dplyr)
require(ggplot2)
source("figures/ggplot_tikz.R")

d <- read.csv("data/top500_num_processors.csv") %>%
	mutate(year=year + (month/12)) %>%
	group_by(year) %>%
	summarize( p=mean(num_processors)
	         , maxp=max(num_processors)
	         , minp=min(num_processors)
	         )

processors_over_time <- ggplot(d, aes(x=year, y=p, ymin=minp, ymax=maxp)) +
	geom_ribbon(alpha = .7, fill="grey70") +
	geom_line() +
	scale_y_log10(labels=format_num,
	              breaks=c( 1
	                      , 10
	                      , 100
	                      , 1000
	                      , 10000
	                      , 100000
	                      , 1000000
	                      , 10000000
	                      )) +
	scale_x_continuous(expand=c(0, 0)) +
	labs( x="Year"
	    , y="Number of Processors"
	    ) +
	plot_theme

render_diagram(processors_over_time, commandArgs(TRUE)[1],
               height=2.5)
