source("figures/application-benchmarks.R")

# Plot the goodness
runtime <- ggplot(d, aes(x=netlist, y=runtime, fill=placer, group=placer)) +
    geom_bar(stat="identity", position="dodge") +
    scale_y_continuous(limits=c(0, 15), expand=c(0,0)) +
    placement_bar_theme +
    labs( x="Benchmark"
        , y="Runtime (\\si{\\second})"
        , fill=""
        )

render_diagram(runtime, commandArgs(TRUE)[1],
               height=2.5)
