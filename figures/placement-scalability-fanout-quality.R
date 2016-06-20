source("figures/placement-scalability-fanout.R")

scalability <- ggplot(d, aes(x=fan_out)) +
    geom_ribbon(aes(ymax=placed_net_length_min/manual_net_length,
                    ymin=placed_net_length_max/manual_net_length,
                    fill=placer),
                alpha=0.5) +
    geom_line(aes(y=placed_net_length/manual_net_length, color=placer)) +
    scale_x_log10( breaks=c(1, 2, 4, 8, 16, 32, 64, 128, 256)
                 , expand=c(0,0)
                 ) +
    scale_y_continuous(expand=c(0,0)) +
    coord_cartesian(ylim=c(0, 5)) +
    placement_theme +
    theme(plot.margin=unit(c(0,1,0,0), "lines")) +
    labs(x="Fan out",
         y="Overhead ($\\times$)",
         fill="", color="") 

render_diagram(scalability, commandArgs(TRUE)[1],
               height=2.5)

