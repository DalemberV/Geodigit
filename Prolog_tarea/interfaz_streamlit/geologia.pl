% =======================================================
% GEOLOGIA.PL - SISTEMA HÍBRIDO (CAMPO + LAB)
% =======================================================

% -------------------------------------------------------
% MODULO 1: CLASIFICACIÓN CUALITATIVA (MODO CAMPO)
% -------------------------------------------------------
% Hechos dinámicos para el modo texto
:- dynamic tiene_textura/1.
:- dynamic tiene_mineral/1.
:- dynamic indice_color/1.

% Reglas de Identificación Visual
identificar_visual(granito) :- tiene_textura(faneritica), indice_color(leucocratico), tiene_mineral(cuarzo), tiene_mineral(feldespato_k).
identificar_visual(granodiorita) :- tiene_textura(faneritica), indice_color(leucocratico), tiene_mineral(cuarzo), tiene_mineral(plagioclasa).
identificar_visual(diorita) :- tiene_textura(faneritica), indice_color(mesocratico), tiene_mineral(plagioclasa), tiene_mineral(anfibol).
identificar_visual(gabro) :- tiene_textura(faneritica), indice_color(melanocratico), tiene_mineral(piroxeno).
identificar_visual(peridotita) :- tiene_textura(faneritica), indice_color(ultramafico), tiene_mineral(olivino).
identificar_visual(riolita) :- tiene_textura(afanitica), indice_color(leucocratico), tiene_mineral(cuarzo).
identificar_visual(andesita) :- tiene_textura(afanitica), indice_color(mesocratico), tiene_mineral(plagioclasa).
identificar_visual(basalto) :- tiene_textura(afanitica), indice_color(melanocratico).
identificar_visual(obsidiana) :- tiene_textura(vitrea).
identificar_visual(piedra_pomez) :- tiene_textura(vesicular), indice_color(leucocratico).
identificar_visual(escoria) :- tiene_textura(vesicular), indice_color(melanocratico).
identificar_visual(toba) :- tiene_textura(piroclastica).

% -------------------------------------------------------
% MODULO 2: CLASIFICACIÓN CUANTITATIVA (STRECKEISEN MATEMÁTICO)
% -------------------------------------------------------

% Definimos si es Intrusiva (Plutónica) o Extrusiva (Volcánica)
es_plutonica(faneritica).
es_plutonica(pegmatitica).
es_volcanica(afanitica).
es_volcanica(piroclastica). % Aunque usualmente no se usa QAPF estricto, la clasificamos en el diagrama volcánico
es_volcanica(vitrea).
es_volcanica(vesicular).

% CÁLCULO DE POSICIÓN EN EL DIAGRAMA
% La clave es normalizar P sobre el total de feldespatos (A + P).
% RatioP = (P / (A + P)) * 100.

clasificar_qapf(Textura, Q, A, P, Roca) :-
    % 1. Calcular Ratio de Plagioclasa (Eje Horizontal)
    ( (A + P) > 0 -> RatioP is (P / (A + P)) * 100 ; RatioP is 0 ),
    
    % 2. Determinar ambiente
    ( es_plutonica(Textura) ->
        clasificar_plutonica(Q, RatioP, Roca)
    ;
        clasificar_volcanica(Q, RatioP, Roca)
    ).

% --- REGLAS PLUTÓNICAS (Triángulo Superior QAP) ---
% Campo 1a: Cuarzolita
clasificar_plutonica(Q, _, 'Cuarzolita (Silexita)') :- Q > 90.

% Campo 1b: Granitoides ricos en cuarzo (Q 60-90)
clasificar_plutonica(Q, _, 'Granitoide rico en cuarzo') :- Q > 60, Q =< 90.

% Campo 2: Granito de Feldespato Alcalino
clasificar_plutonica(Q, RatioP, 'Granito de Feld. Alcalino') :- Q > 20, Q =< 60, RatioP >= 0, RatioP < 10.

% Campo 3: Granito (Sienogranito y Monzogranito)
clasificar_plutonica(Q, RatioP, 'Granito (Sienogranito)') :- Q > 20, Q =< 60, RatioP >= 10, RatioP < 35.
clasificar_plutonica(Q, RatioP, 'Granito (Monzogranito)') :- Q > 20, Q =< 60, RatioP >= 35, RatioP < 65.

% Campo 4: Granodiorita
clasificar_plutonica(Q, RatioP, 'Granodiorita') :- Q > 20, Q =< 60, RatioP >= 65, RatioP < 90.

% Campo 5: Tonalita
clasificar_plutonica(Q, RatioP, 'Tonalita') :- Q > 20, Q =< 60, RatioP >= 90.

% Campo 6: Sienita de Feld. Alcalino cuarzosa
clasificar_plutonica(Q, RatioP, 'Sienita de Feld. Alc. cuarzosa') :- Q > 5, Q =< 20, RatioP >= 0, RatioP < 10.

% Campo 7: Sienita cuarzosa
clasificar_plutonica(Q, RatioP, 'Sienita cuarzosa') :- Q > 5, Q =< 20, RatioP >= 10, RatioP < 35.

% Campo 8: Monzonita cuarzosa
clasificar_plutonica(Q, RatioP, 'Monzonita cuarzosa') :- Q > 5, Q =< 20, RatioP >= 35, RatioP < 65.

% Campo 9: Monzodiorita cuarzosa / Monzogabro cuarzoso
clasificar_plutonica(Q, RatioP, 'Monzodiorita/Monzogabro cuarzoso') :- Q > 5, Q =< 20, RatioP >= 65, RatioP < 90.

% Campo 10: Diorita cuarzosa / Gabro cuarzoso
clasificar_plutonica(Q, RatioP, 'Diorita/Gabro cuarzoso') :- Q > 5, Q =< 20, RatioP >= 90.

% Campo 6*: Sienita de Feld. Alcalino
clasificar_plutonica(Q, RatioP, 'Sienita de Feld. Alcalino') :- Q =< 5, RatioP >= 0, RatioP < 10.

% Campo 7*: Sienita
clasificar_plutonica(Q, RatioP, 'Sienita') :- Q =< 5, RatioP >= 10, RatioP < 35.

% Campo 8*: Monzonita
clasificar_plutonica(Q, RatioP, 'Monzonita') :- Q =< 5, RatioP >= 35, RatioP < 65.

% Campo 9*: Monzodiorita / Monzogabro
clasificar_plutonica(Q, RatioP, 'Monzodiorita/Monzogabro') :- Q =< 5, RatioP >= 65, RatioP < 90.

% Campo 10*: Diorita / Gabro
clasificar_plutonica(Q, RatioP, 'Diorita/Gabro') :- Q =< 5, RatioP >= 90.


% --- REGLAS VOLCÁNICAS (Simplificadas para brevedad, misma lógica de Ratios) ---
clasificar_volcanica(Q, _, 'Riolita de alto silice') :- Q > 60.
clasificar_volcanica(Q, RatioP, 'Riolita de Feld. Alc.') :- Q > 20, Q =< 60, RatioP < 10.
clasificar_volcanica(Q, RatioP, 'Riolita') :- Q > 20, Q =< 60, RatioP >= 10, RatioP < 65.
clasificar_volcanica(Q, RatioP, 'Dacita') :- Q > 20, Q =< 60, RatioP >= 65.
clasificar_volcanica(Q, RatioP, 'Traquita de Feld. Alc.') :- Q =< 20, RatioP < 10.
clasificar_volcanica(Q, RatioP, 'Traquita / Latita') :- Q =< 20, RatioP >= 10, RatioP < 65.
clasificar_volcanica(Q, RatioP, 'Andesita / Basalto') :- Q =< 20, RatioP >= 65.