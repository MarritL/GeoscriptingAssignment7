# Authors: Anne-Juul Welsink and Marrit Leenstra
# 15th January 2019
# Exercise 7, Geoscripting, Wageningen University 

# This project maps which "municipality" in the Netherlands was the 
# greenest in January, in August on average over the year. 

# load libraries
if (!require("sp")) {
  install.packages("sp")
}

library(sp)

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
modis <- brick(path)










