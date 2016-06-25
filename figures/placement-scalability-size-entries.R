source("figures/placement-scalability-size.R")

scalability <- ggplot(d,
       aes(x=width*height)) +
    geom_ribbon(aes(ymax=placed_max_entries_min/manual_max_entries_min,
                    ymin=placed_max_entries_max/manual_max_entries_max,
                    fill=placer),
                alpha=0.5) +
    geom_line(aes(y=placed_max_entries/manual_max_entries, color=placer)) +
    scale_x_log10( breaks=c(9**2, 16**2, 32**2, 64**2, 128**2, 256**2, 512**2, 1024**2)
                 , labels=function(n) {return(sprintf("\\num{%d}", n));}
                 , expand=c(0,0)
                 ) +
    scale_y_continuous( labels=function(l) {
                          return(sprintf(paste("\\begin{tikzpicture}[anchor=east]",
                                               "  \\node [white] {\\SI{17}{\\milli\\second}};",
                                               "  \\node {\\num{%0.0f}};",
                                               "\\end{tikzpicture}"), l));
                        }
                      ) +
    placement_theme +
    theme(legend.position = "none") +
    theme(plot.margin=unit(c(0,2,0,0), "lines")) +
    labs(x="Number of vertices",
         y="Overhead ($\\times$)",
         fill="",
         color="")

render_diagram(scalability, commandArgs(TRUE)[1],
               height=2.0)


