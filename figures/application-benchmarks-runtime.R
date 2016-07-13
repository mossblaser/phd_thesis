source("figures/application-benchmarks.R")

# Plot the goodness
runtime <- ggplot(d, aes(x=netlist, y=runtime, fill=placer, group=placer)) +
    geom_bar(stat="identity", position="dodge") +
    scale_y_continuous( limits=c(0, 15)
                      , expand=c(0,0)
                      , labels=function(l) {
                          return(sprintf(paste("\\begin{tikzpicture}[anchor=east]",
                                               "  \\node [white] {2000};",
                                               "  \\node {%d};",
                                               "\\end{tikzpicture}"), l));
                        }
                      ) +
    placement_bar_theme +
    theme(legend.position = "none") +
    theme(plot.margin=unit(c(0.5,0,0.3,0), "lines")) +
    theme(axis.title.x = element_blank()) +
    labs( y="Runtime (\\si{\\second})"
        , fill=""
        )

render_diagram(runtime, commandArgs(TRUE)[1],
               height=2.0)
