% =======================================================
% GEOLOGIA.PL - CLASIFICACIÓN QAPF STRECKEISEN
% =======================================================

% 1. DICCIONARIO DE TIPOS (TEXTURA -> AMBIENTE)
% Esto decide qué triangulo usar: Plutónico (Intrusivo) o Volcánico (Extrusivo)

ambiente(faneritica, intrusiva).
ambiente(pegmatitica, intrusiva).
ambiente(afanitica, extrusiva).
ambiente(piroclastica, extrusiva).
ambiente(vitrea, extrusiva).
ambiente(vesicular, extrusiva).

% 2. BASE DE DATOS QAPF (RANGOS)
% Formato: qap(Nombre, Ambiente, [MinQ, MaxQ], [MinA, MaxA], [MinP, MaxP])
% A = Feldespato Alcalino (K), P = Plagioclasa, Q = Cuarzo

% --- ROCAS INTRUSIVAS (Plutónicas) ---
qap(granito_rico_cuarzo, intrusiva, [60, 100], [0, 100], [0, 100]).
qap(granito,             intrusiva, [20, 60],  [35, 90],  [10, 65]).
qap(granodiorita,        intrusiva, [20, 60],  [10, 35],  [65, 90]).
qap(tonalita,            intrusiva, [20, 60],  [0, 10],   [90, 100]).
qap(sienita_cuarzosa,    intrusiva, [5, 20],   [65, 90],  [10, 35]).
qap(monzonita_cuarzosa,  intrusiva, [5, 20],   [35, 65],  [35, 65]).
qap(monzodiorita_cuarzosa, intrusiva, [5, 20], [10, 35],  [65, 90]).
qap(diorita_cuarzosa,    intrusiva, [5, 20],   [0, 10],   [90, 100]).
qap(sienita,             intrusiva, [0, 5],    [65, 90],  [10, 35]).
qap(monzonita,           intrusiva, [0, 5],    [35, 65],  [35, 65]).
qap(monzodiorita,        intrusiva, [0, 5],    [10, 35],  [65, 90]).
qap(diorita,             intrusiva, [0, 5],    [0, 10],   [90, 100]).
qap(gabro,               intrusiva, [0, 5],    [0, 10],   [90, 100]). % Superposición con Diorita (se diferencia por % Anortita, aquí simplificado)

% --- ROCAS EXTRUSIVAS (Volcánicas) ---
qap(riolita,             extrusiva, [20, 60],  [35, 90],  [10, 65]).
qap(dacita,              extrusiva, [20, 60],  [10, 35],  [65, 90]).
qap(traquita_cuarzosa,   extrusiva, [5, 20],   [65, 90],  [10, 35]).
qap(latita_cuarzosa,     extrusiva, [5, 20],   [35, 65],  [35, 65]).
qap(andesita,            extrusiva, [0, 20],   [0, 35],   [65, 100]). % Simplificado
qap(traquita,            extrusiva, [0, 5],    [65, 90],  [10, 35]).
qap(latita,              extrusiva, [0, 5],    [35, 65],  [35, 65]).
qap(basalto,             extrusiva, [0, 5],    [0, 35],   [65, 100]).

% 3. LÓGICA DE CLASIFICACIÓN
% Verificamos que el valor esté en el rango
en_rango(Val, [Min, Max]) :-
    Val >= Min,
    Val =< Max.

% REGLA MAESTRA
% Recibe Textura y porcentajes. Devuelve la Roca.
identificar_streckeisen(Textura, Q, A, P, Roca) :-
    % 1. Determinar si usamos tabla Intrusiva o Extrusiva
    ambiente(Textura, TipoAmbiente),
    % 2. Buscar en la base de datos coincidencia
    qap(Roca, TipoAmbiente, RangoQ, RangoA, RangoP),
    % 3. Validar números
    en_rango(Q, RangoQ),
    en_rango(A, RangoA),
    en_rango(P, RangoP).

% CASOS ESPECIALES (Ignoran QAP)
identificar_streckeisen(vitrea, _, _, _, obsidiana).
identificar_streckeisen(vesicular, _, _, _, piedra_pomez). % Simplificado
identificar_streckeisen(piroclastica, _, _, _, toba).