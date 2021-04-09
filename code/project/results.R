library(tidyverse)
library(ggplot2)
gene <- read_delim("../inputs/NUCvsH2_generation.csv", delim = ",")
gene <- gene %>%
  group_by(scenEPR, scenCO2, scenH2) %>%
  mutate(summed =  sum(generation),
  gene_share = generation*100/summed)
ggplot(gene) +
  geom_area(aes(x=scenCO2,y=gene_share, fill=tech)) +
  facet_grid(scenEPR~scenH2) +
  scale_fill_manual(values = c("darkgreen","green","steelblue","brown","wheat3","pink","darkblue","blue","yellow"))
summary <- read_delim("../inputs/NUCvsH2_summary.csv", delim = ",")
colors <- c("social cost" = "red","technical cost" = "blue")
ggplot(summary) +
  geom_line(aes(x=summary$scenCO2,y=summary$SC,color = "social cost"), size = 1.5) +
  geom_line(aes(x=summary$scenCO2,y=summary$TC,color = "technical cost"), size= 1.5)+
  facet_grid(scenEPR~scenH2) +
  ylim(20,30)+
  labs(x = "Social cost of carbon in €/tCO2", y = "Cost in bn€/year",color = "Legend")
ggplot(summary) +
  geom_line(aes(x=summary$scenCO2,y=summary$emission), size = 1.5) +
  facet_grid(scenEPR~scenH2) +
  ylim(-10,50)+
  labs(x = "Social cost of carbon in €/tCO2", y = "annual CO2 emissions in MtCO2/year")
nuc_gene <- gene %>%
  filter(tech == "Nuclear") %>%
  ungroup() %>%
  summarise(scenCO2, scenH2, scenEPR, generation, H2gene)
cor(nuc_gene$generation, nuc_gene$H2gene, method = c("pearson"))
