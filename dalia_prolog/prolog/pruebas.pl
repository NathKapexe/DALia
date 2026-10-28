:- encoding(utf8).
:- use_module(library(plunit)).
:- consult(dalia).

% Mismos escenarios que las pruebas del motor en Dart, con la base real.

cerca(A, B) :- abs(A - B) < 1.0e-9.

:- begin_tests(dalia).

test(sin_foto_usa_solo_contexto) :-
    limpiar,
    reportar(suelo(waterlogged)),
    reportar(sintoma(wilting)),
    ranking([P-overwatering|_]),
    cerca(P, 0.75),
    nivel(alto),
    \+ imagen_disponible.

test(foto_y_sintoma_dan_confianza_alta) :-
    limpiar,
    ver_en_foto('Tomato___Septoria_leaf_spot', 0.89),
    ver_en_foto('Tomato___Bacterial_spot', 0.10),
    reportar(sintoma(spots)),
    ranking([P1-septoria_leaf_spot, _-bacterial_spot|_]),
    cerca(P1, 0.814),
    nivel(alto).

test(una_foto_sola_nunca_llega_a_alto) :-
    limpiar,
    ver_en_foto('Tomato___Late_blight', 0.99),
    ranking([P-late_blight|_]),
    cerca(P, 0.594),
    nivel(medio).

test(sin_sintomas_claros_gana_si_el_usuario_no_marca_nada) :-
    limpiar,
    ver_en_foto('Tomato___healthy', 0.6),
    ver_en_foto('Tomato___Late_blight', 0.3),
    ranking([_-no_clear_symptoms|_]).

test(sin_sintomas_claros_se_atenua_si_el_usuario_marca_un_sintoma) :-
    limpiar,
    ver_en_foto('Tomato___healthy', 0.6),
    ver_en_foto('Tomato___Late_blight', 0.3),
    reportar(sintoma(spots)),
    ranking([P1-late_blight|_]),
    cerca(P1, 0.38),
    puntaje(no_clear_symptoms, P2),
    cerca(P2, 0.18),
    nivel(medio).

test(sin_datos_no_hay_causas_y_el_nivel_es_bajo) :-
    limpiar,
    ranking([]),
    nivel(bajo).

test(la_evidencia_no_repite_respuestas) :-
    limpiar,
    ver_en_foto('Tomato___Late_blight', 0.8),
    reportar(sintoma(spots)),
    setof(E, evidencia(late_blight, E), Lista),
    Lista == [contexto(sintoma(spots)), imagen('Tomato___Late_blight')].

test(las_diez_clases_del_modelo_tienen_causa) :-
    findall(E, etiqueta_modelo(_, E), Etiquetas),
    sort(Etiquetas, Unicas),
    length(Unicas, 10).

test(toda_causa_tiene_al_menos_un_paso_de_tratamiento) :-
    \+ ( causa(C, _), \+ paso(C, 1, _) ).

:- end_tests(dalia).
