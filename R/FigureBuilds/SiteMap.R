#### MAKE A MAP ####
#10.04.2019
library(tidyverse)
library(RColorBrewer)
library(maps)

metadata <- read_excel(path = '~/Dropbox/projects/SNF Experiment/Transplant_Incline/data/overview/MetadataOverview_Gradient_Site.xlsx', 
           sheet='Site level', skip = c(2))
metadat <- data.frame(gradient = metadata[,1], site = metadata[,2], lat =  metadata[,5], long = metadata[,6], elev=metadata[4], year1=metadata[7], yearn=metadata[8])
colnames(metadat) <- c('gradient', 'site', 'lat', 'long', 'elev', 'year1', 'yearn') 
metadat <- metadat %>% group_by(gradient) %>% summarize(nSites=n(), lat=mean(as.numeric(lat)), long=mean(as.numeric(long)),
                                                        yearn=mean(yearn), year1=mean(year1), 
                                                        Elevrange=(max(elev)-min(elev)), Yearrange=yearn-year1)


world_map <- map_data("world")

#Creat a base plot with gpplot2
p <- ggplot() + coord_fixed() +
  xlab("") + ylab("")

#Add map to base plot
base_world_messy <- p + geom_polygon(data=world_map, aes(x=long, y=lat, group=group), 
                                     colour="#cdcdcd", fill="#cdcdcd") 

base_world_messy

cleanup <- 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_rect(fill = 'white', colour = 'white'), 
        axis.line = element_line(colour = "white"), legend.position="none",
        axis.ticks=element_blank(), axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.line.y = ggplot2::element_blank())

base_world <- base_world_messy + cleanup


map_data <- base_world +
  geom_point(data=metadat, 
             aes(x=as.numeric(long), y=as.numeric(lat), fill=Yearrange, size=Elevrange), 
             pch=21, alpha=I(0.7)) + 
  theme(legend.position="bottom", 
        legend.text.align = 0) + # omit plot title saying 'color'
  scale_fill_distiller(palette ="OrRd", direction = 1) +
  labs(size="Elevation (m)", fill="Year Since Established") +
  ggtitle('TransPlant Network Sites') 

map_data



