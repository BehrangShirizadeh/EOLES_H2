library(tidyverse)
library(ggplot2)
investments <- read_delim("investments.csv", delim = ",")
coef <- 20
colors <- c("Annual investment in renewables" = "darkgreen","Annual Investment in fossil sources" = "brown")
fills <- c("Cumulative investment in renewables" = "green","Cumulative investment in fossil sources" = "brown" )
ggplot() +
  geom_area(aes(x=investments$Year, y=investments$RES_cum+investments$FOS_cum,fill = "Cumulative investment in renewables"), alpha = 0.3)+
  geom_area(aes(x=investments$Year, y=investments$FOS_cum, fill = "Cumulative investment in fossil sources"), alpha = 0.4)+
  geom_smooth(aes(x=investments$Year, y=investments$RES_an*coef, color = "Annual investment in renewables"),span = 1,se = FALSE, size = 2)+
  geom_smooth(aes(x=investments$Year, y=investments$FOS_an*coef,color = "Annual Investment in fossil sources"), span = 1, se = FALSE,  size = 2) +
  labs(x="Year", color = "Legend", fill = "Leg")+
  scale_color_manual(values = colors) +
  scale_fill_manual(values = fills)+
  scale_y_continuous(
    
    # Features of the first axis
    name = "Cumulative investment in bn???",
    
    # Add a second axis and specify its features
    sec.axis = sec_axis(~./coef, name="Annual investment in bn???/year")
  )+
  theme(axis.text=element_text(size=16),
        
        axis.title=element_text(size=16,face="bold"),
        legend.text =element_text(size=12) ,
        legend.position = "right")
