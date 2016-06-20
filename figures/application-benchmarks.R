source("figures/ggplot_tikz.R")

require(ggplot2)
require(dplyr)

d <- read.csv("data/application-benchmarks.csv") %>%
    group_by(netlist, placer) %>%
    summarize( runtime=mean(runtime)
             , total_cost=mean(total_cost)
             , worst_case_chip_cost=mean(worst_case_chip_cost)
             ) %>%
    group_by(netlist) %>%
    mutate( total_cost = total_cost / sum(total_cost * (placer=="hilbert"))
          , worst_case_chip_cost = worst_case_chip_cost / sum(worst_case_chip_cost * (placer=="hilbert"))
          )

d$placer <- factor(d$placer, levels=c(
    "hilbert",
    "rcm",
    "rand",
    "sa"
))
levels(d$placer) <- c(
    "Hilbert~~~~~~",
    "RCM~~~~~~",
    "Random~~~~~~",
    "Simulated Annealing~~~~"
)

d$netlist <- factor(d$netlist, levels=c(
    "microcircuit.json",
    "sudoku.json",
    "card_sorting.json",
    "cconv_512.json",
    "parse_512.json",
    "mu0.json"
))
levels(d$netlist) <- c(
    "Microcircuit",
    "Sudoku",
    "Card Sorting",
    "CConv",
    "Parse",
    "MU0"
)

d <- filter(d, !is.na(netlist))
