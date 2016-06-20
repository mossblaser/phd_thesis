source("figures/ggplot_tikz.R")

require(ggplot2)
require(dplyr)

d <- read.csv("data/placement-scalability-fanout.csv") %>%
    group_by(placer,width,height,fan_out,distance_sd) %>%
    summarize(runtime_min=min(runtime),
              runtime_max=max(runtime),
              runtime=mean(runtime),
              placed_net_length_min=min(placed_net_length),
              placed_net_length_max=max(placed_net_length),
              placed_net_length=mean(placed_net_length),
              manual_net_length_min=min(manual_net_length),
              manual_net_length_max=max(manual_net_length),
              manual_net_length=mean(manual_net_length))

d$placer <- factor(d$placer, levels=c(
    "hilbert",
    "rcm",
    "rand",
    "sa"
))
levels(d$placer) <- c(
    "Hilbert~~~~~~",
    "RCM~~~~~~",
    "Random~~~~~~",
    "Simulated Annealing~~~~~~"
)
