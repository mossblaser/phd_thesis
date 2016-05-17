# GGPlot utilities/themes for generating nice LaTeX figures.

require(ggplot2)
require(grid)
require(tools)
library(tikzDevice)

# Function which takes a plot and renders it using TikZ/LaTeX into a PDF
render_diagram <- function (plot, filename, width=5.4, height=5.4) {
	working_dir <- tempdir()
	old_wd <- getwd()
	setwd(working_dir)
	
	sink("plot.tex")
	cat("\\documentclass[12pt]{standalone}")
	cat("\\usepackage{tikz}")
	cat("\\begin{document}")
	tikz(width=width, height=height, console=TRUE)
	print(plot)
	dev.off()
	cat("\\end{document}")
	sink()
	
	system2("pdflatex", c("plot.tex"), stdout="/dev/stderr")
	
	setwd(old_wd);
	
	file.copy(paste(working_dir, "plot.pdf", sep="/"), filename, overwrite=TRUE)
	unlink(working_dir, recursive=TRUE, force=TRUE)
}

# Number formatting function, takes a number of decimal places and returns a
# function which takes numbers/number-strings and produces a string with the
# number printed with that many decimal places.
format_decimals <- function(decimals=0){
	function(x) format(as.double(x),nsmall=decimals,scientific = FALSE)
}


# Generic TeX-y theme for plots.
# Removes background and border from facet labels, uses black-and-white mode
plot_theme = theme_bw() +
             theme(axis.title.x=element_text(margin=margin(7,0,2,0))) +
             theme(axis.title.y=element_text(margin=margin(0,10,0,4))) +
             theme(strip.background = element_rect(fill=NA, linetype=0)) +
             theme(plot.margin = unit(c(0, 0, 0, 0), "lines")) +
             theme(strip.switch.pad.grid = unit(0.5, "lines")) +
             theme(text = element_text(size=11))
             theme(title = element_text(size=12))
             theme(axis.title = element_text(size=12))

# Special theme options for bar-charts
# Remove vertical grid lines on bar charts
bar_theme_with_grid = plot_theme +
                      theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1)) +
                      theme(legend.key = element_rect(linetype=0)) +
                      theme(legend.key.size = unit(1.0, "lines")) +
                      theme(legend.title = element_text(color="white")) +
                      theme(legend.margin = unit(0.1, "lines")) +
                      theme(legend.position="bottom")
bar_theme = bar_theme_with_grid +
            theme(panel.grid.major.x = element_blank()) +
            theme(panel.grid.minor.x = element_blank())

no_rotate = theme(axis.text.x=element_text(angle=0,hjust=0.5,vjust=1))

# Special theme options for violin-plots
violin_theme = plot_theme +
               theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1))
