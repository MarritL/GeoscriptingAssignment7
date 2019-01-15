# Authors: Anne-Juul Welsink and Marrit Leenstra
# 15th January 2019
# Exercise 7, Geoscripting, Wageningen University 

# Function to check which region has the highest NDVI in specified month.
# Input: 
#    NDVIdf: data.frame with monthly NDVI values per municipality
#    month: month to check which NDVI is highest
# Output:
#    munMax: municipality with the highest NDVI in given month

highestNDVI <- function(NDVIdf, month){
  munMax <- NDVIdf[which(NDVIdf[[month]] == max(NDVIdf[[month]][!is.na(NDVIdf[[month]])])),'municipality']
  return(munMax)
}