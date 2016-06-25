source("figures/placement-scalability-fanout.R")

scalability <- ggplot(d,
       aes(x=fan_out)) +
    geom_ribbon(aes(ymax=runtime_min,
                    ymin=runtime_max,
                    fill=placer),
                alpha=0.5) +
    geom_line(aes(y=runtime, color=placer)) +
    scale_x_log10( breaks=c(1, 2, 4, 8, 16, 32, 64, 128, 256)
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
    theme(plot.margin=unit(c(0,1,0,0), "lines")) +
    theme(legend.position = "none") +
    labs(x="Fan out",
         y="Runtime",
         fill="",
         color="")

render_diagram(scalability, commandArgs(TRUE)[1],
               height=2.0)

