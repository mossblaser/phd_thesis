source("figures/placement-scalability-size.R")

scalability <- ggplot(d, aes(x=width*height)) +
    geom_ribbon(aes(ymax=placed_net_length_min/manual_net_length,
                    ymin=placed_net_length_max/manual_net_length,
                    fill=placer),
                alpha=0.5) +
    geom_line(aes(y=placed_net_length/manual_net_length, color=placer)) +
    scale_x_log10( breaks=c(9**2, 16**2, 32**2, 64**2, 128**2, 256**2, 512**2, 1024**2)
                 , labels=function(n) {return(sprintf("\\num{%d}", n));}
                 , expand=c(0,0)
                 ) +
    scale_y_continuous(expand=c(0,0)) +
    coord_cartesian(ylim=c(0, 5)) +
    placement_theme +
    theme(plot.margin=unit(c(0,2,0,0), "lines")) +
    labs(x="Number of vertices",
         y="Overhead ($\\times$)",
         fill="", color="") 

render_diagram(scalability, commandArgs(TRUE)[1],
               height=2.5)

