source("figures/application-benchmarks.R")

# Plot the goodness
goodness <- ggplot(d, aes(x=netlist, y=1/total_cost, fill=placer, group=placer)) +
    geom_bar(stat="identity", position="dodge") +
    scale_y_continuous(limits=c(0, 4), expand=c(0,0)) +
    placement_bar_theme +
    labs( x="Benchmark"
        , y="Improvement ($\\times$)"
        , fill=""
        )

render_diagram(goodness, commandArgs(TRUE)[1],
               height=2.5)

