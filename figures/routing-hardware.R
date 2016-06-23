require(dplyr)
require(ggplot2)

source("figures/ggplot_tikz.R")

# Process the data, replacing names with those used in the thesis
d <- read.csv("data/routing-hardware-saturation.csv") %>%
    mutate(dead_links=100 * (added_dead_links/((64*6) - ((8*4)*2)))) %>%
    mutate(saturation_point=saturation_point*num_chips/1000000) %>%
    filter(dead_links<4, dead_links >= 1.0)

d$centroids <- factor(d$centroids, levels=c("3", "None"))
d$hss_links <- factor(d$hss_links, levels=c("True", "False"))

levels(d$centroids) <- c("3-Centroid Traffic", "Uniform Traffic")
levels(d$hss_links) <- c("HSS Link Fault Model", "Uniform Fault Model")

saturation_v_faults <-
    ggplot(d, aes( x=dead_links
                 , y=saturation_point
                 )) +
        geom_jitter(alpha=0.3, size=0.8, width=0.1) +
        geom_line(size=1, data=d %>% 
                  group_by(dead_links, centroids, hss_links) %>%
                  summarize(saturation_point=mean(saturation_point))) +
        expand_limits(y=0) +
        facet_grid(hss_links ~ centroids) +
        plot_theme +
        labs( x="Faulty links (\\%)"
            , y="Peak throughput (million packets per second)"
            )

render_diagram(saturation_v_faults, commandArgs(TRUE)[1])


