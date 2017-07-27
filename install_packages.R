#############################################################a############################# 
# Installacion de paquetes necessarios
# Actualizado 2017/07/26
# remi.dannunzio@fao.org
##########################################################################################

packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

## Geospatial data handling
packages(raster)
packages(rgeos)
packages(rgdal)
packages(foreign)

## Data table handling
packages(dplyr)

## Graficos
packages(ggplot2)



