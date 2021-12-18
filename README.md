# La distribución espacial de la Covid-19 y su relación con el uso del transporte público en Lima y Callao
## Introducción
El presente trabajo se plantea conocer si el uso del transporte público en Lima y Callao ha sido un factor que ha impactado en los contagios por
Covid-19 y, por tanto, en los decesos por esta enfermedad durante la primera ola de 2020, que tuvo lugar entre marzo y octubre. Investigaciones
hechas en otros países indican que en este modo de transporte no se han producido contagios masivos (Tirachini & Cats, 2020); sin embargo, la 
realidad del Perú y América del Sur es distinta, puesto que el transporte público se caracteriza por tener condiciones precarias de salubridad.
## Datos
Para lograr el objetivo general se propone elaborar un modelo de regresión, cuya variable a explicar sea la tasa de decesos por Covid-19 por 
cada 10,000 habitantes de cada uno de los cincuenta (50) distritos que conforman el área de estudio<sup id="a1">[1](#f1)</sup>. Para acercarnos a 
medir el uso de transporte público se ha utilizado una variable proxy, que es el porcentaje de hogares que no cuentan con automóvil, camioneta
o motocicleta por distrito. 
Además de esta, se incorporan otras variables explicativas a fin de tener un modelo que controle otras características demográficas y del entorno 
construido, como son el porcentaje de adultos mayores, de mujeres y de informalidad<sup id="a2">[2](#f2)</sup>, así como las tasas de densidad residencial, densidad de 
mercados, densidad de establecimientos de salud, y hacinamiento en la ciudad. 

Toda esta información proviene del Centro Nacional de Epidemiologia prevención y Control de Enfermedades - MINSA (2021) y de INEI (2017).
## Metodología
La metodología a seguir consiste de cinco pasos:
1.	Realizar un análisis de correlación entre las variables a trabajar, con la finalidad de conocer la manera en que están asociadas y 
prever posibles situaciones de multicolinealidad en los modelos.
2.	Realizar un análisis exploratorio de la distribución espacial de la variable a utilizar, que consiste principalmente en mapearla, 
y ver los estadísticos de la I de Moran en su versión local y global, con la finalidad de (1) estar seguros de que existe autocorrelación
espacial y (2) escoger un tipo de modelo espacial que se ajuste a las características del fenómeno a estudiar.
3.	Estimar un modelo de regresión con estimación de Mínimo Cuadrados Ordinarios, con la finalidad de confirmar la asociación entre 
las variables observada en el paso 1, encontrar posibles situaciones de multicolinealidad y elegir las variables explicativas a utilizar 
en los modelos espaciales.
4.	Estimar modelos de regresión espacial que se ajusten a las características de las variables utilizadas.
5.	Elegir un modelo final que nos permita conocer el impacto del uso de transporte público en la tasa de decesos por Covid-19.

Estos pasos se han realizado con el uso de R y QGIS.

## Resultados
A continuación, se presentan los resultados ordenados según los pasos descritos en la Metodología. Asimismo, se hace de conocimiento que la 
referencia al código utilizado sigue el formato de `nombre de R-script, línea donde empieza la tarea: línea donde termina`. Las variables 
utilizadas se presentan en la siguiente tabla.

|N°|Variable|Descripción|
|:---:|:---:|:---:|
|1|TDECX10|Tasa de decesos por Covid-19 por cada 10,000 habitantes|
|2|DENS_RES|Densidad residencial|
|3|DENS_MERC|Densidad de mercados|
|4|HACIN_PROM|Hacinamiento|
|5|DENS_EESS_SI|Densidad de establecimientos de salud sin internamiento|
|6|DENS_EESS_CI|Densidad de establecimientos de salud con internamiento|
|7|INFORMAL_PR|Informalidad (%)|
|8|TPUB_PR|Hogares que usan transporte público (%)|
|9|MUJER_PR|Mujeres (%)|
|10|ADULTOMAYOR_PR|Adultos mayores (%)|

### Correlaciones
Como se puede observar en la figura que se muestra a continuación, la tasa de decesos se correlaciona de manera significativa con las variables del entorno construido: 
densidad residencial, de mercados y de establecimientos de salud. Sin embargo, llama la atención el signo de la correlación con los 
establecimientos de salud (EESS, en adelante), ya que estas variables fueron añadidas esperando encontrar una asociación negativa con 
la tasa de decesos: a más cantidad de EESS sin internamiento (es decir, de atención primaria), se esperaría mejor condición de salud previa a la 
pandemia, y por tanto menores tasas de decesos; y a más cantidad de EESS con internamiento, mayor probabilidad de ser atendido en caso de 
enfermar gravemente, y por tanto menores tasas de decesos. Por esta razón se realiza el primer filtro sobre la base de datos y se decide 
excluir estas variables ante la falta de entendimiento de su asociación con la variable dependiente.

Asimismo, aun cuando no tienen una correlación estadísticamente significativa con la variable dependiente, se consideró conservar al 
porcentaje de informalidad, de hogares que hacen uso del transporte público, de mujeres, de adultos mayores y al hacinamiento como parte del 
estudio debido a que la teoría nos indica que deberían permitir explicar la tasa de decesos (Mena et al., 2021).
De la misma figura se puede notar que el porcentaje de adultos mayores, de mujeres y de hogares que hacen uso del transporte público tiene una 
correlación fuerte con el hacinamiento y la informalidad. El código utilizado para este proceso revisarse en `1-corr, 8:48`.

![corrplot](https://user-images.githubusercontent.com/34352451/146657096-fcf9c175-cc34-424a-8573-5f5e20ef2d86.jpeg)

### Análisis exploratorio de la distribución espacial
Como se ha mencionado en la metodología, este paso busca corroborar la existencia de autocorrelación espacial y dotar de suficiente información 
para escoger un tipo de modelo espacial que se ajuste a las características del estudio.
El punto de partida es revisar la manera en que se distribuye la variable dependiente. Lo que se puede entender de la figura que se presenta a continuación
es que los 
distritos centrales de Lima y Callao acumularon una mayor cantidad de decesos en proporción a su población total, formando un clúster en esta 
zona de la ciudad; situación que se repite un poco más hacia el sur, aunque con una menor cantidad de distritos involucrados.

![tdecx10-limaycallao](https://user-images.githubusercontent.com/34352451/146657044-d53b0598-6276-4da6-9977-2a6c8cb52c7b.jpeg)

En adelante, para corroborar la autocorrelación espacial se realiza un análisis de la I de Moran global (`3-moranVD, 2:3`). Este indicador tiene un 
valor positivo (0.47) y estadísticamente significativo (p-valor: 0.000), lo que nos confirma la autocorrelación espacial de nuestra variable 
dependiente en el área de estudio: distritos con tasas altas están cerca de distritos con tasas altas, y distritos con tasas bajas con aquellos de 
la misma característica.

Luego, se calcula la I de Moran local (`3-moranVD, 17:61`) y se identifican los cuadrantes a los que pertenece cada distrito, lo que se puede 
observar en la siguiente figura.

![LISA-limaycallao](https://user-images.githubusercontent.com/34352451/146657045-be4e0156-16b3-4089-b241-e82d10902d7c.jpeg)

Cabe mencionar que para estos cálculos se ha utilizado una matriz de pesos espaciales de contigüidad reina, siguiendo el ejemplo de You et al. 
(2020). También se probó con una matriz de distancias (`2-W, 21:40`; `3-moranVD, 5:6`), pero los resultados no variaron significativamente.

### Modelo con estimación de Mínimo Cuadrados Ordinarios (MCO)
Antes de realizar los modelos espaciales se ha estimado un modelo MCO con la finalidad de conocer posibles situaciones de multicolinealidad y 
entender de mejor manera cómo se asocian las variables del estudio.
En primer lugar, se estimó un modelo con las variables mencionadas en el subapartado de Correlaciones, pero este tenía problemas de 
multicolinealidad (VIF>6; `4-mco, 2:12`), por lo que finalmente se obtuvo el modelo para explicar la tasa de decesos que se presenta en la Tabla 2, 
con un R-cuadrado ajustado de 0.4666.

| |Estimado|Error Est.|t-valor|p-valor|VIF|
|:----|:----|:----|:----|:----|:----|
|(Intercept)|17.929|4.353|4.119|0.000153| |
|TPUB_PR|89.739|14.374|-6.243|0.000000|2.17|
|ADULTOMAYOR_PR|257.658|41.336|6.233|0.000000|2.17|


De este, se puede entender que, a mayor porcentaje de hogares que usan transporte público y a mayor porcentaje de adultos mayores, las tasas de 
decesos aumentaban durante la primera ola, lo cual guarda sentido con lo que desde la teoría (y la evidencia, en el caso de los adultos mayores) 
se señala. 

Sobre los residuos de este modelo se aplicó la I de Moran global, con la finalidad de conocer si, en adelante, un modelo SEM se podría ajustar a 
explicar la tasa de decesos con estas dos variables independientes. El resultado fue que no existe autocorrelación espacial en los errores, toda 
vez que el p-valor fue de 0.254 (`4-mco, 27:35`). 

Asimismo, se calculó la I de Moran de las dos variables independientes, y en ambas sí se pudo comprobar que existe autocorrelación espacial 
(`4-mco, 37:40`). Por esta razón, conociendo que existe autocorrelación espacial en las X y en la Y, se podría pensar que los modelos espaciales 
SDM (Durbin), SAR o SLX serían los adecuados para explicar desde un punto de vista espacial la tasa de decesos por Covid-19. Estos tres modelos 
se presentan en la siguiente sección.

### Modelos de regresión espacial

Como se ha descrito en la sección anterior, el siguiente paso consistió en estimar un SDM, un SAR y un SLX, debido a las características de 
nuestras variables. Los resultados muestran que ninguno de los modelos resulta de utilidad para la investigación, puesto que en los dos primeros 
casos se obtiene un parámetro de dependencia espacial (ρ) no significativo (0.74 y 0.27, respectivamente; `5-mod_esp, 1:9`), y en el tercero el 
valor de estos parámetros (θ) es de 0.16 y 0.11 para cada variable independiente (`5-mod_esp, 11:14`). Asumiendo un nivel de confianza del 95%, 
también se debería desestimar el uso del SLX.

Ante esto, se decidió estimar tres modelos adicionales: SEM, SDEM y SAC, pero como era de esperarse los parámetros de dependencia espacial (λ) 
tampoco fueron significativos (0.84, 0.49 y 0.66, respectivamente; `5-mod_esp, 16:24`).

### Elección de un modelo final


Ante la falta de significancia de los parámetros de dependencia espacial, el modelo escogido para explicar la tasa de decesos en Lima y 
Callao durante la primera ola es el modelo MCO, que se ha presentado en la tabla anterior.

Para afirmar esta decisión, se calcularon los parámetros de Lagrange Multiplier y Robust Lagrange Multiplier del modelo MCO que Anselin 
(2005, p.199) recomienda revisar para decidir si utilizar un modelo espacial o mantener un MCO (`5-mod_esp, 27:35`). Los resultados se 
muestran en la siguiente tabla y confirman la decisión de escoger este modelo.

|Indicador|Valor|p-valor|
|:----|:----|:----|
|Lagrange Multiplier error|0.21|0.65|
|Lagrange Multiplier lag|1.17|0.28|
|Robust Lagrange Multiplier error|0.40|0.53|
|Robust Lagrange Multiplier lag|1.35|0.25|

## Conclusión
Por todo lo mencionado, se puede concluir que el uso del transporte público sí tuvo un impacto en los decesos por Covid-19 durante la primera 
ola en Lima y Callao.

## Limitaciones
El trabajo tiene algunas limitaciones. Por ejemplo, se pudo trabajar con los logaritmos naturales de las variables para 
normalizar su distribución y probar un posible ajuste de los parámetros de dependencia espacial en los modelos SDM, SAR o SLX. Asimismo, 
se pudo incluir otras variables que incorporen más características socioeconómicas o demográficas de la población para tener modelos más robustos.

## Notas al pie

<b id="f1">1</b> En una situación ideal se debería utilizar la tasa de contagios y no la de decesos, pero durante este periodo la mayor cantidad 
de pruebas realizadas eran las de anticuerpos, cuyos resultados no son igual de confiables que las PCR.[↩](#a1)

<b id="f2">2</b> Para la informalidad se utiliza otra variable proxy: el porcentaje de hogares sin refrigeradoras.[↩](#a2)

## Referencias
Anselin, L. (2005). Exploring Spatial Data with GeoDa: A Workbook.

Centro Nacional de Epidemiologia prevención y Control de Enfermedades - MINSA. (2021). Fallecidos por COVID-19. https://www.datosabiertos.gob.pe/dataset/fallecidos-por-covid-19-ministerio-de-salud-minsa

Instituto Nacional de Estadística e Informática (INEI). (2017). XII Censo de Población, VII de Vivienda y III de Comunidades Indígenas. http://censos2017.inei.gob.pe/pubinei/index.asp

Mena, G. E., Martinez, P. P., Mahmud, A. S., Marquet, P. A., Buckee, C. O., & Santillana, M. (2021). Socioeconomic status determines COVID-19 incidence and related mortality in Santiago, Chile. Science, 372(6545). https://doi.org/10.1126/science.abg5298

Tirachini, A., & Cats, O. (2020). COVID-19 and public transportation: Current assessment, prospects, and research needs. Journal of Public Transportation, 22(1), 1–34. https://doi.org/10.5038/2375-0901.22.1.1

You, H., Wu, X., & Guo, X. (2020). Distribution of COVID-19 Morbidity Rate in Association with Social and Economic Factors in Wuhan, China: Implications for Urban Development. International Journal of Environmental Research and Public Health, 17(10), 3417. https://doi.org/10.3390/ijerph17103417







