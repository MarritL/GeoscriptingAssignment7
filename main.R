# Authors: Anne-Juul Welsink and Marrit Leenstra
# 15th January 2019
# Exercise 7, Geoscripting, Wageningen University 

# This project maps which "municipality" in the Netherlands was the 
# greenest in January, in August on average over the year. 

# load libraries
if (!require("sp")) install.packages("sp") 
if (!require("raster")) install.packages("raster")
if (!require("dplyr")) install.package("dplyr")
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

# transform to equal coordinate system and mask
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

## Set graphical parameters (one row and two columns)
opar <- par(mfrow=c(1,2))

# plot
plot(nlMunicipalityPro)

# bonus
munNDVI$Province <- nlMunicipality$NAME_1
munMeanProvince <- munNDVI %>% group_by(Province) %>% summarise(meanProvince = mean(January))
munMaxProvince <- as.character(munMeanProvince[which(munMeanProvince$meanProvince == max(munMeanProvince$meanProvince)),'Province'])

nlProvincePro <- raster::aggregate(nlMunicipalityPro, by = 'NAME_1', dissolve = TRUE)

# plot
plot(nlProvincePro, lwd = 0.15, main = paste("Greenest Dutch province in January"), axes = TRUE)
plot(nlProvincePro[nlProvincePro$NAME_1 == munMaxProvince,], add = TRUE, col = 'green', lwd = 0.1)
mtext(side = 1, line = -1, "Coordinate system: Sinusoidal \n Authors: A.-J. Welsink, M. Leenstra ", adj = 1, cex = 0.4)
legend("topleft", legend = "Utrecht", col = 'green', pch = 20, cex = 0.6)
