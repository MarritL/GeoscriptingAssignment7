# Authors: Anne-Juul Welsink and Marrit Leenstra
# 15th January 2019
# Exercise 7, Geoscripting, Wageningen University 

# This project maps which "municipality" in the Netherlands was the 
# greenest in January, in August on average over the year. 

# load libraries
if (!require("sp")) install.packages("sp")
if (!require("raster")) install.packages("raster")

#library(sp)

# source functions
source("R/retrieveData.R")

# create output folder if needed
if (!dir.exists("output")){
  dir.create("output")
}

# download and unzip data 
retrieveData("https://raw.githubusercontent.com/GeoScripting-WUR/VectorRaster/gh-pages/data/MODIS.zip", "data")
nlMunicipality <- getData('GADM',country='NLD', level=2, path = "data")

# load data to global environment
path <- list.files(path = "data/", pattern = glob2rx('*.grd'), full.names = TRUE)
modis2 <- stack(path)
modis <- brick(path)

# transform to equal coordinate systems and mask
nlMunicipalityPro <- spTransform(nlMunicipality, crs(proj4string(modis)))
maskModis <- mask(modis, nlMunicipalityPro)

nlMunicipalityPro@data <- nlMunicipalityPro@data[!is.na(nlMunicipalityPro$NAME_2),] # Remove rows with NA


munNDVI <- extract(maskModis, layer = 1, nlMunicipalityPro, fun = mean, df = TRUE)
munNDVI2 <- cbind(nlMunicipalityPro$NAME_2, munNDVI)
colnames(munNDVI2[1]) <- "municipality"

which(munNDVI == max(munNDVI[!is.na(munNDVI)]))




