:- encoding(utf8).

% =====================================================================
% Dalia: razonamiento en Prolog (tomate)
%
% Hechos (generados desde tomato.json):  hechos_tomate.pl
% Reglas (este archivo):                  como se combinan foto y respuestas
%
% Uso:
%   swipl dalia.pl
%   ?- limpiar, reportar(suelo(waterlogged)), reportar(sintoma(wilting)).
%   ?- mostrar_diagnostico.
% =====================================================================

:- consult(hechos_tomate).

% ---------------------------------------------------------------------
% Estado de la consulta (hechos que cambian en cada consulta)
%   senal(S)             el usuario reporto S: suelo(_), luz(_) o sintoma(_)
%   hallazgo(Etiqueta,C) el modelo de imagen vio Etiqueta con confianza C
%   imagen_disponible    hubo analisis de la foto (si no, solo se usa el contexto)
% ---------------------------------------------------------------------
:- dynamic senal/1, hallazgo/2, imagen_disponible/0.

% ---------------------------------------------------------------------
% Parametros (son decisiones de diseno, se pueden ajustar con datos reales)
% ---------------------------------------------------------------------
parametro(peso_imagen, 0.6).
parametro(peso_contexto, 0.4).
parametro(max_candidatos, 5).
parametro(puntaje_minimo, 0.05).
parametro(umbral_alto, 0.6).
parametro(umbral_medio, 0.35).
parametro(atenuacion_sin_sintomas, 0.5).

% ---------------------------------------------------------------------
% Cargar una consulta
% ---------------------------------------------------------------------
limpiar :-
    retractall(senal(_)),
    retractall(hallazgo(_, _)),
    retractall(imagen_disponible).

reportar(Senal) :-
    assertz(senal(Senal)).

ver_en_foto(Etiqueta, Confianza) :-
    assertz(hallazgo(Etiqueta, Confianza)),
    (   imagen_disponible
    ->  true
    ;   assertz(imagen_disponible)
    ).

% ---------------------------------------------------------------------
% REGLAS
% ---------------------------------------------------------------------

% El usuario marco al menos un sintoma.
reporta_sintomas :-
    senal(sintoma(_)), !.

% Suma de los pesos de todos los indicadores de una causa.
peso_total(Causa, Total) :-
    causa(Causa, _),
    findall(P, indicador(Causa, _, P), Pesos),
    sum_list(Pesos, Total).

% Suma de los pesos de los indicadores que el usuario si reporto.
peso_cumplido(Causa, Cumplido) :-
    causa(Causa, _),
    findall(P, ( indicador(Causa, S, P), senal(S) ), Pesos),
    sum_list(Pesos, Cumplido).

% Que parte de los indicadores de la causa coincide con las respuestas (0 a 1).
puntaje_contexto(Causa, Puntaje) :-
    peso_total(Causa, Total),
    (   Total =:= 0
    ->  Puntaje = 0.0
    ;   peso_cumplido(Causa, Cumplido),
        Puntaje is Cumplido / Total
    ).

% Mayor confianza del modelo entre las etiquetas que apuntan a la causa.
puntaje_imagen(Causa, Puntaje) :-
    causa(Causa, _),
    findall(C, ( etiqueta_modelo(Causa, E), hallazgo(E, C) ), Confianzas),
    (   Confianzas == []
    ->  Puntaje = 0.0
    ;   max_list(Confianzas, Puntaje)
    ).

% Con foto:  peso_imagen * imagen + peso_contexto * contexto
% Sin foto:  solo contexto.
% Si el usuario marco sintomas, "sin sintomas claros" pierde fuerza.
puntaje(Causa, Puntaje) :-
    puntaje_contexto(Causa, Contexto),
    (   imagen_disponible
    ->  puntaje_imagen(Causa, Imagen),
        parametro(peso_imagen, WI),
        parametro(peso_contexto, WC),
        Bruto is WI * Imagen + WC * Contexto
    ;   Bruto = Contexto
    ),
    (   causa(Causa, none), reporta_sintomas
    ->  parametro(atenuacion_sin_sintomas, F),
        Puntaje is Bruto * F
    ;   Puntaje = Bruto
    ).

% Causa probable: su puntaje llega al minimo.
% Con la variable libre, el backtracking recorre todas las causas.
causa_probable(Causa, Puntaje) :-
    puntaje(Causa, Puntaje),
    parametro(puntaje_minimo, Minimo),
    Puntaje >= Minimo.

% Las mejores causas, de mayor a menor puntaje.
ranking(Mejores) :-
    findall(P-C, causa_probable(C, P), Pares),
    sort(0, @>=, Pares, Ordenados),
    parametro(max_candidatos, Max),
    primeros(Max, Ordenados, Mejores).

% primeros(N, Lista, Prefijo): los N primeros, o toda la lista si es mas corta.
primeros(N, Lista, Prefijo) :-
    length(Prefijo, N),
    append(Prefijo, _, Lista), !.
primeros(_, Lista, Lista).

% Nivel de confianza segun la mejor causa.
nivel(Nivel) :-
    (   ranking([Mejor-_|_])
    ->  parametro(umbral_alto, Alto),
        parametro(umbral_medio, Medio),
        (   Mejor >= Alto  -> Nivel = alto
        ;   Mejor >= Medio -> Nivel = medio
        ;   Nivel = bajo
        )
    ;   Nivel = bajo
    ).

% Por que aparece una causa (varias respuestas por backtracking).
evidencia(Causa, imagen(Etiqueta)) :-
    imagen_disponible,
    etiqueta_modelo(Causa, Etiqueta),
    hallazgo(Etiqueta, _).
evidencia(Causa, contexto(Senal)) :-
    indicador(Causa, Senal, _),
    senal(Senal).

% ---------------------------------------------------------------------
% Para ver resultados en pantalla
% ---------------------------------------------------------------------
mostrar_diagnostico :-
    nivel(Nivel),
    format("Nivel de confianza: ~w~n", [Nivel]),
    ranking(Mejores),
    (   Mejores == []
    ->  format("  (sin causas con suficiente informacion)~n")
    ;   forall(member(P-C, Mejores),
               (   nombre(C, Nombre),
                   format("  ~3f  ~w  (~w)~n", [P, Nombre, C])
               ))
    ).

tratamiento(Causa) :-
    nombre(Causa, Nombre),
    resumen(Causa, Resumen),
    format("~w~n~w~n~nQue hacer:~n", [Nombre, Resumen]),
    forall(paso(Causa, N, Texto), format("  ~w. ~w~n", [N, Texto])).
