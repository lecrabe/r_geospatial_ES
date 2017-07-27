###########################################################################################
################## módulo de gestión de tabla,  creación de una matriz de confusión #######
###########################################################################################

# Puntos cubiertos:
# - leer CSV, TXT
# - escribir CSV, TXT
# - crear una trama de datos
# - manejar una trama de datos
# - crear una matriz
# - llenar una matriz

#############################################################a############################# 
# actualizado 2017/07/25
# remi.dannunzio@fao.org
##########################################################################################

##########################################################################################
################## Options de base, paquets
##########################################################################################
options(stringsAsFactors=FALSE)

# cambiar el camino hasta la carpeta de trabajo
setwd("C:/Users/dannunzio/Documents/R/formation_geospatiale/espanol/data/")
getwd()

### Leer una tabla: "<-" y "read.csv"
df    <- read.csv("tablas/BIOKO_collectedData_earthaa_bioko_CE_2017_04_02_on_070417_114427_CSV.csv")
areas <- read.csv("tablas/sampling_bioko_r.csv")

### Resumen de tablas: "str"
str(df)
str(areas)

### Veer las primeras lineas: "head"
head(areas)
head(df,2)

### Nombre de columnas: "names"
names(df) 

### Extraer una columna: "$"
areas$map_area

### Clase de un objecto: "class"
class(df$map_class)

### Valores unicas de un vector: "unique"
unique(df$map_class)

### Valores unicas como factores: "levels"
levels(df$map_class)

### Changer le type d'une variable: fonction "as.XXXXX"
### NB: plusieurs fonctions imbriquées, l'indentation est automatique

(legend <- levels(as.factor(df$map_class)
                  )
 )

### Cuantos elementos de cada clase: "table"
table(df$map_class)

### Tabla pivotal
matrix <- table(df$map_class,df$ref_class)
matrix

### Addicionar: "sum"
sum(areas$map_area)

### Extraer un elemento / una linea / una columna: "[,]" 
areas[4,]
areas[areas$map_code > 20,]
areas[,"map_area"]
areas[areas$map_edited_class == "1_bosque","map_code"]
areas[areas$map_code==1,]$map_area

### Matriz de proporciones
matrix_w <- matrix

for(i in 1:length(legend)){
  for(j in 1:length(legend)){
    matrix_w[i,j] <- matrix[i,j]/
      sum(matrix[i,])*
      areas[areas$map_code==legend[i],]$map_area/
      sum(areas$map_area)
                             }
                          }

### Matriz de error standard
matrix_se<-matrix
for(i in 1:length(legend)){
  for(j in 1:length(legend)){
      matrix_se[i,j]<-
      (areas[areas$map_code==legend[i],]$map_area/sum(areas$map_area))^2*
      matrix[i,j]/
      sum(matrix[i,])*
      (1-matrix[i,j]/sum(matrix[i,]))/
      (sum(matrix[i,])-1)
  }
}

### Juego de datos de sintesis
confusion<-data.frame(matrix(nrow=length(legend),ncol=9))
names(confusion)<-c("class","code","Pa","PaW","Ua","area","area_adj","se","ci")

### cambiar cada linea de la base de datos
for(i in 1:length(legend)){
  confusion[i,]$class    <- areas[areas$map_code==legend[i],]$map_edited_class
  confusion[i,]$code     <- areas[areas$map_code==legend[i],]$map_code
  confusion[i,]$Pa       <- matrix[i,i]/sum(matrix[,i])
  confusion[i,]$Ua       <- matrix[i,i]/sum(matrix[i,])
  confusion[i,]$PaW      <- matrix_w[i,i]/sum(matrix_w[,i])
  confusion[i,]$area_adj <- sum(matrix_w[,i])*sum(areas$map_area)
  confusion[i,]$area     <- areas[areas$map_code==legend[i],]$map_area
  confusion[i,]$se       <- sqrt(sum(matrix_se[,i]))*sum(areas$map_area)
  confusion[i,]$ci       <- confusion[i,]$se*1.96
  }

### Veer resultados
confusion
matrix

### Exportar resultados CSV
write.csv(file="tablas/matrix_confusion.csv",matrix,row.names=T)

### Hacer grafico con intervalos de confianza
library(ggplot2)

confusion$ci      <- as.numeric(confusion$ci)
confusion$area_adj<- as.numeric(confusion$area_adj)

### Grafico simple 
avg.plot <- ggplot(data=confusion,aes(x=class,y=area_adj))

### Veer el grafico
avg.plot+geom_bar(stat="identity",fill="darkgrey")


### Borrar la zona grafica
dev.off()

### Grafico con intervalos de confianza
avg.plot + 
  geom_bar(stat="identity",fill="darkgrey")+
  geom_errorbar(aes(ymax=area_adj+ci, ymin=area_adj-ci))+
  theme_bw()

