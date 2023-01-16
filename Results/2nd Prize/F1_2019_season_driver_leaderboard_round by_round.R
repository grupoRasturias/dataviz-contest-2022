# install.packages("qs")
# install.packages("gganimate")
# install.packages("gifski")


library(gifski)
library(qs)
library(tidyverse)
library(ggplot2)
library(gganimate)
library(ggdark)
library(directlabels)
library(RColorBrewer)
library(plotly)


setwd("R/Dataviz-III/")


results_19 <- qread("f1dataR/2019/results_2019.qs")

results_19 <- results_19 %>%
  group_by(driverId) %>%
  mutate(total_points = cumsum(points))


results_19_set <- results_19 %>%
  mutate(round = ordered(round, 1:max(as.numeric(results_19$round)))) %>%
  group_by(round) %>%
  mutate(
         rank = rank(-total_points, ties.method = "first"),
         total_points_rel = total_points/total_points[rank==1],
         total_points_lbl = paste0(" ",total_points),
         driverId = as.factor(driverId)) %>%
  group_by(driverId) %>% 
  filter(rank <=30) %>%
  ungroup()



results_19_set$driverId <- recode_factor(results_19_set$driverId, bottas = "Bottas", hamilton = "Hamilton", 
                                max_verstappen = "Verstappen", vettel = "Vettel", leclerc = "Leclerc",
                                kevin_magnussen = "Magnussen", hulkenberg = "Hulkenberg",
                                raikkonen = "Raikkonen", stroll = "Stroll", kvyat = "Kvyat",
                                gasly = "Gasly", norris = "Norris", perez = "Pérez", albon = "Albon",
                                giovinazzi = "Giovinazzi", russell = "Russell", kubica = "Kubica",
                                grosjean = "Grosjean", ricciardo = "Ricciardo", sainz = "Sainz")



staticplot <- ggplot(results_19_set, aes(rank, group = driverId,
                                       fill = as.factor(driverId), color = as.factor(driverId))) +
  geom_tile(aes(y = total_points/2,
                height = total_points,
                width = 0.9), alpha = 0.8, color = NA) +
  geom_text(aes(y = 0, label = paste(driverId, " ")), vjust = 0.2, hjust = 1, size = 8) +
  geom_text(aes(y=total_points,label = total_points_lbl, hjust=0), size = 8) +
  coord_flip(clip = "off", expand = FALSE) +
  scale_y_continuous(labels = scales::comma) +
  scale_x_reverse() +
  scale_fill_viridis_d(option = "H") +
  scale_colour_viridis_d(option = "H") +
  guides(color = FALSE, fill = FALSE) +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        panel.grid.major.x = element_line( size=.1, color="grey" ),
        panel.grid.minor.x = element_line( size=.1, color="grey" ),
        plot.title=element_text(size=25, hjust=0.5, face="bold", colour="grey", vjust=-1),
        plot.subtitle=element_text(size=18, hjust=0.5, face="italic", color="grey"),
        plot.caption =element_text(size=8, hjust=0.5, face="italic", color="grey"),
        plot.background=element_blank(),
        plot.margin = margin(2, 3, 2, 5, "cm"))



anim <- staticplot + transition_states(round, transition_length = 1, state_length = 2) +
  view_follow(fixed_x = TRUE)  +
  ease_aes('quadratic-in-out') +
  labs(title = 'Driver points after round: {closest_state}',
       subtitle  =  "F1 pilots",
       caption  = "F1 results | Data Source: f1dataR")

animate(anim, 200, fps = 20,  width = 1200, height = 1000,
        renderer = gifski_renderer("gganim.gif"))



