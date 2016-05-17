require(dplyr)
require(ggplot2)

source("figures/ggplot_tikz.R")

d <- read.csv("data/shortest_path_vector_runtimes.csv") %>%
  filter(!is.na(runtime)) %>%
  mutate(runtime=(runtime / ((width * height) ^ 2)) * 1000000000) %>%
  group_by(algo) %>%
  summarize(max_runtime=quantile(runtime, 0.25),
            min_runtime=quantile(runtime, 0.75),
            runtime=mean(runtime))
d$algo = factor(d$algo, levels=c("INSEE", "XYZ-Protocol", "IQ Method"))

runtimes <- ggplot(d, aes( x=paste("~~~", algo),
                         , y=runtime
                         , ymin=min_runtime
                         , ymax=max_runtime
                         )) +
            geom_bar(stat="identity") +
            geom_errorbar() +
            scale_y_continuous(expand=c(0, 0)) +
            geom_blank(aes(y=max_runtime*1.10)) +
            bar_theme_with_grid +
            no_rotate +
            labs(y="Runtime (ns)")+
            theme(axis.title.y=element_blank()) +
            theme(panel.grid.major.y = element_blank()) +
            theme(panel.grid.minor.y = element_blank()) +
            coord_flip()

render_diagram(runtimes, commandArgs(TRUE)[1], height=1.1)
