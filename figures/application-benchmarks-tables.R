source("figures/application-benchmarks.R")

# Plot the goodness
goodness <- ggplot(d, aes(x=netlist, y=max_entries, fill=placer, group=placer)) +
    geom_bar(stat="identity", position="dodge") +
    placement_bar_theme +
    scale_y_continuous(limits=c(0, 2250), expand=c(0,0)) +
    geom_hline(yintercept=1024, color="red") +
    theme(legend.position = "none") +
    theme(axis.title.x = element_blank()) +
    theme(plot.margin=unit(c(0,0,0.1,0), "lines")) +
    labs( y="Max table entries"
        , fill=""
        )

render_diagram(goodness, commandArgs(TRUE)[1],
               height=2.0)


