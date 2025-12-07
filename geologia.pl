% =======================================================
% ARCHIVO: geologia.pl
% =======================================================

% 1. DEFINIR QUE ESTOS HECHOS CAMBIAN DINÁMICAMENTE
:- dynamic tiene_textura/1.
:- dynamic tiene_mineral/1.
:- dynamic indice_color/1.

% 2. REGLAS MAESTRAS (Aridad 1: identificar_roca(Resultado))

% --- Familia Granito/Riolita ---
identificar_roca(granito) :-
    tiene_textura(faneritica),
    indice_color(leucocratico),
    tiene_mineral(cuarzo),
    tiene_mineral(feldespato_k).

identificar_roca(riolita) :-
    tiene_textura(afanitica),
    indice_color(leucocratico),
    tiene_mineral(cuarzo).

% --- Familia Granodiorita/Dacita ---
identificar_roca(granodiorita) :-
    tiene_textura(faneritica),
    indice_color(leucocratico),
    tiene_mineral(cuarzo),
    tiene_mineral(plagioclasa).

% --- Familia Diorita/Andesita ---
identificar_roca(diorita) :-
    tiene_textura(faneritica),
    indice_color(mesocratico),
    tiene_mineral(plagioclasa),
    tiene_mineral(anfibol).

identificar_roca(andesita) :-
    tiene_textura(afanitica),
    indice_color(mesocratico),
    tiene_mineral(plagioclasa).

% --- Familia Gabro/Basalto ---
identificar_roca(gabro) :-
    tiene_textura(faneritica),
    indice_color(melanocratico),
    tiene_mineral(piroxeno).

identificar_roca(basalto) :-
    tiene_textura(afanitica),
    indice_color(melanocratico),
    tiene_mineral(piroxeno).

identificar_roca(basalto) :- % Caso alternativo para basalto
    tiene_textura(vesicular),
    indice_color(melanocratico).

% --- Rocas Ultramáficas ---
identificar_roca(peridotita) :-
    tiene_textura(faneritica),
    indice_color(ultramafico),
    tiene_mineral(olivino).

% --- Vidrios ---
identificar_roca(obsidiana) :-
    tiene_textura(vitrea).

identificar_roca(piedra_pomez) :-
    tiene_textura(vesicular),
    indice_color(leucocratico).

identificar_roca(escoria) :-
    tiene_textura(vesicular),
    indice_color(melanocratico).

identificar_roca(toba) :-
    tiene_textura(piroclastica).