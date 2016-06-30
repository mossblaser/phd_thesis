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

resource_v_faults <- ggplot(d, aes(x=factor(faults), y=max_resource)) +
                     geom_violin(scale="width") +
                     facet_grid(fault_model ~ dist, scales="free_y") +
                     violin_theme +
                     scale_x_discrete(labels = format_decimals(2)) +
                     expand_limits(y = 0) +
                     labs( x="Faulty Links (\\%)"
                         , y="Max Routes-per-Chip"
                         )

render_diagram(resource_v_faults, commandArgs(TRUE)[1])

