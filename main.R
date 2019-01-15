# Authors: Anne-Juul Welsink and Marrit Leenstra
# 15th January 2019
# Exercise 7, Geoscripting, Wageningen University 

# This project maps which "municipality" in the Netherlands was the 
# greenest in January, in August on average over the year. 

# load libraries
if (!require("sp")) install.packages("sp") 
if (!require("raster")) install.packages("raster")
if (!require("dplyr")) install.packages("dplyr")
library(sp)
library(raster)
library(dplyr)

# source functions
source("R/retrieveData.R")

# download and unzip data 
retrieveData("https://raw.githubusercontent.com/GeoScripting-WUR/VectorRaster/gh-pages/data/MODIS.zip", "data")
nlMunicipality <- getData('GADM',country='NLD', level=2, path = "data")

# load data to global environment
path <- list.files(path = "data/", pattern = glob2rx('*.grd'), full.names = TRUE)
modis <- brick(path)

# transform to equal coordinate system, mask, and crop
nlMunicipalityPro <- spTransform(nlMunicipality, crs(proj4string(modis)))
maskModis <- mask(modis, nlMunicipalityPro)

# extract NDVI for each municipality
munNDVI <- extract(maskModis, nlMunicipalityPro, fun = mean, df = TRUE, na.rm = TRUE)
munNDVI$municipality <- nlMunicipality$NAME_2

# check which municipality has the max NDVI
munMaxJan <- munNDVI[which(munNDVI$January == max(munNDVI$January[!is.na(munNDVI$January)])),'municipality']
munMaxAugust <- munNDVI[which(munNDVI$August == max(munNDVI$August[!is.na(munNDVI$August)])),'municipality']
munNDVI$mean <- rowMeans(munNDVI[,2:13], na.rm = TRUE) 
munMaxYear <- munNDVI[which(munNDVI$mean == max(munNDVI$mean[!is.na(munNDVI$mean)])),'municipality']

# calculate which province has the highest NDVI
munNDVI$Province <- nlMunicipality$NAME_1
munMeanProvince <- munNDVI %>% group_by(Province) %>% summarise(meanProvince = mean(January))
munMaxProvince <- as.character(munMeanProvince[which(munMeanProvince$meanProvince == max(munMeanProvince$meanProvince)),'Province'])
nlProvincePro <- raster::aggregate(nlMunicipalityPro, by = 'NAME_1', dissolve = TRUE)

## Set graphical parameters (one row and two columns)
opar <- par(mfrow=c(1,2))

# plot province with highest NVDI
plot(nlProvincePro, lwd = 0.15, main = paste("Greenest Dutch province in January"), axes = TRUE)
plot(nlProvincePro[nlProvincePro$NAME_1 == munMaxProvince,], add = TRUE, col = 'green', lwd = 0.1)
mtext(side = 1, line = -1, "Coordinate system: Sinusoidal \n Authors: A.-J. Welsink, M. Leenstra ", adj = 1, cex = 0.4)
legend("topleft", legend = "Utrecht", col = 'green', pch = 20, cex = 0.6)

# plot municipalities with highest NDVI
nlMunicipalityPro@data <- nlMunicipalityPro@data[!is.na(nlMunicipalityPro$NAME_2),]
plot(nlMunicipalityPro, lwd = 0.1, main = paste("Greenest Dutch municipality in January, August, and year-round"), axes = TRUE)
plot(nlMunicipalityPro[nlMunicipalityPro$NAME_2 == munMaxJan,], lwd = 0.1, add = TRUE, col = 'red')
plot(nlMunicipalityPro[nlMunicipalityPro$NAME_2 == munMaxAugust,], lwd = 0.1, add = TRUE, col = 'blue')
plot(nlMunicipalityPro[nlMunicipalityPro$NAME_2 == munMaxYear,], lwd = 0.1, add = TRUE, col = 'green')
mtext(side = 1, line = -2, "Coordinate system: Sinusoidal \n Authors: A.-J. Welsink, M. Leenstra ", adj = 1, cex = 0.4)
legend("topleft", legend = c(paste("Highest NDVI January: \n", munMaxJan), paste("\n Highest NDVI August: \n", munMaxAugust), paste("\n Highest mean NDVI year-round: \n", munMaxYear)), col = c('red', 'blue', 'green'), pch = 20, cex = 0.6, bty = 'n')


