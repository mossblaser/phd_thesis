# Produce statistics for the shortest path vector computing
# functions.
#
# $ Rscript build_shortest_path_vector_runtimes.R [outputfilename]

require(dplyr)

d <- read.csv("data/shortest_path_vector_runtimes.csv") %>%
  filter(!is.na(runtime)) %>%
  mutate(runtime=(runtime / ((width * height) ^ 2)) * 1000000000) %>%
  group_by(algo) %>%
  summarize(max_runtime=quantile(runtime, 0.25),
            min_runtime=quantile(runtime, 0.75),
            runtime=mean(runtime)) %>%
  mutate(error_plus=max_runtime-runtime,
         error_minus=runtime-min_runtime)

write.csv(d, commandArgs(TRUE)[1], quote=FALSE)

#require(ggplot2)
#print(ggplot(d,
#             aes(x=algo, y=runtime)) +
#      geom_bar(stat="identity") +
#      geom_errorbar(aes(ymax=max_runtime, ymin=min_runtime)) +
#      labs(x="Algorithm", y="Runtime (ns)"))
