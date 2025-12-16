% =======================================================
% GEOLOGIA.PL - BASE DE CONOCIMIENTO MAESTRA (V4.0)
% Cubre: Serie de Bowen completa, QAPF Plutónico y Volcánico.
% =======================================================

% 1. DEFINICIÓN DE HECHOS DINÁMICOS
:- dynamic tiene_textura/1.
:- dynamic tiene_mineral/1.
:- dynamic indice_color/1.

% =======================================================
% MODULO 1: CLASIFICACIÓN CUALITATIVA (MODO CAMPO)
% Reglas para descripción visual (Textura + Color + Minerales).
% Uso estricto de NEGACIÓN (\+) para diferenciar familias.
% =======================================================

% -------------------------------------------------------
% A. ROCAS FÉLSICAS (Ricas en Sílice)
% -------------------------------------------------------
% Granito: Cuarzo + K-Feldspato dominantes.
identificar_visual(granito) :- 
    tiene_textura(faneritica), 
    indice_color(leucocratico), 
    tiene_mineral(cuarzo), 
    tiene_mineral(feldespato_k),
    \+ tiene_mineral(olivino).

% Granodiorita: Cuarzo + Plagioclasa dominantes.
identificar_visual(granodiorita) :- 
    tiene_textura(faneritica), 
    indice_color(leucocratico), 
    tiene_mineral(cuarzo), 
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(olivino).

% Riolita (Equivalente volcánico del Granito)
identificar_visual(riolita) :- 
    tiene_textura(afanitica), 
    indice_color(leucocratico), 
    tiene_mineral(cuarzo),
    \+ tiene_mineral(olivino).

% Dacita (Equivalente volcánico de Granodiorita)
identificar_visual(dacita) :- 
    tiene_textura(afanitica), 
    indice_color(leucocratico), 
    tiene_mineral(cuarzo), 
    tiene_mineral(plagioclasa).

% -------------------------------------------------------
% B. ROCAS INTERMEDIAS (La zona que faltaba)
% -------------------------------------------------------
% Sienita: Mucho K-Feldspato, SIN Cuarzo, SIN Plagioclasa importante.
identificar_visual(sienita) :-
    tiene_textura(faneritica),
    (indice_color(leucocratico) ; indice_color(mesocratico)),
    tiene_mineral(feldespato_k),
    \+ tiene_mineral(cuarzo),
    \+ tiene_mineral(plagioclasa).

% Monzonita: "La mezcla". K-Feldspato + Plagioclasa, pero SIN Cuarzo.
identificar_visual(monzonita) :-
    tiene_textura(faneritica),
    indice_color(mesocratico),
    tiene_mineral(feldespato_k),
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(cuarzo).

% Diorita: Plagioclasa + Anfíbol, SIN K-Feldspato, SIN Cuarzo.
identificar_visual(diorita) :- 
    tiene_textura(faneritica), 
    indice_color(mesocratico), 
    tiene_mineral(plagioclasa), 
    tiene_mineral(anfibol),
    \+ tiene_mineral(cuarzo),
    \+ tiene_mineral(feldespato_k).

% Traquita (Volcánica de Sienita)
identificar_visual(traquita) :-
    tiene_textura(afanitica),
    (indice_color(leucocratico) ; indice_color(mesocratico)),
    tiene_mineral(feldespato_k),
    \+ tiene_mineral(cuarzo).

% Latita (Volcánica de Monzonita)
identificar_visual(latita) :-
    tiene_textura(afanitica),
    indice_color(mesocratico),
    tiene_mineral(feldespato_k),
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(cuarzo).

% Andesita (Volcánica de Diorita)
identificar_visual(andesita) :- 
    tiene_textura(afanitica), 
    indice_color(mesocratico), 
    tiene_mineral(plagioclasa).

% -------------------------------------------------------
% C. ROCAS MÁFICAS Y ULTRAMÁFICAS
% -------------------------------------------------------
% Gabro: Plagioclasa + Piroxeno.
identificar_visual(gabro) :- 
    tiene_textura(faneritica), 
    indice_color(melanocratico), 
    tiene_mineral(piroxeno).

% Peridotita: Olivino dominante.
identificar_visual(peridotita) :- 
    tiene_textura(faneritica), 
    indice_color(ultramafico), 
    tiene_mineral(olivino).

% Basalto: Plagioclasa + Piroxeno (grano fino).
identificar_visual(basalto) :- 
    tiene_textura(afanitica), 
    indice_color(melanocratico).

% -------------------------------------------------------
% D. TEXTURAS ESPECIALES
% -------------------------------------------------------
identificar_visual(obsidiana) :- tiene_textura(vitrea).
identificar_visual(piedra_pomez) :- tiene_textura(vesicular), indice_color(leucocratico).
identificar_visual(escoria) :- tiene_textura(vesicular), indice_color(melanocratico).
identificar_visual(toba) :- tiene_textura(piroclastica).


% =======================================================
% MODULO 2: CLASIFICACIÓN CUANTITATIVA (STRECKEISEN MATEMÁTICO)
% Lógica de Ratios para cubrir el 100% del diagrama QAP.
% =======================================================

% Definición de Ambientes
es_plutonica(faneritica).
es_plutonica(pegmatitica).
es_volcanica(afanitica).
es_volcanica(piroclastica).
es_volcanica(vitrea).
es_volcanica(vesicular).

% Regla Maestra QAPF
clasificar_qapf(Textura, Q, A, P, Roca) :-
    % 1. Normalización del eje horizontal (Plagioclasa vs Total Feldespatos)
    % RatioP va de 0 (Todo K) a 100 (Todo Plagioclasa)
    ( (A + P) > 0 -> RatioP is (P / (A + P)) * 100 ; RatioP is 0 ),
    
    % 2. Selección de diagrama
    ( es_plutonica(Textura) ->
        clasificar_plutonica(Q, RatioP, Roca)
    ;
        clasificar_volcanica(Q, RatioP, Roca)
    ).

% --- REGLAS PLUTÓNICAS (QAP Superior) ---

% Campo 1: Rocas de sílice pura
clasificar_plutonica(Q, _, 'Cuarzolita (Silexita)') :- Q > 90.

% Campo 1b: Transición
clasificar_plutonica(Q, _, 'Granitoide rico en cuarzo') :- Q > 60, Q =< 90.

% -- BANDA GRANÍTICA (Q entre 20 y 60) --
clasificar_plutonica(Q, RatioP, 'Granito de Feld. Alcalino') :- Q > 20, Q =< 60, RatioP >= 0, RatioP < 10.
clasificar_plutonica(Q, RatioP, 'Sienogranito (Granito)')   :- Q > 20, Q =< 60, RatioP >= 10, RatioP < 35.
clasificar_plutonica(Q, RatioP, 'Monzogranito (Granito)')   :- Q > 20, Q =< 60, RatioP >= 35, RatioP < 65.
clasificar_plutonica(Q, RatioP, 'Granodiorita')             :- Q > 20, Q =< 60, RatioP >= 65, RatioP < 90.
clasificar_plutonica(Q, RatioP, 'Tonalita')                 :- Q > 20, Q =< 60, RatioP >= 90.

% -- BANDA CON CUARZO (Q entre 5 y 20) --
clasificar_plutonica(Q, RatioP, 'Sienita de Feld. Alc. cuarzosa')   :- Q > 5, Q =< 20, RatioP >= 0, RatioP < 10.
clasificar_plutonica(Q, RatioP, 'Sienita cuarzosa')                 :- Q > 5, Q =< 20, RatioP >= 10, RatioP < 35.
clasificar_plutonica(Q, RatioP, 'Monzonita cuarzosa')               :- Q > 5, Q =< 20, RatioP >= 35, RatioP < 65.
clasificar_plutonica(Q, RatioP, 'Monzodiorita/Monzogabro cuarzoso') :- Q > 5, Q =< 20, RatioP >= 65, RatioP < 90.
clasificar_plutonica(Q, RatioP, 'Diorita/Gabro cuarzoso')           :- Q > 5, Q =< 20, RatioP >= 90.

% -- BANDA SATURADA (Q entre 0 y 5) --
clasificar_plutonica(Q, RatioP, 'Sienita de Feld. Alcalino') :- Q =< 5, RatioP >= 0, RatioP < 10.
clasificar_plutonica(Q, RatioP, 'Sienita')                   :- Q =< 5, RatioP >= 10, RatioP < 35.
clasificar_plutonica(Q, RatioP, 'Monzonita')                 :- Q =< 5, RatioP >= 35, RatioP < 65.
clasificar_plutonica(Q, RatioP, 'Monzodiorita / Monzogabro') :- Q =< 5, RatioP >= 65, RatioP < 90.
clasificar_plutonica(Q, RatioP, 'Diorita / Gabro / Anortosita') :- Q =< 5, RatioP >= 90.


% --- REGLAS VOLCÁNICAS (QAP Superior) ---

% Riolitas y Dacitas
clasificar_volcanica(Q, _, 'Riolita de alto silice') :- Q > 60.
clasificar_volcanica(Q, RatioP, 'Riolita de Feld. Alc.') :- Q > 20, Q =< 60, RatioP >= 0, RatioP < 10.
clasificar_volcanica(Q, RatioP, 'Riolita')               :- Q > 20, Q =< 60, RatioP >= 10, RatioP < 65.
clasificar_volcanica(Q, RatioP, 'Dacita')                :- Q > 20, Q =< 60, RatioP >= 65.

% Traquitas y Latitas (Con Cuarzo)
clasificar_volcanica(Q, RatioP, 'Traquita de Feld. Alc. cuarzosa') :- Q > 5, Q =< 20, RatioP >= 0, RatioP < 10.
clasificar_volcanica(Q, RatioP, 'Traquita cuarzosa')               :- Q > 5, Q =< 20, RatioP >= 10, RatioP < 35.
clasificar_volcanica(Q, RatioP, 'Latita cuarzosa')                 :- Q > 5, Q =< 20, RatioP >= 35, RatioP < 65.
clasificar_volcanica(Q, RatioP, 'Andesita/Basalto cuarzoso')       :- Q > 5, Q =< 20, RatioP >= 65.

% Traquitas y Latitas (Saturadas)
clasificar_volcanica(Q, RatioP, 'Traquita de Feld. Alc.') :- Q =< 5, RatioP >= 0, RatioP < 10.
clasificar_volcanica(Q, RatioP, 'Traquita')               :- Q =< 5, RatioP >= 10, RatioP < 35.
clasificar_volcanica(Q, RatioP, 'Latita')                 :- Q =< 5, RatioP >= 35, RatioP < 65.
clasificar_volcanica(Q, RatioP, 'Andesita / Basalto')     :- Q =< 5, RatioP >= 65.