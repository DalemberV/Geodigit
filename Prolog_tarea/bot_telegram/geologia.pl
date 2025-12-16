% =======================================================
% GEOLOGIA.PL - VERSIÓN 8.0 (JERARQUÍA + COLOR INDEX)
% =======================================================

:- dynamic tiene_textura/1.
:- dynamic tiene_mineral/1.
:- dynamic indice_color/1.

% =======================================================
% MODULO 1: CLASIFICACIÓN VISUAL (MODO CAMPO)
% =======================================================
% NOTA: El orden de las reglas importa (Prolog busca de arriba a abajo).

% -------------------------------------------------------
% NIVEL 1: LOS TRES MINERALES (Q + FK + Plag)
% -------------------------------------------------------
identificar_visual('Cuarzo Monzonita / Granito (Monzogranito)') :-
    tiene_textura(faneritica),
    (indice_color(leucocratico) ; indice_color(mesocratico)), % Filtro Color
    tiene_mineral(cuarzo),
    tiene_mineral(feldespato_k),
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(olivino).

% -------------------------------------------------------
% NIVEL 2: PARES FÉLSICOS (Con Cuarzo OBLIGATORIO)
% -------------------------------------------------------

% Granito de Feld. Alcalino (Sienogranito)
identificar_visual('Granito de Feld. Alcalino') :- 
    tiene_textura(faneritica), 
    (indice_color(leucocratico) ; indice_color(mesocratico)),
    tiene_mineral(cuarzo), 
    tiene_mineral(feldespato_k),
    \+ tiene_mineral(plagioclasa), % Si tuviera Plag, sería Nivel 1
    \+ tiene_mineral(olivino).

% Granodiorita / Tonalita
identificar_visual('Granodiorita / Tonalita') :- 
    tiene_textura(faneritica), 
    (indice_color(leucocratico) ; indice_color(mesocratico)),
    tiene_mineral(cuarzo), 
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(feldespato_k),
    \+ tiene_mineral(olivino).

% Riolita (Volcánica)
identificar_visual(riolita) :- 
    tiene_textura(afanitica), 
    (indice_color(leucocratico) ; indice_color(mesocratico)),
    tiene_mineral(cuarzo), 
    \+ tiene_mineral(olivino).

% -------------------------------------------------------
% NIVEL 3: PARES INTERMEDIOS (Sin Cuarzo)
% -------------------------------------------------------

% Monzonita (FK + Plag)
identificar_visual(monzonita) :-
    tiene_textura(faneritica),
    (indice_color(leucocratico) ; indice_color(mesocratico)),
    tiene_mineral(feldespato_k),
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(cuarzo).

% Latita (Volcánica)
identificar_visual(latita) :-
    tiene_textura(afanitica),
    tiene_mineral(feldespato_k),
    tiene_mineral(plagioclasa),
    \+ tiene_mineral(cuarzo).

% -------------------------------------------------------
% NIVEL 4: UN SOLO MINERAL DOMINANTE
% -------------------------------------------------------

% Sienita (Solo FK)
identificar_visual(sienita) :-
    tiene_textura(faneritica),
    (indice_color(leucocratico) ; indice_color(mesocratico)),
    tiene_mineral(feldespato_k),
    \+ tiene_mineral(cuarzo),
    \+ tiene_mineral(plagioclasa).

% Diorita (Solo Plag + Máficos)
identificar_visual(diorita) :- 
    tiene_textura(faneritica), 
    (indice_color(mesocratico) ; indice_color(melanocratico)), % Diorita puede ser oscura
    tiene_mineral(plagioclasa), 
    \+ tiene_mineral(cuarzo),
    \+ tiene_mineral(feldespato_k).

% Traquita (Volcánica Sienita)
identificar_visual(traquita) :- 
    tiene_textura(afanitica), 
    tiene_mineral(feldespato_k), 
    \+ tiene_mineral(cuarzo).

% Andesita (Volcánica Diorita)
identificar_visual(andesita) :- 
    tiene_textura(afanitica), 
    tiene_mineral(plagioclasa).

% -------------------------------------------------------
% NIVEL 5: MÁFICAS Y ULTRAMÁFICAS (Color Oscuro OBLIGATORIO)
% -------------------------------------------------------

% Gabro
identificar_visual(gabro) :- 
    tiene_textura(faneritica), 
    indice_color(melanocratico), % Debe ser oscuro
    tiene_mineral(piroxeno).

% Peridotita
identificar_visual(peridotita) :- 
    tiene_textura(faneritica), 
    indice_color(ultramafico),   % Debe ser verde/negro
    tiene_mineral(olivino).

% Basalto
identificar_visual(basalto) :- 
    tiene_textura(afanitica), 
    indice_color(melanocratico).

% -------------------------------------------------------
% NIVEL 6: TEXTURAS ESPECIALES
% -------------------------------------------------------
identificar_visual(obsidiana) :- tiene_textura(vitrea).
identificar_visual('Piedra Pomez') :- tiene_textura(vesicular), indice_color(leucocratico).
identificar_visual(escoria) :- tiene_textura(vesicular), indice_color(melanocratico).
identificar_visual(toba) :- tiene_textura(piroclastica).


% =======================================================
% MODULO 2: QAPF CUANTITATIVO (STRECKEISEN)
% =======================================================
es_plutonica(faneritica).
es_plutonica(pegmatitica).
es_volcanica(afanitica).
es_volcanica(piroclastica).
es_volcanica(vitrea).
es_volcanica(vesicular).

clasificar_qapf(Textura, Q, A, P, Roca) :-
    ( (A + P) > 0 -> RatioP is (P / (A + P)) * 100 ; RatioP is 0 ),
    ( es_plutonica(Textura) -> clasificar_plutonica(Q, RatioP, Roca) ; clasificar_volcanica(Q, RatioP, Roca) ).

% PLUTÓNICAS
clasificar_plutonica(Q, _, 'Cuarzolita') :- Q > 90.
clasificar_plutonica(Q, _, 'Granitoide rico en cuarzo') :- Q > 60, Q =< 90.
clasificar_plutonica(Q, RatioP, 'Granito de Feld. Alc.') :- Q > 20, Q =< 60, RatioP >= 0, RatioP < 10.
clasificar_plutonica(Q, RatioP, 'Sienogranito') :- Q > 20, Q =< 60, RatioP >= 10, RatioP < 35.
clasificar_plutonica(Q, RatioP, 'Monzogranito') :- Q > 20, Q =< 60, RatioP >= 35, RatioP < 65.
clasificar_plutonica(Q, RatioP, 'Granodiorita') :- Q > 20, Q =< 60, RatioP >= 65, RatioP < 90.
clasificar_plutonica(Q, RatioP, 'Tonalita') :- Q > 20, Q =< 60, RatioP >= 90.

% INTERMEDIAS
clasificar_plutonica(Q, RatioP, 'Sienita (Cuarzosa)') :- Q =< 20, RatioP < 10.
clasificar_plutonica(Q, RatioP, 'Sienita/Monzonita (Transición)') :- Q =< 20, RatioP >= 10, RatioP < 35.
clasificar_plutonica(Q, RatioP, 'Monzonita (Cuarzosa)') :- Q =< 20, RatioP >= 35, RatioP < 65.
clasificar_plutonica(Q, RatioP, 'Monzodiorita (Cuarzosa)') :- Q =< 20, RatioP >= 65, RatioP < 90.
clasificar_plutonica(Q, RatioP, 'Diorita / Gabro') :- Q =< 20, RatioP >= 90.

% VOLCÁNICAS
clasificar_volcanica(Q, _, 'Riolita') :- Q > 20.
clasificar_volcanica(Q, RatioP, 'Traquita') :- Q =< 20, RatioP < 35.
clasificar_volcanica(Q, RatioP, 'Latita') :- Q =< 20, RatioP >= 35, RatioP < 65.
clasificar_volcanica(Q, RatioP, 'Andesita / Basalto') :- Q =< 20, RatioP >= 65.