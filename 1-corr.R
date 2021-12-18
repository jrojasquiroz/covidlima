library(readxl)#para leer archivo Excel
library(PerformanceAnalytics) #para los gráficos de correlación
library(corrplot)
library(Hmisc) #para obtener los p-valores
library(dplyr) #para manipular el df


#1. Importamos el Excel con toda la info
df <- read_excel("turuta/consolidado-limaycallao-distritos.xlsx")
head(df)
names(df)
#2. Para hacer las correlaciones es necesario que el df solo
#tenga las columnas con las variables (no el nombre de las unidades
#u otras cosas)
df_clean=select(df,4:10,12:14)

#3.Una vez obtenido el df necesario, utilizamos este código que, a
#mi parecer, es el que mejor resume la información.
cor_5 <- rcorr(as.matrix(df_clean)) #esta lista contiene
                 #los coeficientes, los p-valores, y el n° de
                 #observaciones
M <- cor_5$r     #aquí están los coeficiente de correlación
p_mat <- cor_5$P #aquí están los p-valores #para esto sirve Hmisc

corrplot(M, order = "hclust", 
         p.mat = p_mat, sig.level = 0.01)


#Con estas lineas guardamos el corrplot
jpeg(height=1000, width=1000, file="corrplot.jpeg", type = "cairo",
     quality=100)

col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(M, method = "color", col = col(200),  
         type = "upper",
         #order = "hclust", #Es posible añadir esto para darle
         #mas orden al grafico. Pero en este caso no me interesa tanto
         #eso, sino mas bien ver de manera directa las correlaciones
         #de mi variable de interes:TDECX10.
         addCoef.col = "black", # Add coefficient of correlation
         tl.col = "darkblue", tl.srt = 45, #Text label color and rotation
         # Combine with significance level
         p.mat = p_mat, sig.level = 0.01,  
         # hide correlation coefficient on the principal diagonal
         diag = FALSE 
)

dev.off()
#Toda la info aquí: https://rstudio-pubs-static.s3.amazonaws.com/240657_5157ff98e8204c358b2118fa69162e18.html

#De lo encontrado, veo que será necesario utilizar las
#siguientes variables en el modelo:
#Por su relación teórica: INFORMAL_PR,AUTOM_PR,MUJER_PR,
#                         ADULTOMAYOR_PR,HACIN_PROM (no tiene corr. signficativa
#                         pero si un coeficiente con sentido)
#Por su correlación:      DENS_RES,DENS_MRC

#Se excluyen DENS_EESS_SI y DENS_EESS_CI porque su coeficiente
#es positivo pese a que la teoría nos indica lo contrario:
#Ya sean los establecimientos de salud sin intermaiento o con 
#internamiento deberían ayudar a disminuir la tasa de decesos.