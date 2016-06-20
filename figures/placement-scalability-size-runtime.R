source("figures/placement-scalability-size.R")

scalability <- ggplot(d,
       aes(x=width*height)) +
    geom_ribbon(aes(ymax=runtime_min,
                    ymin=runtime_max,
                    fill=placer),
                alpha=0.5) +
    geom_line(aes(y=runtime, color=placer)) +
    scale_x_log10( breaks=c(9**2, 16**2, 32**2, 64**2, 128**2, 256**2, 512**2, 1024**2)
                 , labels=function(n) {return(sprintf("\\num{%d}", n));}
                 , expand=c(0,0)
                 ) +
    scale_y_log10( breaks=c(0.017, 1, 60, 60*60)
                 , labels=c("\\SI{17}{\\milli\\second}"
                           ,"\\SI{1}{\\second}"
                           ,"\\SI{1}{\\minute}"
                           ,"\\SI{1}{\\hour}"
                           )
                 ) +
    placement_theme +
    theme(plot.margin=unit(c(0,2,0,0), "lines")) +
    labs(x="Number of vertices",
         y="Runtime",
         fill="",
         color="")

render_diagram(scalability, commandArgs(TRUE)[1],
               height=2.5)

