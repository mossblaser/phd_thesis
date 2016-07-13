require(dplyr)
require(ggplot2)

source("figures/ggplot_tikz.R")

# Run Python generation script
out <-
    system2("python", c("buildfig.py",
                        "-e", ".csv",
                        "-s", "python",
                        "figures/space_filling_curves_comparison.py", "{output}"),
            stdout=TRUE)
filename <- strsplit(out, "[{}]")[[1]][2]

d <- read.csv(filename) %>%
    group_by(ordering, distance) %>%
    summarize( max_cost=max(cost)
             , min_cost=min(cost)
             , cost=mean(cost)
             )

d$ordering = factor(d$ordering, c(
    "row_order",
    "alternating",
    "hilbert"
))
levels(d$ordering) <- c(
    "Row-order~~~~~~",
    "Alternating~~~~~~~",
    "Hilbert~~~~~~~"
)

distances <- ggplot(d,
                    aes( x=distance
                       , y=cost
                       , color=ordering
                       , group=ordering
                       )) +
             geom_line() +
             scale_x_continuous(limits=c(NA, 512), expand=c(0,0)) +
             scale_y_continuous(limits=c(0, 35), expand=c(0,0)) +
             plot_theme +
             theme(legend.position="top") +
             theme(legend.key = element_rect(linetype=0)) +
             theme(legend.title = element_blank()) +
             theme(plot.margin=unit(c(-1,0,0,0), "lines")) +
             labs( x="1D Distance"
                 , y="Mean 2D Distance"
                 , color="Space filling curve"
                 )

render_diagram(distances, commandArgs(TRUE)[1], height=2.5)
