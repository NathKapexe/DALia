:- encoding(utf8).

% Generado por generar_hechos.py desde tomato.json (version 0.1-borrador).
% NO editar a mano: edita el JSON y vuelve a generar este archivo.

:- discontiguous causa/2, nombre/2, resumen/2, etiqueta_modelo/2,
                 indicador/3, paso/3, precaucion/2.

% causa(Id, Categoria).            nombre(Id, Texto).      resumen(Id, Texto).
% etiqueta_modelo(Id, Etiqueta).   indicador(Id, Senal, Peso).
% paso(Id, Numero, Texto).         precaucion(Id, Texto).

causa(late_blight, disease).
nombre(late_blight, 'Tizón tardío').
resumen(late_blight, 'Hongo parecido a un moho que causa manchas grandes, oscuras y de aspecto aceitoso en hojas, tallos y frutos. Avanza rápido con humedad y temperaturas frescas.').
etiqueta_modelo(late_blight, 'Tomato___Late_blight').
indicador(late_blight, sintoma(spots), 0.5).
indicador(late_blight, sintoma(moldOrPowder), 0.3).
indicador(late_blight, sintoma(wilting), 0.2).
paso(late_blight, 1, 'Retira y desecha en una bolsa (no en la composta) las hojas o plantas muy afectadas.').
paso(late_blight, 2, 'Riega en la base y por la mañana; evita mojar las hojas.').
paso(late_blight, 3, 'Mejora la ventilación y deja espacio entre plantas.').
paso(late_blight, 4, 'Si decides usar un fungicida, elige uno autorizado para tomate en tu país y sigue la etiqueta.').
paso(late_blight, 5, 'Revisa la planta cada 2 o 3 días: puede empeorar muy rápido.').
precaucion(late_blight, 'Puede contagiar a otros tomates y a papas cercanas.').

causa(early_blight, disease).
nombre(early_blight, 'Tizón temprano').
resumen(early_blight, 'Hongo que forma manchas café con anillos concéntricos, normalmente en las hojas de abajo primero, rodeadas de un halo amarillo.').
etiqueta_modelo(early_blight, 'Tomato___Early_blight').
indicador(early_blight, sintoma(spots), 0.6).
indicador(early_blight, sintoma(yellowLeaves), 0.4).
paso(early_blight, 1, 'Quita las hojas de abajo afectadas y tira los restos lejos de la planta.').
paso(early_blight, 2, 'Cubre la tierra con paja o mantillo para evitar salpicaduras.').
paso(early_blight, 3, 'Riega en la base y evita mojar las hojas.').
paso(early_blight, 4, 'Si decides usar un fungicida, elige uno autorizado para tomate en tu país y sigue la etiqueta.').
precaucion(early_blight, 'Si el cultivo se repite en el mismo suelo, el hongo puede volver: rota cultivos cuando sea posible.').

causa(septoria_leaf_spot, disease).
nombre(septoria_leaf_spot, 'Mancha foliar por Septoria').
resumen(septoria_leaf_spot, 'Hongo que produce muchas manchas pequeñas y redondas con borde oscuro y centro claro, empezando por las hojas de abajo.').
etiqueta_modelo(septoria_leaf_spot, 'Tomato___Septoria_leaf_spot').
indicador(septoria_leaf_spot, sintoma(spots), 0.7).
indicador(septoria_leaf_spot, sintoma(yellowLeaves), 0.3).
paso(septoria_leaf_spot, 1, 'Retira las hojas de abajo afectadas.').
paso(septoria_leaf_spot, 2, 'Evita mojar las hojas al regar y no trabajes con la planta cuando esté mojada.').
paso(septoria_leaf_spot, 3, 'Cubre la tierra con mantillo para reducir salpicaduras.').
paso(septoria_leaf_spot, 4, 'Si decides usar un fungicida, elige uno autorizado para tomate en tu país y sigue la etiqueta.').
precaucion(septoria_leaf_spot, 'Los restos de hojas infectadas pueden guardar el hongo: no los dejes en la maceta.').

causa(target_spot, disease).
nombre(target_spot, 'Mancha anillada (Target spot)').
resumen(target_spot, 'Hongo que causa manchas café con anillos, parecidas al tizón temprano, en hojas y a veces en frutos.').
etiqueta_modelo(target_spot, 'Tomato___Target_Spot').
indicador(target_spot, sintoma(spots), 0.7).
indicador(target_spot, sintoma(yellowLeaves), 0.3).
paso(target_spot, 1, 'Retira las hojas afectadas y los restos caídos.').
paso(target_spot, 2, 'Mejora la ventilación y evita el exceso de humedad en las hojas.').
paso(target_spot, 3, 'Riega en la base.').
paso(target_spot, 4, 'Si decides usar un fungicida, elige uno autorizado para tomate en tu país y sigue la etiqueta.').
precaucion(target_spot, 'Se confunde fácilmente con el tizón temprano; si hay duda, consulta a un especialista.').

causa(bacterial_spot, disease).
nombre(bacterial_spot, 'Mancha bacteriana').
resumen(bacterial_spot, 'Bacteria que causa manchas pequeñas, oscuras y algo húmedas en hojas y frutos, a menudo con un halo amarillo. Se propaga con el agua que salpica.').
etiqueta_modelo(bacterial_spot, 'Tomato___Bacterial_spot').
indicador(bacterial_spot, sintoma(spots), 0.7).
indicador(bacterial_spot, sintoma(yellowLeaves), 0.3).
paso(bacterial_spot, 1, 'Quita las hojas más afectadas.').
paso(bacterial_spot, 2, 'Riega en la base; evita regadera de lluvia sobre las hojas.').
paso(bacterial_spot, 3, 'No toques las plantas cuando estén mojadas y desinfecta las herramientas.').
paso(bacterial_spot, 4, 'Evita guardar semillas de plantas enfermas.').
precaucion(bacterial_spot, 'Los productos a base de cobre pueden ayudar solo de forma limitada; úsalos según la etiqueta.').

causa(leaf_mold, disease).
nombre(leaf_mold, 'Moho de la hoja').
resumen(leaf_mold, 'Hongo que causa manchas amarillas arriba de la hoja y un moho gris verdoso por debajo. Aparece con mucha humedad y poca ventilación.').
etiqueta_modelo(leaf_mold, 'Tomato___Leaf_Mold').
indicador(leaf_mold, sintoma(moldOrPowder), 0.6).
indicador(leaf_mold, sintoma(yellowLeaves), 0.4).
paso(leaf_mold, 1, 'Mejora la ventilación y baja la humedad alrededor de la planta.').
paso(leaf_mold, 2, 'Quita las hojas afectadas.').
paso(leaf_mold, 3, 'Riega en la base, por la mañana.').
paso(leaf_mold, 4, 'Si decides usar un fungicida, elige uno autorizado para tomate en tu país y sigue la etiqueta.').
precaucion(leaf_mold, 'Es más común en invernaderos y zonas cerradas.').

causa(tomato_mosaic_virus, disease).
nombre(tomato_mosaic_virus, 'Virus del mosaico del tomate').
resumen(tomato_mosaic_virus, 'Virus que deja las hojas con zonas claras y oscuras (mosaico) y a veces deformes. No tiene cura.').
etiqueta_modelo(tomato_mosaic_virus, 'Tomato___Tomato_mosaic_virus').
indicador(tomato_mosaic_virus, sintoma(curledOrDeformed), 0.6).
indicador(tomato_mosaic_virus, sintoma(yellowLeaves), 0.4).
paso(tomato_mosaic_virus, 1, 'Retira y desecha la planta afectada para proteger a las demás.').
paso(tomato_mosaic_virus, 2, 'Lávate las manos y desinfecta las herramientas después de tocarla.').
paso(tomato_mosaic_virus, 3, 'Usa semillas y plantines de fuentes confiables.').
precaucion(tomato_mosaic_virus, 'El virus se transmite por contacto: evita tocar plantas sanas después de tocar las enfermas.').

causa(yellow_leaf_curl_virus, disease).
nombre(yellow_leaf_curl_virus, 'Virus del rizado amarillo').
resumen(yellow_leaf_curl_virus, 'Virus transmitido por mosca blanca: las hojas se enrollan hacia arriba, se ponen amarillas y la planta crece poco. No tiene cura.').
etiqueta_modelo(yellow_leaf_curl_virus, 'Tomato___Tomato_Yellow_Leaf_Curl_Virus').
indicador(yellow_leaf_curl_virus, sintoma(curledOrDeformed), 0.5).
indicador(yellow_leaf_curl_virus, sintoma(yellowLeaves), 0.3).
indicador(yellow_leaf_curl_virus, sintoma(visibleInsects), 0.2).
paso(yellow_leaf_curl_virus, 1, 'Retira la planta afectada si el daño es grande.').
paso(yellow_leaf_curl_virus, 2, 'Controla la mosca blanca (trampas amarillas pegajosas, malla fina, revisar el envés de las hojas).').
paso(yellow_leaf_curl_virus, 3, 'Evita plantar cerca de plantas ya infectadas.').
precaucion(yellow_leaf_curl_virus, 'Una planta infectada joven rara vez se recupera.').

causa(spider_mites, pest).
nombre(spider_mites, 'Arañita roja').
resumen(spider_mites, 'Ácaros diminutos que chupan la savia: punteado amarillo en las hojas y, a veces, telarañas finas por debajo. Prefieren ambientes calientes y secos.').
etiqueta_modelo(spider_mites, 'Tomato___Spider_mites Two-spotted_spider_mite').
indicador(spider_mites, sintoma(visibleInsects), 0.5).
indicador(spider_mites, sintoma(yellowLeaves), 0.3).
indicador(spider_mites, sintoma(dryTips), 0.2).
paso(spider_mites, 1, 'Limpia las hojas con agua, sobre todo por el envés.').
paso(spider_mites, 2, 'Aísla la planta si hay otras cerca.').
paso(spider_mites, 3, 'Puedes probar jabón potásico o aceite de neem, siguiendo la etiqueta.').
paso(spider_mites, 4, 'Revisa cada pocos días: se reproducen rápido.').
precaucion(spider_mites, 'No apliques productos con el sol directo ni en horas de calor fuerte.').

causa(overwatering, watering).
nombre(overwatering, 'Exceso de riego').
resumen(overwatering, 'Cuando la tierra queda siempre encharcada, las raíces no respiran y la planta se ve amarilla o decaída aunque la tierra esté mojada.').
indicador(overwatering, suelo(waterlogged), 0.5).
indicador(overwatering, sintoma(yellowLeaves), 0.25).
indicador(overwatering, sintoma(wilting), 0.25).
paso(overwatering, 1, 'Deja que la tierra se seque en la superficie antes de volver a regar.').
paso(overwatering, 2, 'Comprueba que la maceta tenga agujeros de drenaje y no dejes agua en el plato.').
paso(overwatering, 3, 'Si las raíces se ven café y blandas, trasplanta a sustrato nuevo y recorta las partes podridas.').
precaucion(overwatering, 'Es una causa muy común en macetas y se confunde con enfermedades.').

causa(underwatering, watering).
nombre(underwatering, 'Falta de riego').
resumen(underwatering, 'La planta se marchita y las puntas se secan porque no recibe suficiente agua. Suele recuperarse después de regar.').
indicador(underwatering, suelo(veryDry), 0.4).
indicador(underwatering, suelo(dry), 0.2).
indicador(underwatering, sintoma(wilting), 0.2).
indicador(underwatering, sintoma(dryTips), 0.2).
paso(underwatering, 1, 'Riega despacio hasta que salga agua por los agujeros de la maceta.').
paso(underwatering, 2, 'Crea una rutina de riego y revisa la tierra con el dedo.').
paso(underwatering, 3, 'Cubre la tierra con paja o mantillo para conservar la humedad.').
precaucion(underwatering, 'En días de mucho calor, una maceta pequeña puede secarse en pocas horas.').

causa(excess_sun, light).
nombre(excess_sun, 'Exceso de sol').
resumen(excess_sun, 'Demasiado sol directo o calor quema las hojas: manchas pálidas o secas y bordes quebradizos en las hojas más expuestas.').
indicador(excess_sun, luz(fullSun), 0.5).
indicador(excess_sun, sintoma(dryTips), 0.3).
indicador(excess_sun, sintoma(yellowLeaves), 0.2).
paso(excess_sun, 1, 'Da sombra en las horas de más sol con una malla o moviendo la maceta.').
paso(excess_sun, 2, 'Acostumbra la planta al sol de forma gradual.').
paso(excess_sun, 3, 'Mantén un riego regular.').
precaucion(excess_sun, 'Es un daño por calor o luz, no una infección: no se contagia.').

causa(low_light, light).
nombre(low_light, 'Falta de luz').
resumen(low_light, 'Con poca luz la planta se estira, las hojas se ven pálidas y florece poco.').
indicador(low_light, luz(low), 0.7).
indicador(low_light, sintoma(yellowLeaves), 0.3).
paso(low_light, 1, 'Mueve la planta a un lugar con al menos 6 horas de sol directo al día.').
paso(low_light, 2, 'Gira la maceta de vez en cuando para que reciba luz por todos lados.').
precaucion(low_light, 'Si no puedes darle más sol, considera una luz de cultivo.').

causa(nutrient_deficiency, nutrition).
nombre(nutrient_deficiency, 'Falta de nutrientes').
resumen(nutrient_deficiency, 'Hojas amarillas (sobre todo las más viejas), bordes secos o crecimiento lento pueden indicar que a la tierra le faltan nutrientes.').
indicador(nutrient_deficiency, sintoma(yellowLeaves), 0.6).
indicador(nutrient_deficiency, sintoma(dryTips), 0.3).
indicador(nutrient_deficiency, sintoma(curledOrDeformed), 0.1).
paso(nutrient_deficiency, 1, 'Abona con un fertilizante equilibrado para tomate, siguiendo la etiqueta.').
paso(nutrient_deficiency, 2, 'Renueva parte del sustrato si lleva mucho tiempo en la maceta.').
paso(nutrient_deficiency, 3, 'No te pases con el abono: demasiado también daña la planta.').
precaucion(nutrient_deficiency, 'Puede parecerse al exceso de riego; revisa primero el estado de la tierra.').

causa(no_clear_symptoms, none).
nombre(no_clear_symptoms, 'Sin síntomas claros').
resumen(no_clear_symptoms, 'En la foto no se detectan síntomas claros. Eso no garantiza que la planta esté sana.').
etiqueta_modelo(no_clear_symptoms, 'Tomato___healthy').
paso(no_clear_symptoms, 1, 'Sigue con el cuidado habitual.').
paso(no_clear_symptoms, 2, 'Toma otra foto de cerca de una hoja y revisa también el envés.').
paso(no_clear_symptoms, 3, 'Observa la planta unos días y vuelve a consultar si aparece algún cambio.').
precaucion(no_clear_symptoms, 'Una foto no sustituye la revisión directa de la planta.').
