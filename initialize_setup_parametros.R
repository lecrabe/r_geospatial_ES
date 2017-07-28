#############################################################a############################# 
# Installacion de paquetes necessarios
# Actualizado 2017/07/26
# remi.dannunzio@fao.org
##########################################################################################

######################## CAMBIAR EL CAMINO HASTA SU CARPETA DE TRABAJO
#setwd("/media/dannunzio/OSDisk/Users/dannunzio/Documents/R/formation_geospatiale/espanol/data/")
setwd("C:/Users/dannunzio/Documents/R/formation_geospatiale/espanol/data/")

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

## Opciones
options(stringsAsFactors=FALSE)




