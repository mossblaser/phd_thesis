source("figures/placement-scalability-fanout.R")

scalability <- ggplot(d,
       aes(x=fan_out)) +
    geom_ribbon(aes(ymax=placed_max_entries_min/manual_max_entries_min,
                    ymin=placed_max_entries_max/manual_max_entries_max,
                    fill=placer),
                alpha=0.5) +
    geom_line(aes(y=placed_max_entries/manual_max_entries, color=placer)) +
    scale_x_log10( breaks=c(1, 2, 4, 8, 16, 32, 64, 128, 256)
                 , expand=c(0,0)
                 ) +
    scale_y_continuous( labels=function(l) {
                          return(sprintf(paste("\\begin{tikzpicture}[anchor=east]",
                                               "  \\node [white] {\\SI{1}{\\minute}};",
                                               "  \\node {\\num{%0.0f}};",
                                               "\\end{tikzpicture}"), l));
                        }
                      ) +
    placement_theme +
    theme(legend.position = "none") +
    theme(plot.margin=unit(c(0,1,0,0), "lines")) +
    labs(x="Fan out",
         y="Overhead ($\\times$)",
         fill="",
         color="")

render_diagram(scalability, commandArgs(TRUE)[1],
               height=2.0)


