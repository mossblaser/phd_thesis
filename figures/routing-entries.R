require(dplyr)
require(ggplot2)

source("figures/ggplot_tikz.R")

# Process the data, replacing names with those used in the thesis
d <- read.csv("data/routing-usage-output.csv") %>%
	mutate( fault_model=ifelse(fault_model=="uniform", "Uniform Fault Model", "HSS Link Fault Model")
	      , dist=ifelse(dist=="uniform", "Uniform Traffic", "3-Centroid Traffic")
	      )


# Plot of max routing entries per chip as faults increase. Red line at 1024
# entries mark.
entries_v_faults <- ggplot(d, aes(x=factor(faults), y=max_entries)) +
                    geom_violin(scale="width") +
                    geom_hline(yintercept=1024, color="red") +
                    facet_grid(fault_model ~ dist, scales="free_y") +
                    violin_theme +
                    scale_x_discrete(labels = format_decimals(2)) +
                    labs( x="Faulty Links (\\%)"
                        , y="Max Routing Entries-per-Chip"
                        )

render_diagram(entries_v_faults, commandArgs(TRUE)[1])
