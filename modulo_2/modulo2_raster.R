##########################################################################################
##################  M?dulo de creaci?n de cuadr?cula, la extracci?n de informaci?n #######
##########################################################################################

# Puntos cubiertos:
# - leer un archivo de trama
# - crear una cuadr?cula de puntos
# - extraer informaci?n
# - seleccionar un subconjunto de datos
# - exportaci?n de resultados en formato de vectores
 
#############################################################a############################# 
# Actualizado 2017/07/25
# remi.dannunzio@fao.org
##########################################################################################

##########################################################################################
################## Options de base, paquets
##########################################################################################
options(stringsAsFactors=FALSE)

# Cambiar el camino
# setwd("C:/Users/dannunzio/Documents/countries/congo_brazza/formation_R/module_1/")
getwd()

library(rgdal)
library(raster)

### Leer un raster: "raster"
raster <- raster("raster/bioko_uso_suelos.tif")
str(raster)
extent(raster)

# ######### Crear un extracto : "extent" y "crop"
e    <- extent(8.5,8.6,3.2,3.6)
rast <- crop(raster,e)

######### Visualizar un raster : "plot"
plot(rast)
rast <- raster

# ######### Puntos aleatorios sobre un raster: "sampleRandom"
tmp <- sampleRandom(rast,1000,xy=TRUE)

# ######### Convertir en un data frame: "data.frame"
my_sample <- data.frame(tmp)

# ######### Cambiar nombre de columnas
names(my_sample) <- c("x_coord","y_coord","value")
str(my_sample)

# ######### Extraer latitude y longitude
x<-my_sample$x_coord
y<-my_sample$y_coord

# ######### Visualizar puntos: "plot"
plot(x,y)

# ######### Borrar grafico
dev.off()

# ######### Creer un marco vacio
plot(my_sample$x_coord,my_sample$y_coord,
     type="n",xlab="longitude",ylab="latitude")

# ######### Visualizar un raster : "rasterImage"
rasterImage(as.raster(rast),xmin(rast),ymin(rast),xmax(rast),ymax(rast))

# ######### Visualizar un raster : "plot"
class <-c(0,1,2,3,4,5)  
cols <- c("black","grey","lightgreen","darkgreen","blue","green")
plot(rast,col=cols,breaks=class)

# ######### Anadir puntos en un grafico: "points"
points(my_sample$x_coord,my_sample$y_coord,col="yellow")

# ######### Crear un identificador unico, numero de linea: "row"
my_sample$id <- row(my_sample)[,1]

head(my_sample)

# ######### Operador logico "differente de" :  "!="
list_logic <- my_sample$value != 0
head(list_logic)

# ######### Crear un base de datos
in_country <- my_sample[list_logic,]

points(in_country$x_coord,in_country$y_coord,col="grey")

# ######### Distribucion de valores por puntos : "table"
table(in_country$value)

# ######### Seleccionar un muestreo: "sample"
pts_FP <- my_sample[
                sample(my_sample[
                my_sample$value==1,]$id,5)
  ,]

# ######### Anadir puntos en el grafico
points(pts_FP$x_coord,pts_FP$y_coord,col="red",pch=19)


# ######### Convertir pixeles en puntos: "rasterToPoints"
start <- Sys.time()
rast_PP <- rasterToPoints(rast,
          fun=function(rast){rast==3})

Sys.time()-start

# ######### Convertir en data.frame 
df_pts_PP        <-  as.data.frame(rast_PP)
names(df_pts_PP) <- c("x_coord","y_coord","value")
df_pts_PP$id     <- row(df_pts_PP)[,1]

# ######### Seleccionar 50 puntos de perdidas
pts_PP<-df_pts_PP[sample(df_pts_PP$id,50),]

# ######### Visualizar estos puntos de perdidas
points(pts_PP$x_coord,pts_PP$y_coord,col="red",pch=19)

# ######### Combinar 2 juegos de datos: "rbind"
mes_points <- rbind(pts_FP,pts_PP)

# ######### Verificar distribuccion de puntos por valores
table(mes_points$value)

# ######### Convertir en un formato vector: "SpatialPointsDataFrame"
sp_df<-SpatialPointsDataFrame(
                              coords = mes_points[,c(1,2)],
                              data   = data.frame(mes_points[,c(4,3)]),
                              proj4string=CRS("+proj=longlat +datum=WGS84")
                              )

# ######### Exportar en KML
writeOGR(obj=sp_df,dsn="vector/mis_points.kml",layer="mis_points",driver = "KML")


