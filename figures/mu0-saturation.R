require(dplyr)
require(ggplot2)

source("figures/ggplot_tikz.R")

# Process the data, replacing names with those used in the thesis
d <- read.csv("data/mu0-saturation.csv") %>% filter(placer!="sa")

d$placer <- factor(d$placer, levels=c(
    "hilbert",
    "rcm",
    "rand",
    "sa"
))
levels(d$placer) <- c(
    "Hilbert",
    "RCM",
    "Random",
    "SA"
)

dropped_packets <-
    ggplot(d, aes( x=placer
                 , y=saturation_point/1000
                 )) +
        geom_violin() +
        geom_hline(yintercept=400000/1000) +
        expand_limits(y=0) +
        plot_theme +
        theme(axis.title.y = element_blank()) +
        theme(plot.margin=unit(c(0,0,0,0.6), "lines")) +
        labs( x="Placement Algorithm"
            , y="Maximum simulation speed ($\\times$)"
            ) +
        coord_flip()

render_diagram(dropped_packets, commandArgs(TRUE)[1], height=1.5)




