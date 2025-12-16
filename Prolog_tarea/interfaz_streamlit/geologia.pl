% =======================================================
% GEOLOGIA.PL - VERSIÓN 6.0 (PRECISIÓN TOTAL + FLEXIBILIDAD)
% Cubre: Diagrama QAPF completo (15 campos) y Modo Campo robusto.
% =======================================================

:- dynamic tiene_textura/1.
:- dynamic tiene_mineral/1.
:- dynamic indice_color/1.

% =======================================================
% MODULO 1: CLASIFICACIÓN CUALITATIVA (VISUAL / MODO CAMPO)
% Permite variaciones de color y mezclas de minerales.
% =======================================================

% --- A. ROCAS FÉLSICAS (CON CUARZO VISIBLE) ---

% Granito: Típicamente Leucocrático, pero aceptamos Mesocrático.
identificar_visual(granito) :- 
    tiene_textura(faneritica), 
    (indice_color(leucocratico) ; indice_color(mesocratico)), 
    tiene_mineral(cuarzo), 
    tiene_mineral(feldespato_k),
    \+ tiene_mineral(olivino).

% Granodiorita: Plagioclasa dominante sobre K.
identificar_visual(granodiorita) :- 
    tiene_textura(faneritica), 
    (indice_color(leucocratico) ; indice_color(mesocratico)), 
    tiene_mineral(cuarzo), 
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(olivino).

% Cuarzo Monzonita: El caso intermedio (FK + Plag + Q + Color medio).
identificar_visual('cuarzo_monzonita') :-
    tiene_textura(faneritica),
    (indice_color(leucocratico) ; indice_color(mesocratico)),
    tiene_mineral(cuarzo),
    tiene_mineral(feldespato_k),
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(olivino).

% Riolita (Volcánica)
identificar_visual(riolita) :- 
    tiene_textura(afanitica), 
    tiene_mineral(cuarzo),
    \+ tiene_mineral(olivino).

% Dacita (Volcánica)
identificar_visual(dacita) :- 
    tiene_textura(afanitica), 
    tiene_mineral(cuarzo), 
    tiene_mineral(plagioclasa).


% --- B. ROCAS INTERMEDIAS (POCO O NADA DE CUARZO) ---

% Sienita: FK dominante. Sin Cuarzo (o muy poco).
identificar_visual(sienita) :-
    tiene_textura(faneritica),
    tiene_mineral(feldespato_k),
    \+ tiene_mineral(cuarzo),
    \+ tiene_mineral(plagioclasa).

% Monzonita: FK + Plagioclasa. Sin Cuarzo.
identificar_visual(monzonita) :-
    tiene_textura(faneritica),
    (indice_color(leucocratico) ; indice_color(mesocratico)),
    tiene_mineral(feldespato_k),
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(cuarzo).

% Diorita: Plagioclasa + Anfíbol. Sin FK.
identificar_visual(diorita) :- 
    tiene_textura(faneritica), 
    tiene_mineral(plagioclasa), 
    tiene_mineral(anfibol),
    \+ tiene_mineral(cuarzo),
    \+ tiene_mineral(feldespato_k).

% Volcánicas Intermedias
identificar_visual(traquita) :- tiene_textura(afanitica), tiene_mineral(feldespato_k), \+ tiene_mineral(cuarzo).
identificar_visual(latita)   :- tiene_textura(afanitica), tiene_mineral(feldespato_k), tiene_mineral(plagioclasa), \+ tiene_mineral(cuarzo).
identificar_visual(andesita) :- tiene_textura(afanitica), tiene_mineral(plagioclasa).


% --- C. ROCAS MÁFICAS Y ULTRAMÁFICAS ---

identificar_visual(gabro) :- 
    tiene_textura(faneritica), 
    indice_color(melanocratico), 
    tiene_mineral(piroxeno).

identificar_visual(peridotita) :- 
    tiene_textura(faneritica), 
    indice_color(ultramafico), 
    tiene_mineral(olivino).

identificar_visual(basalto) :- 
    tiene_textura(afanitica), 
    indice_color(melanocratico).


% --- D. TEXTURAS ESPECIALES ---
identificar_visual(obsidiana) :- tiene_textura(vitrea).
identificar_visual(piedra_pomez) :- tiene_textura(vesicular), indice_color(leucocratico).
identificar_visual(escoria) :- tiene_textura(vesicular), indice_color(melanocratico).
identificar_visual(toba) :- tiene_textura(piroclastica).


% =======================================================
% MODULO 2: CLASIFICACIÓN CUANTITATIVA (STRECKEISEN MATEMÁTICO)
% Detalle completo de campos QAPF.
% =======================================================

es_plutonica(faneritica).
es_plutonica(pegmatitica).
es_volcanica(afanitica).
es_volcanica(piroclastica).
es_volcanica(vitrea).
es_volcanica(vesicular).

% LÓGICA PRINCIPAL
clasificar_qapf(Textura, Q, A, P, Roca) :-
    % Cálculo del Ratio de Plagioclasa [0..100]
    ( (A + P) > 0 -> RatioP is (P / (A + P)) * 100 ; RatioP is 0 ),
    
    ( es_plutonica(Textura) -> 
        clasificar_plutonica(Q, RatioP, Roca) 
    ; 
        clasificar_volcanica(Q, RatioP, Roca) 
    ).

% --- REGLAS PLUTÓNICAS (Triángulo QAP Superior) ---

% 1. CAMPO DE CUARZO EXTREMO (>90%)
clasificar_plutonica(Q, _, 'Cuarzolita (Silexita)') :- Q > 90.

% 2. CAMPO DE TRANSICIÓN (60-90%)
clasificar_plutonica(Q, _, 'Granitoide rico en cuarzo') :- Q > 60, Q =< 90.

% 3. BANDA GRANÍTICA (20-60%)
clasificar_plutonica(Q, RatioP, 'Granito de Feld. Alcalino') :- Q > 20, Q =< 60, RatioP >= 0, RatioP < 10.
clasificar_plutonica(Q, RatioP, 'Sienogranito')              :- Q > 20, Q =< 60, RatioP >= 10, RatioP < 35.
clasificar_plutonica(Q, RatioP, 'Monzogranito')              :- Q > 20, Q =< 60, RatioP >= 35, RatioP < 65.
clasificar_plutonica(Q, RatioP, 'Granodiorita')              :- Q > 20, Q =< 60, RatioP >= 65, RatioP < 90.
clasificar_plutonica(Q, RatioP, 'Tonalita')                  :- Q > 20, Q =< 60, RatioP >= 90.

% 4. BANDA CUARZOSA (5-20%) - Aquí es donde estaba la simplificación que corregimos
clasificar_plutonica(Q, RatioP, 'Sienita de Feld. Alc. Cuarzosa') :- Q > 5, Q =< 20, RatioP >= 0, RatioP < 10.
clasificar_plutonica(Q, RatioP, 'Sienita Cuarzosa')               :- Q > 5, Q =< 20, RatioP >= 10, RatioP < 35.
clasificar_plutonica(Q, RatioP, 'Monzonita Cuarzosa')             :- Q > 5, Q =< 20, RatioP >= 35, RatioP < 65.
clasificar_plutonica(Q, RatioP, 'Monzodiorita / Monzogabro Cuarzoso') :- Q > 5, Q =< 20, RatioP >= 65, RatioP < 90.
clasificar_plutonica(Q, RatioP, 'Diorita / Gabro Cuarzoso')       :- Q > 5, Q =< 20, RatioP >= 90.

% 5. BANDA SATURADA (0-5%)
clasificar_plutonica(Q, RatioP, 'Sienita de Feld. Alcalino') :- Q =< 5, RatioP >= 0, RatioP < 10.
clasificar_plutonica(Q, RatioP, 'Sienita')                   :- Q =< 5, RatioP >= 10, RatioP < 35.
clasificar_plutonica(Q, RatioP, 'Monzonita')                 :- Q =< 5, RatioP >= 35, RatioP < 65.
clasificar_plutonica(Q, RatioP, 'Monzodiorita / Monzogabro') :- Q =< 5, RatioP >= 65, RatioP < 90.
clasificar_plutonica(Q, RatioP, 'Diorita / Gabro')           :- Q =< 5, RatioP >= 90.


% --- REGLAS VOLCÁNICAS (Simplificadas pero completas) ---

clasificar_volcanica(Q, _, 'Riolita') :- Q > 20. % Generalización para Riolita/Dacita si no tenemos Feldspato claro
clasificar_volcanica(Q, RatioP, 'Traquita')           :- Q =< 20, RatioP < 35. % Agrupa Feld Alc y Traquita normal
clasificar_volcanica(Q, RatioP, 'Latita')             :- Q =< 20, RatioP >= 35, RatioP < 65.
clasificar_volcanica(Q, RatioP, 'Andesita / Basalto') :- Q =< 20, RatioP >= 65.