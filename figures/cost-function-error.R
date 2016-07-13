require(dplyr)
require(ggplot2)
require(reshape2)
source("figures/ggplot_tikz.R")

d <- read.csv("data/cost_function_comparison.csv") %>%
	melt(id.vars=c("n_vertices", "routed"),
	     variable.name="cost_function",
	     value.name="cost") %>%
	group_by(n_vertices, cost_function) %>%
	filter(routed>0, n_vertices<= 30) %>%
	summarize( error=mean(cost-routed)
	         , error_sd=sd(cost-routed)
	         )

# Re-order the cost functions
d$cost_function <- factor(d$cost_function, levels=c(
	"star",
	"sqrt_hpwl",
	"sqrt_hex_hpwl",
	"hpwl",
	"hex_hpwl"
))

# Label with LaTeX friendly full-names
levels(d$cost_function) <- c(
	"Star",
	"$\\sqrt{n}\\times$HPWL$_{xy}$",
	"$\\sqrt{n}\\times$Hexagonal HPWL~~~",
	"HPWL$_{xy}$",
	"Hexagonal HPWL"
)

# ColorBrewer 5-class Paired
cbPalette <- c(
	"#fb9a99", # Light red
	"#33a02c", # Dark green
	"#b2df8a", # Light green
	"#1f78b4", # Dark blue
	"#a6cee3"  # Light blue
)

cost_function_comparison <-
	ggplot(d, aes(x=n_vertices, y=error, color=cost_function)) +
	geom_line() +
	scale_x_continuous(expand=c(0, 0), breaks=c(2,10,20,30)) +
	scale_y_continuous(breaks=c(0), labels=c("0")) +
	labs( x="Net fan out ($n$)"
	    , y="(Linear) Error"
	    , color="Net cost function"
	    ) +
	plot_theme +
	annotate( "text"
	        , x = 19.65
	        , y = 6
	        , label = "\\footnotesize\\color{gray}$\\uparrow$ Overestimate"
	        , hjust = 0
	        ) +
	annotate( "text"
	        , x = 19.65
	        , y = -6
	        , label = "\\footnotesize\\color{gray}$\\downarrow$ Underestimate"
	        , hjust = 0
	        ) +
	theme(plot.margin=unit(c(0,0,0.2,0), "lines")) +
	theme(legend.key = element_rect(colour="white")) +
	scale_colour_manual(values=cbPalette) +
	coord_cartesian(ylim = c(-60, 60))

render_diagram(cost_function_comparison, commandArgs(TRUE)[1],
               height=2.5)

