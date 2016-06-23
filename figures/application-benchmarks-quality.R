source("figures/application-benchmarks.R")

# Plot the goodness
goodness <- ggplot(d, aes(x=netlist, y=1/total_cost, fill=placer, group=placer)) +
    geom_bar(stat="identity", position="dodge") +
    scale_y_continuous( limits=c(0, 4)
                      , expand=c(0,0)
                      , labels=function(l) {
                          return(sprintf(paste("\\begin{tikzpicture}[anchor=east]",
                                               "  \\node [white] {2000};",
                                               "  \\node {%d};",
                                               "\\end{tikzpicture}"), l));
                        }
                      ) +
    placement_bar_theme +
    theme(axis.title.x = element_blank()) +
    theme(plot.margin=unit(c(0,0,0.1,0), "lines")) +
    labs( y="Improvement ($\\times$)"
        , fill=""
        )

render_diagram(goodness, commandArgs(TRUE)[1],
               height=2.5)

