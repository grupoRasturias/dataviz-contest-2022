###################################################################
# R Contest III: Raúl Fernández Pérez, Oviedo
###################################################################

# We will plot the legendary final lap of the last race of 2021's Championship:

# Both Hamilton and Verstappen entered the race with the same points: 369.5

# In the last lap, after trailing behind Hamilton during all the race,
# Verstappen overtook him and won the title

library(qs)
library(stringr)
library(ggplot2)
library(data.table)
library(lubridate)
library(dplyr)
library(ggimage)
library(ggpubr)
library(png)
library(viridis)
library(gganimate)
library(av)
library(gifski)
library(magick)
library(ggnewscale)

###################################################################
# Read data
###################################################################

dir.data <- "E:/Docs/WORK/R_contest/2022_third_edition/f1dataR/"
dir.out <- "E:/Docs/WORK/R_contest/2022_third_edition/foo_contest/"
file.img <- "E:/Docs/WORK/R_contest/2022_third_edition/foo_contest/img_flag.png"

# If you set file.img <- NULL, the animation will be ploted without using a custom image

data <- lapply(setNames(2021,paste0("y",2021)),function(x){
  lapply(setNames(list.files(file.path(dir.data,x),full.names = T),gsub(".qs","",list.files(file.path(dir.data,x)))),function(y){
    qread(y)
  })
})

#######################################
# Let's choose 1 year, 1 race: 2021, Verstappen's last-second win over Hamilton at Abu Dhabi: round 22
#######################################

df <- data$y2021$telemetry_2021
df <- df[df$round == 22,]

#######################################
# Preprocess I
#######################################

# Create time variable
df$.time <- str_split_fixed(df$Date, " ", 2)[,2]

# Create time to seconds variable
df$.time.s <- period_to_seconds(hms(df$.time)) # convert time to period and then period to seconds passed

# Split by driver
df.s <- split(df, f = df$driverCode)

#######################################
# Preprocess II
#######################################

# The time variable does not have enough resolution, let's collapse distances by seconds, so that times are unique
df.s2 <- lapply(df.s,function(x){
  data.frame(
    dist = as.numeric(tapply(x$Distance, x$.time, function(y){mean(y)})),
    rpm = as.numeric(tapply(x$RPM, x$.time, function(y){mean(y)})),
    speed = as.numeric(tapply(x$Speed, x$.time, function(y){mean(y)})),
    throttle = as.numeric(tapply(x$Throttle, x$.time, function(y){mean(y)})),
    X = as.numeric(tapply(x$X, x$.time, function(y){mean(y)})),
    Y = as.numeric(tapply(x$Y, x$.time, function(y){mean(y)})),
    Z = as.numeric(tapply(x$Z, x$.time, function(y){mean(y)})),
    times = names(tapply(x$Speed, x$.time.s, function(y){mean(y)})),
    time2 = names(tapply(x$Speed, x$.time, function(y){mean(y)})),
    row.names = paste0("t",names(tapply(x$Speed, x$.time.s, function(y){mean(y)})))
  )
})

# Combine data
final <- rbindlist(df.s2, use.names = T, idcol = "driver")

#######################################
# 2D coordinates plots
#######################################

# Let's plot Max vs Hamilton race: final lap

# Set surname
final$driver[final$driver == "MAX"] <- "VER"

# Select drivers
final2 <- final[grepl("HAM|VER",final$driver),]

final2$X <- (final2$X - min(final$X))/1000
final2$Y <- (final2$Y - min(final$Y))/1000

#######################################
# We will draw the circuit (unanimate) by plotting all the covered coordinates

# Create mock DF for drawing unanimate circuit
circuit <- final2[final2$driver == "HAM",c("X","Y")] # Do NOT include time variable
# Change variable names so that these are static
circuit$X.cir <- circuit$X
circuit$Y.cir <- circuit$Y

#######################################
# Create mock DF for drawing unanimate start flag: 

# Flag coordinates are where dist == 0 for the LAST driver (mick schumacher)
flag <- final[final$dist == 0 & final$driver == "MSC", c("X","Y")] # Do NOT include time variable
# Change variable names so that these are static
flag$X.flag <- (flag$X - min(final$X)) / 1000
flag$Y.flag <- (flag$Y - min(final$Y)) / 1000 + 0.3 # move the flag a bit

#######################################
# Select only last lap: we want to see it in detail! (Plotting the full race is indistinguishable)

# Find last lap minutes (they run at 1:30 per lap):

start = "15:32:10"
end = "15:33:38"

final.lap <- final2[final2$times >= final2$times[which(final2$time2 == start)] &
                      final2$times <= final2$times[which(final2$time2 == end)],]

#######################################
# Create mock DF for drawing distance between pilots

final.lap.d <- split(final.lap,final.lap$driver)

# We only have common times
table(final.lap.d$HAM$time2 == final.lap.d$VER$time2)

# Create DF: we'll compute euclidean distance using the X,Y coordinates
disty <- data.frame(
  time2 = final.lap.d$HAM$time2,
  dist = sqrt((final.lap.d$HAM$X - final.lap.d$VER$X)^2 + (final.lap.d$HAM$Y - final.lap.d$VER$Y)^2)
)

# Add each variable for coloring: HAM leads until 15:32:36
disty$lead <- "HAM"
disty$lead[which(disty$time2 == "15:32:36"):nrow(disty)] <- "VER"

# For the rest of time, keep one point at the minimum, add noise (aesthetic purposes)
disty$dist.H <- disty$dist
disty$dist.H[disty$lead == "VER"] <- rep(min(disty$dist),length(disty$dist.H[disty$lead == "VER"])) + rnorm(length(disty$dist.H[disty$lead == "VER"]),mean = 0, sd = 0.001)

disty$dist.V <- disty$dist
disty$dist.V[disty$lead == "HAM"] <- rep(min(disty$dist),length(disty$dist.V[disty$lead == "HAM"])) + rnorm(length(disty$dist.V[disty$lead == "HAM"]),mean = 0, sd = 0.001)

#######################################
# Plot I: race track
#######################################

p <- ggplot() +
  
  # Plot circuit (inanimate)
  geom_point(data = circuit, aes(x = Y.cir, y = X.cir), # input X and Y flipped; we do this here because we are using coord_fixed() to set aspect ratio, which is incompatible with coord_flip()
             size = 0.75, color = "black", shape = 19)

# Plot flag (inanimate):If you set file.img <- NULL, the animation will be ploted without using a custom image
if(!is.null(file.img)){
  p <- p + geom_image(data = flag, aes(x = Y.flag, y = X.flag,
                                       image = file.img), asp = 2)
}else if(is.null(file.img)){
  p <- p + geom_point(data = flag, aes(x = Y.flag, y = X.flag),shape = 95, size = 8, col = "red")
}


# Re-define data to plot other variables (animated)
anim <-  p + 
  
  # Plot distances: Hamilton (150*dist so that points are bigger)
  geom_point(data = disty, aes(x = 14.85, y = 1.5, size = dist.H*150), color = "black", fill = "darkturquoise", shape = 21) +
  # Plot distances: Verstappen
  geom_point(data = disty, aes(x = 14.5, y = 1.5, size = dist.V*150), color = "black", fill = "red2", shape = 21) +
  
  # Legends and palettes
  scale_size_continuous(guide = "none") + # do not show this legend
  
  # Reset legends for new layers
  new_scale(new_aes = "size") +
  
  # Plot drivers
  geom_point(data = final.lap, aes(x = Y, y = X,
                                   fill = speed, color = driver, size = throttle),
             shape = 21, stroke = 1.5) +
  
  # Add Aesthetics
  
  # Flip map as it is usually displayed and set aspect ratio
  scale_y_reverse() +
  
  coord_fixed(ratio = 1) + # if needed, use clip = "off" to plot points outside area
  
  # Legends and palettes
  scale_size_continuous(name = "Throttle (%)") +
  scale_fill_viridis(name = "Speed (km/h)", option = "B") +
  scale_color_manual(name = "Driver", values = c(HAM = "darkturquoise", VER = "red2")) +
  
  # Add new scale with ggnewscale::
  
  # Themes
  xlab("Distance") +
  ylab("Distance") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_text(color = "black", size = 8),
        axis.title = element_text(color = "black", size = 8),
        legend.text = element_text(color = "black", size = 8),
        legend.title = element_text(color = "black", size = 8),
        plot.title = element_text(color = "black", size = 10, face = "bold"),
        plot.subtitle = element_text(color = "gray30", size = 8)) +
  
  
  # Add animation across time2 variable
  transition_states(time2,
                    transition_length = 2,
                    state_length = 1,
                    wrap = FALSE) + # o allow end_pause to work
  
  # Return current time2 in the ggtitle
  ggtitle("2021 Abu Dhabi Grand Prix",
          subtitle = "This animation shows the final lap of the legendary 2021 Abu Dhabi GP race, the last event in\nthe championship. Both Hamilton and Verstappen entered the race with 369.5 points.\nAfter trailing behind Hamilton during all the race, Verstappen overtook him in the final lap!\n\nRace time {closest_state} (dotted line marks the pit lane).\nWe use real-time telemetry data to show driver position, speed and throttle pressure. The points\non the top right represent the (euclidean) distance between drivers.") 


#######################################
# Render
#######################################

# Using gifski_renderer() because imagemagick gave problems, even when changing the cache resources via the policy.xml
# this also generates a very lightweight GIF

a1 <- animate( # this will last around xxxx seconds, because we have around xxxx frames
  anim,
  nframes = 4*nrow(final.lap),
  fps = 50, # must be factor of 100
  dev = "png",
  start_pause = 20, # stay for 20 frames on first frame
  end_pause = 20, # stay for 20 frames on last frame
  renderer = gifski_renderer(),
  height = 6, width = 6, res = 300, unit = "in"
)

# Save video output
anim_save(filename = "animation.gif", path = dir.out, animation = a1)
