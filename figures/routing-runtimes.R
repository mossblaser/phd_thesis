require(dplyr)
require(ggplot2)

source("figures/ggplot_tikz.R")

# Process the data, replacing names with those used in the thesis
d <- read.csv("data/routing-timing-processed.csv") %>%
	mutate(router=ifelse(router=="graph_search", "FGS",
	              ifelse(router=="dor", "DOR",
	              ifelse(router=="lf", "LDFR",
	              ifelse(router=="opt", "ESPR",
	              ifelse(router=="smart", "NER",
	              router)))))) %>%
	mutate(dist=ifelse(dist=="cent3", "3-Centroid Traffic",
	            ifelse(dist=="uniform", "Uniform Traffic",
	            dist))) %>%
	mutate(fault_model=ifelse(fault_model=="uniform", "Uniform Fault Model",
	                   ifelse(fault_model=="spinn_link", "HSS Link Fault Model",
	                   fault_model)))
d$router = factor(d$router, c("FGS", "DOR", "LDFR", "ESPR", "NER"))


# Plot showing how runtime increases with number of faults for PGS
runtime_v_faults <- ggplot(d %>% filter( router=="NER"
                                       , postprocess=="DIJKSTRA"
                                       , dest==16
                                       , experiment=="baseline"
                                       , faults>=0
                                       )
                          , aes(x=factor(round(faults*100/(256*256*3), 2)))
                          ) + facet_grid(fault_model ~ dist) +
                              geom_bar(aes(y=exectime+post_exectime, fill="PGS Repair~~~~~"), stat="identity") +
                              geom_bar(aes(y=exectime, fill="Routing"), stat="identity") +
                              geom_errorbar(aes( ymin=exectime+post_exectime-post_exectime_ci
                                               , ymax=exectime+post_exectime+post_exectime_ci
                                               )) +
                              geom_errorbar(aes( ymin=exectime-exectime_ci
                                               , ymax=exectime+exectime_ci
                                               )) +
                              labs( x="Link Faults (\\%)"
                                  , y="Mean Runtime ($\\mu s$)"
                                  , fill=""
                                  ) +
                              bar_theme +
                              scale_x_discrete(labels = format_decimals(2)) +
                              scale_y_continuous(expand=c(0, 0)) +
                              geom_blank(aes(y=(exectime+post_exectime+post_exectime_ci)*1.05)) +
                              scale_fill_brewer(palette="Dark2", direction=-1)

render_diagram(runtime_v_faults, commandArgs(TRUE)[1])
