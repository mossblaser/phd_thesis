require(dplyr)
require(ggplot2)

source("figures/ggplot_tikz.R")

# Process the data, replacing names with those used in the thesis
num_seconds <- 4.5;
d <- read.csv("data/parse-dropped-packets.csv") %>%
  mutate(dropped_multicast=dropped_multicast / num_seconds / 1000000)

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
                 , y=dropped_multicast
                 )) +
        geom_jitter(alpha=0.3, size=0.8, width=0.3) +
        expand_limits(y=0) +
        plot_theme +
        theme(axis.title.x = element_blank()) +
        theme(axis.text.x=element_text(angle=25,hjust=1,vjust=1)) +
        theme(plot.margin=unit(c(0.2,0,0.3,0), "lines")) +
        labs( x="Placement Algorithm"
            , y="Dropped ($10^6$ packets/s)"
            )

render_diagram(dropped_packets, commandArgs(TRUE)[1], width=4.5/2, height=4.5/2)



