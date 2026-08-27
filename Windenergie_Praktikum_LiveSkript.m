%% Windenergie-Praktikum: Auswertung realer Messdaten
% Dieses Live-Skript ergänzt die Vorlesung durch die Auswertung realer Messdaten einer Kleinwindkraftanlage am Hochschulstandort. Im Mittelpunkt stehen Windangebot, Windrichtung, Leistungskennlinie, Rotordrehzahl, Schnelllaufzahl und der elektrisch abgeleitete Leistungsbeiwert.
%
% Die umfangreiche technische Verarbeitung der Messdaten ist am Ende dieses Dokuments im Abschnitt "Technischer Anhang - nicht bearbeiten" hinterlegt. Für die Bearbeitung des Praktikums müssen diese Funktionen weder gelesen noch verändert werden.

%% Vorbereitung und Bearbeitungshinweise
% Benötigte Ordnerstruktur:
%
% Windenergie_Praktikum_LiveSkript.mlx
%
% Daten/
%
%     Wind_Mittel-2018.csv
%
%     Wind_Mittel-2017.csv
%
%     Wind_Momentan-2013.csv
%
% Vorgehen:
%
% 1. Speichern Sie das Live-Skript und den Ordner Daten im selben Hauptordner.
%
% 2. Öffnen Sie das Live-Skript mit MATLAB R2025b.
%
% 3. Führen Sie zuerst Abschnitt 0 aus. Dort wird geprüft, ob alle Dateien gefunden werden.
%
% 4. Bearbeiten Sie die Abschnitte in der vorgegebenen Reihenfolge.
%
% 5. Verändern oder ergänzen Sie ausschließlich Variablen, deren Namen auf "_eingabe" enden. Die übrigen Codezeilen sind für die automatische Auswertung erforderlich.
%
% 6. MATLAB verwendet im Code einen Dezimalpunkt. Schreiben Sie beispielsweise 0.5 und nicht 0,5.
%
% 7. Tragen Sie Rechenergebnisse in die mit NaN vorbelegten Variablen ein.
%
% 8. Führen Sie danach den zugehörigen Abschnitt erneut aus. Die Rückmeldung lautet "korrekt", "nicht korrekt" oder "nicht bearbeitet".
%
% 9. Formulieren Sie qualitative Antworten direkt unter den Fragen.
%
% 10. Am Ende kann nach Eingabe des Wortes FERTIG eine Musterlösung zur Selbstkontrolle eingeblendet werden.
%
% 11. Speichern Sie das bearbeitete Live-Skript unter einem neuen Dateinamen.

%% 0 Start, Anlagenparameter und Dateiprüfung
clearvars; close all; clc;
rng(1);

scriptFolder = getScriptFolder();
dataFolder = fullfile(scriptFolder, "Daten");

meteoFile    = fullfile(dataFolder, "Wind_Mittel-2018.csv");
powerFile    = fullfile(dataFolder, "Wind_Mittel-2017.csv");
momentanFile = fullfile(dataFolder, "Wind_Momentan-2013.csv");

requiredFiles = [meteoFile, powerFile, momentanFile];
fileCheck = checkRequiredFiles(requiredFiles);
fileCheck

assert(all(fileCheck.Gefunden), ...
    "Mindestens eine Datendatei fehlt. Prüfen Sie die Ordnerstruktur im Abschnitt Vorbereitung.");

cfg = defaultConfig();
settingsOverview = createSettingsOverview(cfg);
settingsOverview
%

%% 1 Kurze Einordnung der Datenbasis
% Für die Standortauswertung werden die 30-s-Mittelwerte des Jahres 2018 verwendet. Vor der Auswertung werden ungültige Zeitstempel entfernt, kurze Datenlücken bis fünf Minuten linear interpoliert und längere auffällige Nullwertabschnitte ausgeschlossen. Die Bereinigung läuft automatisch und ist nicht der Schwerpunkt dieses Praktikums.
%
% Entscheidend ist, ob anschließend eine ausreichend vollständige und über das Jahr verteilte Datenbasis für die folgenden Auswertungen vorliegt.
[Tmeteo, reportMeteo] = prepareWindMittel(meteoFile, cfg);
qualityOverview = createShortQualityOverview(reportMeteo);
qualityOverview

plotDataQualityExample(Tmeteo, cfg);
%

%% Aufgaben zur Datenbasis
% 1. Ist die Datenverfügbarkeit des Jahres 2018 für eine saisonale Auswertung grundsätzlich ausreichend? Begründen Sie knapp.
%
% Antwort:
%
% 2. Welche Verzerrung könnte entstehen, wenn längere Datenlücken überwiegend in einer bestimmten Jahreszeit auftreten?
%
% Antwort:
%

%% 2 Windangebot 2018
% Die 30-s-Messwerte schwanken stark und sind über ein vollständiges Jahr nur schwer zu überblicken. Tagesmittel zeigen windreiche und windarme Phasen. Monatsmittel ermöglichen eine saisonale Betrachtung. Das Histogramm zeigt, welche Windgeschwindigkeiten am Standort besonders häufig auftreten.
%
% Die Einschaltwindgeschwindigkeit, auch Cut-in-Windgeschwindigkeit genannt, bezeichnet die Windgeschwindigkeit, ab der die Anlage in den elektrischen Erzeugungsbetrieb übergeht. Für die untersuchte Airdolphin GTO beträgt sie laut Hersteller 2.5 m/s. Eine Rotorbewegung kann bereits unterhalb dieses Werts auftreten.
%
% Für die energetische Bewertung ist zusätzlich entscheidend, dass die im Wind enthaltene Leistung mit der dritten Potenz der Windgeschwindigkeit zunimmt. Daher liefern wenige höhere Windgeschwindigkeiten einen überproportionalen Beitrag zum theoretischen Windenergieangebot. Dieser Zusammenhang wird in der folgenden Rechenaufgabe auf die Hochschulanlage angewendet.
windStats = createWindStatistics(Tmeteo, cfg);
monthlyStats = calcMonthlyStatistics(Tmeteo);

windStats
monthlyStats
plotWindAnalysis(Tmeteo, monthlyStats, cfg);
%

%% 2.1 Rechenaufgabe: Anteil oberhalb der Einschaltwindgeschwindigkeit
% Welcher prozentuale Anteil der verfügbaren Windgeschwindigkeitswerte liegt mindestens bei 2.5 m/s und damit in dem Bereich, in dem die Anlage grundsätzlich in den elektrischen Erzeugungsbetrieb übergehen kann?
%
% Verwenden Sie dazu die beiden Anzahlen aus der Tabelle windStats.
%
% === EINGABE: nur die folgende Zeile ergänzen ===
anteilOberhalbCutIn_eingabe = NaN;  % [%]

cutInCheck = checkSingleAnswer( ...
    "Anteil oberhalb der Einschaltgrenze", anteilOberhalbCutIn_eingabe, ...
    100*windStats.AnzahlOberhalbCutIn/windStats.GueltigeWerte, 0.2);
cutInCheck
%

%% 2.2 Rechenaufgabe: Windleistung und Betz-Grenze
% Gegeben sind der Rotordurchmesser D = 1.8 m, die Luftdichte rho = 1.225 kg/m^3 sowie die Windgeschwindigkeiten v1 = 5 m/s und v2 = 10 m/s.
%
% 1. Berechnen Sie die vom Rotor überstrichene Fläche.
%
% 2. Berechnen Sie die im Wind enthaltene Leistung bei 5 m/s.
%
% 3. Berechnen Sie die im Wind enthaltene Leistung bei 10 m/s.
%
% 4. Bestimmen Sie das Verhältnis der beiden Windleistungen.
%
% 5. Berechnen Sie die maximal ideal entnehmbare Leistung bei 10 m/s nach der Betz-Grenze.
%
% === EINGABEN: nur die folgenden Zeilen ergänzen ===
A_eingabe = NaN;                    % [m^2]
Pwind_5_eingabe = NaN;              % [W]
Pwind_10_eingabe = NaN;             % [W]
Leistungsverhaeltnis_eingabe = NaN; % [-]
Pbetz_10_eingabe = NaN;             % [W]

windPowerCheck = checkWindPowerTask( ...
    A_eingabe, Pwind_5_eingabe, Pwind_10_eingabe, ...
    Leistungsverhaeltnis_eingabe, Pbetz_10_eingabe, cfg);
windPowerCheck
%

%% 2.3 Interpretation des Windangebots
% 1. Benennen Sie den windreichsten und den windärmsten Monat. Prüfen Sie dabei auch die jeweilige monatliche Datenverfügbarkeit.
%
% Antwort:
%
% 2. Lässt sich ein saisonaler Verlauf erkennen? Beschreiben Sie Ihre Beobachtungen.
%
% Antwort:
%
% 3. Was beschreibt die Betz-Grenze und warum kann selbst eine ideale Windkraftanlage nicht die gesamte im Wind enthaltene Leistung nutzen?
%
% Antwort:
%
% 4. Warum kann die mittlere Windleistung bei schwankender Windgeschwindigkeit nicht exakt aus der mittleren Windgeschwindigkeit berechnet werden? Beziehen Sie die kubische Abhängigkeit der Windleistung ein.
%
% Antwort:
%
% 5. Bedeutet v >= 2.5 m/s automatisch, dass elektrische Leistung erzeugt wird?
%
% Antwort:
%

%% 3 Windrichtungsverteilung 2018
% Die Windrose verbindet die Häufigkeit der Windrichtungen mit Windgeschwindigkeitsklassen. Sie zeigt damit nicht nur, woher der Wind überwiegend kommt, sondern auch, aus welchen Richtungen höhere Windgeschwindigkeiten auftreten.
%
% Schwachwind unter 0.5 m/s wird separat ausgewiesen, da die Windrichtung bei sehr niedriger Geschwindigkeit nur eingeschränkt aussagekräftig ist.
windRoseResult = plotWindRoseInternal( ...
    Tmeteo.WindDirection, Tmeteo.WindSpeed);

sectorTable = windRoseResult.SectorTable;
sectorTable
%

%% 3.1 Rechenaufgabe: westlicher Richtungsanteil
% Berechnen Sie aus sectorTable den gemeinsamen Anteil der Sektoren
%      SW + WSW + W
%
% an allen gültigen Richtungswerten.
% === EINGABE: nur die folgende Zeile ergänzen ===
westlicherSektoranteil_eingabe = NaN;  % [%]

windRoseCheck = checkWestSectorShare( ...
    westlicherSektoranteil_eingabe, sectorTable);
windRoseCheck
%

%% 3.2 Interpretation der Windrose
% 1. Welcher zusammenhängende Richtungsbereich dominiert?
%
% Antwort:
%
% 2. Treten Windgeschwindigkeiten ab 4 m/s aus denselben Richtungen auf wie der Wind insgesamt? Vergleichen Sie die beiden Häufigkeitsspalten.
%
% Antwort:
%
% 3. Welche geometrischen und geografischen Standortbedingungen können die gemessene Windrose beeinflussen?
%
% Antwort:
%
% 4. Welche Information liefert eine Windrose, die ein Monatsmittelwert nicht enthält?
%
% Antwort:
%

%% 4 Leistungskennlinie der Kleinwindkraftanlage 2017
% Eine Leistungskennlinie beschreibt den Zusammenhang zwischen Windgeschwindigkeit und elektrischer Generatorleistung.
%
% Begriffe:
%
% Vollständiges Betriebsverhalten: alle plausiblen Messwerte einschließlich Stillständen und Nullleistung.
%
% Erzeugungskennlinie: Zusammenfassung ausgewählter Messwerte ab der Einschaltwindgeschwindigkeit und oberhalb einer festgelegten Mindestleistung.
%
% Windgeschwindigkeitsklasse: Zusammenfassung der Messwerte innerhalb eines begrenzten Geschwindigkeitsintervalls.
%
% Klassenmittel: mittlere elektrische Leistung aller berücksichtigten Messwerte einer Windgeschwindigkeitsklasse.
%
% Zunächst wird das gesamte gemessene Betriebsverhalten dargestellt. Dieses Diagramm enthält bewusst auch Stillstände und Nullleistung.
[Tpower, reportPower] = prepareWindMittel(powerFile, cfg);
plotMeasuredOperatingBehaviour(Tpower, cfg);
%

%% 4.1 Erzeugungskennlinie mit veränderbaren Parametern
% Führen Sie den Abschnitt zunächst mit den Ausgangswerten aus. Ändern Sie anschließend jeweils nur einen Parameter und führen Sie den Abschnitt erneut aus. Verwenden Sie im MATLAB-Code einen Dezimalpunkt.
%
% Mindestleistung: 10 W -> 50 W
%
% Klassenbreite: 0.5 m/s -> 1.0 m/s
%
% Stellen Sie danach die Ausgangswerte wieder her.
%
% === VERÄNDERBARE PARAMETER: nur die folgenden Zeilen verändern ===
Mindestleistung_eingabe = 10;  % [W]
Klassenbreite_eingabe = 0.5;   % [m/s]

curveOperating = calcPowerCurve( ...
    Tpower, Mindestleistung_eingabe, Klassenbreite_eingabe, cfg);

manufacturerCurve = createManufacturerCurveGTO();

plotGenerationCurve( ...
    curveOperating, manufacturerCurve, ...
    Mindestleistung_eingabe, Klassenbreite_eingabe, cfg);

powerCurveSummary = createPowerCurveSummary( ...
    curveOperating, Mindestleistung_eingabe, Klassenbreite_eingabe);
powerCurveSummary

powerClassTable = createPowerClassTable(curveOperating);
powerClassTable
%

%% 4.2 Rechenaufgabe: elektrisch abgeleiteter Leistungsbeiwert
% Für eine ausreichend besetzte Windgeschwindigkeitsklasse nahe 10 m/s werden die Klassenmitte und die mittlere elektrische Generatorleistung ausgegeben.
%
% 1. Berechnen Sie für die angegebene Klassenmitte die theoretische Windleistung durch die Rotorfläche.
%
% 2. Bestimmen Sie daraus den elektrisch abgeleiteten Leistungsbeiwert.
%
% Verwenden Sie den in der Tabelle angegebenen Klassenmittelwert der elektrischen Leistung.
%
% Die Rechenaufgabe verwendet unabhängig von der vorherigen Parametervariation die Ausgangswerte von 10 W Mindestleistung und 0.5 m/s Klassenbreite.
curveStandard = calcPowerCurve( ...
    Tpower, cfg.powerActiveMin_W, cfg.powerBinWidth_mps, cfg);

representativePowerClass = selectRepresentativePowerClass( ...
    curveStandard, 10.0);
representativePowerClass

% === EINGABEN: nur die folgenden Zeilen ergänzen ===
Pwind_Klasse_eingabe = NaN;  % [W]
cpEl_Klasse_eingabe = NaN;   % [-]

powerClassCheck = checkPowerClassTask( ...
    Pwind_Klasse_eingabe, cpEl_Klasse_eingabe, ...
    representativePowerClass, cfg);
powerClassCheck
%

%% 4.3 Auswertung der Leistungskennlinie
% 1. Ab welchem Windgeschwindigkeitsbereich steigt die elektrische Leistung erkennbar an? Vergleichen Sie den Bereich mit der Einschaltgrenze.
%
% Antwort:
%
% 2. Warum liegt eine gefilterte Erzeugungskennlinie im unteren Windbereich oberhalb einer Kennlinie aus allen Betriebszuständen?
%
% Antwort:
%
% 3. Wie verändert sich die Kennlinie, wenn die Mindestleistung von 10 W auf 50 W erhöht wird? Welche Zustände werden dadurch systematisch entfernt?
%
% Antwort:
%
% 4. Wie verändert sich die Kennlinie bei einer Klassenbreite von 1.0 m/s? Beurteilen Sie Auflösung und Glättung.
%
% Antwort:
%
% 5. In welchen Bereichen ist die Klassenbelegung gering? Weshalb sind diese Bereiche vorsichtiger zu interpretieren?
%
% Antwort:
%
% 6. Vergleichen Sie die gemessene Erzeugungskennlinie mit der näherungsweise aus dem Herstellerdiagramm digitalisierten Kennlinie. Warum sind Abweichungen zu erwarten?
%
% Antwort:
%
% 7. Welche Verluste und Messabweichungen sind im berechneten c_p,el enthalten?
%
% Antwort:
%

%% 5 Kurzfristiges Anlagenverhalten mit Momentandaten 2013
% Die 2-s-Momentandaten bilden kurzfristige Änderungen von Windgeschwindigkeit, Generatorleistung und Rotordrehzahl ab. Die Diagramme zeigen eine reduzierte Stichprobe der Einzelwerte sowie Klassenmittel und den Bereich zwischen dem 25-%- und 75-%-Quantil. Das 25-%-Quantil wird von 25 % der Werte unterschritten, das 75-%-Quantil von 75 %. Der dargestellte Bereich enthält damit die mittleren 50 % der Messwerte einer Klasse.
%
% Dadurch lässt sich untersuchen, ob Rotorbewegung und elektrische Leistungsabgabe gleichzeitig einsetzen und wie die Anlagenregelung bei höheren Windgeschwindigkeiten sichtbar wird.
[Tmomentan, reportMomentan] = prepareWindMomentan(momentanFile, cfg);

momentPower = calcBinnedRelationship( ...
    Tmomentan.WindSpeed, Tmomentan.Power, ...
    0.5, cfg.minMomentBinPoints);
momentSpeed = calcBinnedRelationship( ...
    Tmomentan.WindSpeed, Tmomentan.RotorSpeed, ...
    0.5, cfg.minMomentBinPoints);

plotMomentRelationships(Tmomentan, momentPower, momentSpeed, cfg);
%

%% 5.1 Interpretation der Momentandaten
% 1. Kann sich der Rotor bereits unterhalb der Einschaltwindgeschwindigkeit drehen? Begründen Sie anhand des Drehzahldiagramms.
%
% Antwort:
%
% 2. Ab welchem Geschwindigkeitsbereich steigt die elektrische Leistung erkennbar an? Stimmt dieser Bereich exakt mit dem Beginn der Rotation überein?
%
% Antwort:
%
% 3. Wie verändert sich die Rotordrehzahl bei höheren Windgeschwindigkeiten? Welche technische Ursache ist wahrscheinlich?
%
% Antwort:
%
% 4. Nennen Sie mindestens drei Ursachen für die Streuung der Einzelwerte.
%
% Antwort:
%

%% 6 Schnelllaufzahl und elektrisch abgeleiteter Leistungsbeiwert
% Für die c_p,el-Lambda-Auswertung werden Messwerte im geregelten Status U-Konstant und aus längeren zusammenhängenden Messphasen verwendet.
%
% Die Schnelllaufzahl vergleicht die Blattspitzengeschwindigkeit mit der Windgeschwindigkeit. Der elektrisch abgeleitete Leistungsbeiwert setzt die gemessene elektrische Generatorleistung ins Verhältnis zur im Wind enthaltenen Leistung. Er ist daher nicht mit dem rein aerodynamischen Leistungsbeiwert des Rotors gleichzusetzen.
[cpResults, cpMaxima, cpFilterReport, cpData] = ...
    calcCpLambdaSensitivity(momentanFile, cfg);

cpFilterReport
%

%% 6.1 Rechenaufgabe für einen realen Betriebspunkt
% Aus den für die c_p,el-Lambda-Auswertung aufbereiteten Daten wird ein
% repräsentativer 30-s-Betriebspunkt nahe 8 m/s ausgewählt.
%
% Die Tabelle enthält die mittlere Windgeschwindigkeit, die mittlere Drehzahl,
% die mittlere elektrische Leistung sowie den innerhalb des Fensters bestimmten
% Mittelwert von v^3.
%
% Berechnen Sie nacheinander:
%
% 1. die Winkelgeschwindigkeit des Rotors,
%
% 2. die Blattspitzengeschwindigkeit,
%
% 3. die Schnelllaufzahl,
%
% 4. die theoretische Windleistung durch die Rotorfläche und
%
% 5. den elektrisch abgeleiteten Leistungsbeiwert.
%
% Verwenden Sie für die Windleistung den angegebenen Mittelwert von v^3
% und nicht die dritte Potenz der mittleren Windgeschwindigkeit.
cpOperatingPoint = selectCpOperatingPoint(cpData, 8.0, 0.25, cfg);
cpOperatingPoint

% === EINGABEN: nur die folgenden Zeilen ergänzen ===
omega_eingabe = NaN;                  % [rad/s]
uSpitze_eingabe = NaN;                % [m/s]
lambda_eingabe = NaN;                 % [-]
Pwind_Betriebspunkt_eingabe = NaN;    % [W]
cpEl_Betriebspunkt_eingabe = NaN;     % [-]

momentCalculationCheck = checkMomentCalculationTask( ...
    omega_eingabe, uSpitze_eingabe, lambda_eingabe, ...
    Pwind_Betriebspunkt_eingabe, cpEl_Betriebspunkt_eingabe, ...
    cpOperatingPoint, cfg);
momentCalculationCheck
%

%% 6.2 Vollständige c_p,el-Lambda-Kennlinie
% Der Median und der Quartilsbereich fassen die stark streuenden Einzelwerte klassenweise zusammen. Zunächst wird die Hauptauswertung mit Delta-Lambda = 0.50 dargestellt. Ein zweites Diagramm vergleicht nur die Medianlinien für Delta-Lambda = 0.25, 0.50 und 1.00.
plotCpLambda(cpResults, cpData, cfg);
cpMaxima
%

%% 6.3 Auswertung der c_p,el-Lambda-Kennlinie
% 1. Liegt der manuell berechnete Betriebspunkt in der Nähe der dargestellten Kennlinie? Nennen Sie Gründe für mögliche Abweichungen.
%
% Antwort:
%
% 2. Welche Klassenbreite besitzt die höchste Auflösung und welche die stärkste Glättung?
%
% Antwort:
%
% 3. Bleibt die Lage oder die Höhe des Maximums bei Änderung der Klassenbreite stabiler? Welche Aussage ist damit belastbarer?
%
% Antwort:
%
% 4. Warum wird bei stark streuenden Daten der Median verwendet?
%
% Antwort:
%
% 5. Warum können einzelne berechnete Werte oberhalb der Betz-Grenze auftreten, obwohl dies aerodynamisch nicht möglich ist?
%
% Antwort:
%
% 6. Warum muss c_p,el von einem aerodynamischen c_p unterschieden werden?
%
% Antwort:
%

%% 7 Vertiefung: Energieintegration
% Zunächst wird die elektrische Energie exemplarisch aus vier gültigen 30-s-Intervallen berechnet. Berücksichtigen Sie dabei die jeweilige Leistung, die Dauer der Intervalle und die Umrechnung in Wattstunden.
%
% Anschließend berechnet MATLAB die erfasste elektrische Energie und das theoretische Windenergieangebot über alle gemeinsamen gültigen Intervalle. Fehlende Zeiträume werden nicht auf ein vollständiges Jahr hochgerechnet.
energyExample = createEnergyExample(Tmeteo, cfg, 4);
energyExample

% === EINGABE: nur die folgende Zeile ergänzen ===
Eel_Beispiel_eingabe = NaN;  % [Wh]

energyExampleCheck = checkEnergyExample( ...
    Eel_Beispiel_eingabe, energyExample);
energyExampleCheck

energyResult = calcEnergyCommonIntervals(Tmeteo, cfg);
energyResult
%

%% Aufgaben zur Energieintegration
% 1. Weshalb müssen elektrische und theoretische Energie über dieselben Zeitintervalle integriert werden?
%
% Antwort:
%
% 2. Warum ist E_el/E_Wind kein einzelner Anlagenwirkungsgrad?
%
% Antwort:
%

%% 8 Vertiefung: Weibull-Verteilung
% Die Weibull-Verteilung kann verwendet werden, um die Häufigkeitsverteilung
% der Windgeschwindigkeit durch eine stetige statistische Funktion zu beschreiben.
% Sie wird durch den Formparameter k und den Skalenparameter a bestimmt.
%
% Für dieses Modul wird die Statistics and Machine Learning Toolbox benötigt.
%
% Die Wahrscheinlichkeitsdichte der Weibull-Verteilung lautet:
%
% f(v) = (k/a) * (v/a)^(k-1) * exp(-(v/a)^k)
%
% Berechnen Sie mit den für 2018 bestimmten Parametern a und k die
% Wahrscheinlichkeitsdichte
%
% 1. bei v = 3 m/s und
%
% 2. bei v = 6 m/s.
%
% Vergleichen Sie Ihre Ergebnisse anschließend mit der dargestellten
% Weibull-Kurve.

if hasWeibullFunctions()
    weibullParameters = fitAndPlotWeibull(Tmeteo.WindSpeed, cfg);
    weibullParameters

    % === EINGABEN: nur die folgenden Zeilen ergänzen ===
    weibull_f3_eingabe = NaN;
    weibull_f6_eingabe = NaN;

    weibullCheck = checkWeibullTask( ...
        weibull_f3_eingabe, weibull_f6_eingabe, ...
        weibullParameters);
    weibullCheck
else
    disp("Die Weibull-Vertiefung wurde übersprungen: benötigte Toolbox nicht verfügbar.");
end
%

%% 8.1 Interpretation der Weibull-Verteilung
% Betrachten Sie das Histogramm der gemessenen Windgeschwindigkeiten und
% die darin eingezeichnete Weibull-Verteilung.
%
% In welchem Windgeschwindigkeitsbereich sind die größten Abweichungen
% zwischen den Messdaten und dem Weibull-Modell zu erkennen?
%
% Antwort:
%
%% 9 Vertiefung: idealisierter Höhen- und Rauigkeitseinfluss
% Verwenden Sie das logarithmische Windprofil aus der Vorlesung.
%
% Gegeben sind v(h1) = 4.0 m/s, h1 = 10 m, h2 = 30 m, Rauigkeitshöhe z0 = 0.5 m und Versatzparameter d = 0 m.
%
% Berechnen Sie v(h2). Erläutern Sie anschließend, warum diese idealisierte Umrechnung auf einem bebauten Hochschuldach nur eingeschränkt anwendbar ist.
%
% === EINGABE: nur die folgende Zeile ergänzen ===
v_h2_eingabe = NaN;  % [m/s]

heightCheck = checkHeightTask(v_h2_eingabe);
heightCheck

% Einschränkungen der Übertragung auf das Hochschuldach:
%
% Antwort: ________________________________________________________________
%

%% 10 Selbstkontrolle und integrierte Musterlösung
% Dieser Abschnitt dient der freiwilligen Selbstkontrolle. Nach der Eingabe und Ausführung erscheint die Musterlösung direkt unterhalb des Eingabefelds.
%
% Nach Bearbeitung aller Rechenfelder des Kernteils:
%
% Tragen Sie FERTIG ein und führen Sie nur diesen Abschnitt aus, um die Musterlösung anzuzeigen.
%
% Tragen Sie RESET ein und führen Sie nur diesen Abschnitt aus, um die Eingabevariablen im aktuellen MATLAB-Arbeitsbereich auf NaN und die veränderbaren Kennlinienparameter auf ihre Ausgangswerte zurückzusetzen.
%
% === EINGABE: "FERTIG" oder "RESET" eintragen ===
freigabe_eingabe = "";

command_eingabe = upper(strtrim(string(freigabe_eingabe)));

switch command_eingabe
    case "RESET"
        anteilOberhalbCutIn_eingabe = NaN;
        A_eingabe = NaN;
        Pwind_5_eingabe = NaN;
        Pwind_10_eingabe = NaN;
        Leistungsverhaeltnis_eingabe = NaN;
        Pbetz_10_eingabe = NaN;
        westlicherSektoranteil_eingabe = NaN;
        Pwind_Klasse_eingabe = NaN;
        cpEl_Klasse_eingabe = NaN;
        omega_eingabe = NaN;
        uSpitze_eingabe = NaN;
        lambda_eingabe = NaN;
        Pwind_Betriebspunkt_eingabe = NaN;
        cpEl_Betriebspunkt_eingabe = NaN;
        Mindestleistung_eingabe = cfg.powerActiveMin_W;
        Klassenbreite_eingabe = cfg.powerBinWidth_mps;

        if exist('Eel_Beispiel_eingabe','var')
            Eel_Beispiel_eingabe = NaN;
        end
        if exist('weibull_f3_eingabe','var')
            weibull_f3_eingabe = NaN;
        end
        if exist('weibull_f6_eingabe','var')
            weibull_f6_eingabe = NaN;
        end
        if exist('v_h2_eingabe','var')
            v_h2_eingabe = NaN;
        end

        freigabe_eingabe = "";
        disp("Die Eingabevariablen im aktuellen Arbeitsbereich wurden zurückgesetzt.");
        disp("Bereits im Skripttext gespeicherte Zahlen werden dadurch nicht verändert.");

    case "FERTIG"
        coreInputs = [ ...
            anteilOberhalbCutIn_eingabe, ...
            A_eingabe, ...
            Pwind_5_eingabe, ...
            Pwind_10_eingabe, ...
            Leistungsverhaeltnis_eingabe, ...
            Pbetz_10_eingabe, ...
            westlicherSektoranteil_eingabe, ...
            Pwind_Klasse_eingabe, ...
            cpEl_Klasse_eingabe, ...
            omega_eingabe, ...
            uSpitze_eingabe, ...
            lambda_eingabe, ...
            Pwind_Betriebspunkt_eingabe, ...
            cpEl_Betriebspunkt_eingabe];

        if all(isfinite(coreInputs))
            if ~exist('energyExample', 'var')
                energyExample = createEnergyExample(Tmeteo, cfg, 4);
            end
            if ~exist('energyResult', 'var')
                energyResult = table();
            end
            if ~exist('weibullParameters', 'var')
                weibullParameters = table();
            end

            showIntegratedMusterloesung( ...
                windStats, ...
                monthlyStats, ...
                sectorTable, ...
                representativePowerClass, ...
                cpOperatingPoint, ...
                cpMaxima, ...
                energyExample, ...
                energyResult, ...
                weibullParameters, ...
                cfg);
        else
            disp("Die Musterlösung wird angezeigt, sobald alle Rechenfelder des Kernteils bearbeitet sind.");
        end

    otherwise
        disp("Zur Anzeige der Musterlösung FERTIG oder zum Zurücksetzen RESET eintragen.");
end
%

%% Technischer Anhang – nicht bearbeiten und nicht einzeln ausführen
% Ab diesem Abschnitt folgen lokale Funktionen für Dateiimport, Datenaufbereitung, Berechnung, grafische Darstellung und Musterlösung. Die Funktionen werden beim Ausführen der vorherigen Abschnitte automatisch verwendet.
% Für die Praktikumsbearbeitung müssen diese Funktionen weder gelesen, verändert noch einzeln ausgeführt werden. Änderungen können dazu führen, dass die Auswertungen nicht mehr mit der dokumentierten Methodik übereinstimmen.
function cfg = defaultConfig()
    % Anlagenparameter Zephyr Airdolphin GTO
    cfg.D = 1.8;
    cfg.R = cfg.D/2;
    cfg.A = pi*cfg.R^2;
    cfg.rho = 1.225;
    cfg.vCutIn = 2.5;

    % Datenaufbereitung Wind_Mittel
    cfg.dtMittel_s = 30;
    cfg.maxInterpolationPoints = 10;
    cfg.zeroTolerance_mps = 0.01;
    cfg.minZeroPlateauPoints = 120;
    cfg.vMittelMin = 0;
    cfg.vMittelMax = 35;
    cfg.powerMin = 0;
    cfg.powerMax = 6000;
    cfg.rotorSpeedMin = 0;
    cfg.rotorSpeedMax = 2500;

    % Leistungskennlinie
    cfg.powerBinWidth_mps = 0.5;
    cfg.powerActiveMin_W = 10;
    cfg.minPowerBinPoints = 30;

    % Momentandaten
    cfg.dtMomentan_s = 2;
    cfg.vMomentanMin = 0;
    cfg.vMomentanMax = 25;
    cfg.minMomentBinPoints = 100;

    % c_p,el-Lambda-Auswertung
    cfg.cpMinWind_mps = 3.0;
    cfg.cpMinPower_W = 10;
    cfg.cpMinRotorSpeed_rpm = 50;

    % technische Herstellergrenzen
    cfg.cpMaxRotorSpeed_rpm = 1280;
    cfg.cpMaxPower_W = 4000;

    % zeitliche Synchronisierung
    cfg.cpLag_s = 2;

    % 30-s-Aggregation
    cfg.cpAggregation_s = 30;
    cfg.cpMinWindowCoverage = 0.80;
    cfg.cpMinWindowPoints = ceil( ...
        cfg.cpMinWindowCoverage * ...
        cfg.cpAggregation_s / cfg.dtMomentan_s);

    % Lambda-Auswertung
    cfg.cpLambdaMaxRaw = 20;
    cfg.cpLambdaPlotMax = 16;
    cfg.cpMinBinPoints = 50;
    cfg.cpBinWidths = [0.25 0.50 1.00];

    % zusammenhängende U-Konstant-Abschnitte
    cfg.cpMaxGap_s = 10;
    cfg.cpMinBlockDuration_s = 3600;
end


function overview = createSettingsOverview(cfg)
    overview = table( ...
        ["Rotordurchmesser";"Luftdichte"; ...
         "Einschaltwindgeschwindigkeit"; ...
         "Standard-Klassenbreite Leistungskennlinie"; ...
         "Standard-Mindestleistung Erzeugungskennlinie"], ...
        [cfg.D; cfg.rho; cfg.vCutIn; ...
         cfg.powerBinWidth_mps; cfg.powerActiveMin_W], ...
        ["m";"kg/m^3";"m/s";"m/s";"W"], ...
        'VariableNames', {'Einstellung','Wert','Einheit'});
end


function folder = getScriptFolder()
    folder = pwd;
    try
        activeFile = string(matlab.desktop.editor.getActiveFilename);
        if strlength(activeFile) > 0
            candidate = fileparts(activeFile);
            if strlength(candidate) > 0
                folder = candidate;
            end
        end
    catch
        % Fallback auf den aktuellen MATLAB-Arbeitsordner.
    end
end


function result = checkRequiredFiles(files)
    files = string(files(:));
    result = table(files, isfile(files), ...
        'VariableNames', {'Datei','Gefunden'});
end


function overview = createShortQualityOverview(report)
    overview = table( ...
        ["Zeitliche Datenverfügbarkeit"; ...
         "Interpolierte kurze Lücken"; ...
         "Ausgeschlossene Null-Plateau-Dauer"], ...
        [report.DataAvailability_percent; ...
         report.InterpolatedPoints; ...
         report.ExcludedZeroPlateau_h], ...
        ["%";"Messpunkte";"h"], ...
        'VariableNames', {'Kennwert','Wert','Einheit'});
end


function [T, report] = prepareWindMittel(filename, cfg)
    Traw = readWindFile(filename);
    columns = detectColumns(Traw, "mittel");
    S = buildStandardTable(Traw, columns);

    rawRows = height(S);
    invalidTime = sum(isnat(S.Time));
    S = S(~isnat(S.Time),:);
    if isempty(S)
        error("Die Datei %s enthält keine gültigen Zeitstempel.", filename);
    end

    S = sortrows(S,"Time");
    yearRef = mode(year(S.Time));
    tz = S.Time.TimeZone;
    yearStart = datetime(yearRef,1,1,'TimeZone',tz);
    yearEnd = datetime(yearRef+1,1,1,'TimeZone',tz);

    % Zeitstempel auf das erwartete 30-s-Raster runden.
    offset_s = seconds(S.Time - yearStart);
    S.Time = yearStart + seconds(round(offset_s/cfg.dtMittel_s)*cfg.dtMittel_s);
    S = S(S.Time >= yearStart & S.Time < yearEnd,:);
    S = sortrows(S,"Time");

    [~, ia] = unique(S.Time,'stable');
    duplicateCount = height(S) - numel(ia);
    S = S(ia,:);

    dtRaw = seconds(diff(S.Time));
    timeJumps = sum(dtRaw > 1.01*cfg.dtMittel_s);

    % Plausibilitätsprüfung vor der Einordnung in das Vollraster.
    invalidV = ~isfinite(S.WindSpeed) | ...
        S.WindSpeed < cfg.vMittelMin | S.WindSpeed > cfg.vMittelMax;
    S.WindSpeed(invalidV) = NaN;

    invalidP = ~isfinite(S.Power) | ...
        S.Power < cfg.powerMin | S.Power > cfg.powerMax;
    S.Power(invalidP) = NaN;

    invalidN = ~isfinite(S.RotorSpeed) | ...
        S.RotorSpeed < cfg.rotorSpeedMin | S.RotorSpeed > cfg.rotorSpeedMax;
    S.RotorSpeed(invalidN) = NaN;

    S.WindDirection(~isfinite(S.WindDirection)) = NaN;
    S.WindDirection = mod(S.WindDirection,360);

    fullTime = (yearStart:seconds(cfg.dtMittel_s): ...
        yearEnd-seconds(cfg.dtMittel_s))';
    N = numel(fullTime);

    vRaw = nan(N,1);
    wd = nan(N,1);
    p = nan(N,1);
    n = nan(N,1);
    status = strings(N,1);

    [isOnGrid, loc] = ismember(S.Time, fullTime);
    loc = loc(isOnGrid);
    Sg = S(isOnGrid,:);
    vRaw(loc) = Sg.WindSpeed;
    wd(loc) = Sg.WindDirection;
    p(loc) = Sg.Power;
    n(loc) = Sg.RotorSpeed;
    status(loc) = Sg.Status;

    [vInterpolated, interpolationMask] = ...
        interpolateShortGaps(vRaw, cfg.maxInterpolationPoints);

    zeroCandidate = isfinite(vInterpolated) & ...
        abs(vInterpolated) <= cfg.zeroTolerance_mps;
    zeroPlateauMask = selectLongRuns( ...
        zeroCandidate, cfg.minZeroPlateauPoints);

    vClean = vInterpolated;
    vClean(zeroPlateauMask) = NaN;

    T = table(fullTime, vRaw, vInterpolated, vClean, wd, p, n, status, ...
        interpolationMask, zeroPlateauMask, ...
        'VariableNames', {'Time','WindSpeedRaw','WindSpeedInterpolated', ...
        'WindSpeed','WindDirection','Power','RotorSpeed','Status', ...
        'Interpolated','ZeroPlateau'});

    report = table(rawRows, invalidTime, duplicateCount, timeJumps, N, ...
        sum(isfinite(vRaw)), sum(interpolationMask), sum(zeroPlateauMask), ...
        cfg.dtMittel_s*sum(zeroPlateauMask)/3600, sum(isfinite(vClean)), ...
        100*sum(isfinite(vClean))/N, ...
        'VariableNames', {'RawRows','InvalidTimestamps', ...
        'DuplicateTimestamps','TimeJumps','TheoreticalPoints', ...
        'OriginalValidWindPoints','InterpolatedPoints', ...
        'ExcludedZeroPlateauPoints','ExcludedZeroPlateau_h', ...
        'FinalValidWindPoints','DataAvailability_percent'});
end


function [T, report] = prepareWindMomentan(filename, cfg)
    Traw = readWindFile(filename);
    columns = detectColumns(Traw, "momentan");
    S = buildStandardTable(Traw, columns);

    rawRows = height(S);
    S = S(~isnat(S.Time),:);
    S = sortrows(S,"Time");
    [~, ia] = unique(S.Time,'stable');
    duplicateCount = height(S) - numel(ia);
    S = S(ia,:);

    valid = isfinite(S.WindSpeed) & ...
        S.WindSpeed >= cfg.vMomentanMin & ...
        S.WindSpeed <= cfg.vMomentanMax & ...
        isfinite(S.Power) & ...
        S.Power >= cfg.powerMin & S.Power <= cfg.powerMax & ...
        isfinite(S.RotorSpeed) & ...
        S.RotorSpeed >= cfg.rotorSpeedMin & ...
        S.RotorSpeed <= cfg.rotorSpeedMax;
    T = S(valid,:);

    if isempty(T)
        error("Nach der Plausibilitätsprüfung enthält %s keine gültigen Werte.", filename);
    end

    dt = seconds(diff(T.Time));
    timeJumps = sum(dt > 1.01*cfg.dtMomentan_s);
    report = table(rawRows, duplicateCount, height(T), timeJumps, ...
        min(T.Time), max(T.Time), ...
        'VariableNames', {'RawRows','DuplicateTimestamps','ValidPoints', ...
        'TimeJumps','FirstTimestamp','LastTimestamp'});
end


function T = readWindFile(filename)
    filename = string(filename);
    if ~isfile(filename)
        error("Datei nicht gefunden: %s", filename);
    end

    [~,~,ext] = fileparts(filename);
    if strcmpi(ext,'.csv')
        opts = detectImportOptions(filename, ...
            'FileType','text','VariableNamingRule','preserve');
        try
            opts.Delimiter = ';';
        catch
        end
        T = readtable(filename,opts);
    else
        opts = detectImportOptions(filename, ...
            'VariableNamingRule','preserve');
        T = readtable(filename,opts);
    end
    T.Properties.VariableNames = ...
        matlab.lang.makeValidName(T.Properties.VariableNames);
end


function columns = detectColumns(T, mode)
    names = string(T.Properties.VariableNames);
    low = lower(names);

    columns.Time = findByPattern(low, ...
        ["timestamp30s","timestamp2s","timestamp","time","zeit","datum"]);

    if mode == "momentan"
        columns.WindSpeed = findByPattern(low, ...
            ["vmomentan","v_momentan","momentan","windspeed"]);
    else
        columns.WindSpeed = findByPattern(low, ...
            ["v030mittel","v03","v30","v2mittel","v_mittel","windspeed"]);
    end

    columns.WindDirection = findByPattern(low, ...
        ["wricht_2mittel","wricht_2","wricht","windrichtung", ...
         "direction","richtung"]);
    columns.RotorSpeed = findByPattern(low, ...
        ["drehzahl_rm","drehzahl","rpm","rotorspeed"]);
    columns.Power = findByPattern(low, ...
        ["pdc_rm","pdc","leistung","power","pel"]);
    columns.Status = findByPattern(low, ...
        ["status","zustand","state"]);

    if columns.Time == 0
        error("Keine Zeitspalte erkannt.");
    end
    if columns.WindSpeed == 0
        error("Keine Windgeschwindigkeitsspalte erkannt.");
    end
end


function idx = findByPattern(lowNames, patterns)
    idx = 0;
    for pattern = patterns
        hit = find(contains(lowNames,pattern),1,'first');
        if ~isempty(hit)
            idx = hit;
            return;
        end
    end
end


function T = buildStandardTable(Traw, columns)
    N = height(Traw);
    time = parseTime(Traw{:,columns.Time});
    windSpeed = parseNumber(Traw{:,columns.WindSpeed});

    if columns.WindDirection > 0
        windDirection = parseNumber(Traw{:,columns.WindDirection});
    else
        windDirection = nan(N,1);
    end

    if columns.RotorSpeed > 0
        rotorSpeed = parseNumber(Traw{:,columns.RotorSpeed});
    else
        rotorSpeed = nan(N,1);
    end

    if columns.Power > 0
        power = parseNumber(Traw{:,columns.Power});
    else
        power = nan(N,1);
    end

    if columns.Status > 0
        status = string(Traw{:,columns.Status});
    else
        status = strings(N,1);
    end

    T = table(time(:),windSpeed(:),windDirection(:),rotorSpeed(:), ...
        power(:),status(:), ...
        'VariableNames',{'Time','WindSpeed','WindDirection', ...
        'RotorSpeed','Power','Status'});
end


function x = parseNumber(raw)
    if isnumeric(raw)
        x = double(raw);
    else
        x = str2double(strrep(string(raw),',','.'));
    end
    x = x(:);
end


function t = parseTime(raw)
    if isdatetime(raw)
        t = raw(:);
        return;
    end

    if isnumeric(raw)
        try
            t = datetime(raw,'ConvertFrom','excel');
        catch
            t = NaT(size(raw));
        end
        t = t(:);
        return;
    end

    s = strtrim(string(raw));
    t = NaT(size(s));
    formats = ["yyyy-MM-dd HH:mm:ss","dd.MM.yyyy HH:mm:ss", ...
        "yyyy-MM-dd'T'HH:mm:ss","MM/dd/yyyy HH:mm:ss"];

    for fmt = formats
        missing = isnat(t) & strlength(s)>0;
        if ~any(missing)
            break;
        end
        try
            candidate = datetime(s(missing),'InputFormat',fmt);
            t(missing) = candidate;
        catch
        end
    end

    missing = isnat(t) & strlength(s)>0;
    if any(missing)
        try
            t(missing) = datetime(s(missing));
        catch
        end
    end
    t = t(:);
end


function [filled, mask] = interpolateShortGaps(v, maxGapPoints)
    filled = v;
    mask = false(size(v));
    missing = isnan(v);
    [starts,ends] = runBounds(missing);

    for k = 1:numel(starts)
        len = ends(k)-starts(k)+1;
        left = starts(k)-1;
        right = ends(k)+1;
        if len <= maxGapPoints && left >= 1 && right <= numel(v) && ...
                isfinite(v(left)) && isfinite(v(right))
            values = linspace(v(left),v(right),len+2)';
            filled(starts(k):ends(k)) = values(2:end-1);
            mask(starts(k):ends(k)) = true;
        end
    end
end


function selected = selectLongRuns(logicalVector, minLength)
    selected = false(size(logicalVector));
    [starts,ends] = runBounds(logicalVector);
    for k = 1:numel(starts)
        if ends(k)-starts(k)+1 >= minLength
            selected(starts(k):ends(k)) = true;
        end
    end
end


function [starts,ends] = runBounds(logicalVector)
    logicalVector = logicalVector(:);
    d = diff([false; logicalVector; false]);
    starts = find(d==1);
    ends = find(d==-1)-1;
end


function plotDataQualityExample(T, cfg)
    if any(T.ZeroPlateau)
        mask = T.ZeroPlateau;
        labelText = 'ausgeschlossenes Null-Plateau';
    else
        mask = ~isfinite(T.WindSpeedRaw);
        labelText = 'Datenlücke';
    end

    [starts,ends] = runBounds(mask);
    if isempty(starts)
        idx = false(height(T),1);
        idx(1:min(height(T),24*120)) = true;
    else
        [~,k] = max(ends-starts+1);
        centerIndex = round((starts(k)+ends(k))/2);
        center = T.Time(centerIndex);
        idx = T.Time >= center-hours(2) & T.Time <= center+hours(2);
    end

    figure('Color','w','Name','Kurzes Beispiel Datenqualität');
    plot(T.Time(idx),T.WindSpeedRaw(idx),'.-', ...
        'DisplayName','Rohwert');
    hold on;
    plot(T.Time(idx),T.WindSpeed(idx),'-','LineWidth',1.5, ...
        'DisplayName','für Auswertung verwendeter Wert');
    yline(cfg.zeroTolerance_mps,'--','Nulltoleranz');
    grid on; box on;
    xlabel('Zeit');
    ylabel('Windgeschwindigkeit [m/s]');
    title(sprintf('Beispielhafte Datenstelle: %s',labelText));
    legend('Location','best');
end


function stats = createWindStatistics(T, cfg)
    v = T.WindSpeed;
    valid = isfinite(v);
    stats = table( ...
        mean(v(valid)), median(v(valid)), ...
        sum(valid), sum(v(valid) >= cfg.vCutIn), ...
        'VariableNames', {'Mittelwert_mps','Median_mps', ...
        'GueltigeWerte','AnzahlOberhalbCutIn'});
end


function monthly = calcMonthlyStatistics(T)
    monthNames = ["Jan";"Feb";"Mrz";"Apr";"Mai";"Jun"; ...
        "Jul";"Aug";"Sep";"Okt";"Nov";"Dez"];
    monthNo = month(T.Time);
    meanWind = nan(12,1);
    medianWind = nan(12,1);
    availability = nan(12,1);
    validPoints = zeros(12,1);

    for m = 1:12
        idx = monthNo==m;
        values = T.WindSpeed(idx);
        valid = isfinite(values);
        validPoints(m) = sum(valid);
        availability(m) = 100*mean(valid);
        if any(valid)
            meanWind(m) = mean(values(valid));
            medianWind(m) = median(values(valid));
        end
    end

    monthly = table((1:12)',monthNames,meanWind,medianWind, ...
        availability,validPoints, ...
        'VariableNames',{'MonatNr','Monat','Mittelwert_mps', ...
        'Median_mps','Datenverfuegbarkeit_Prozent','GueltigeWerte'});
end


function plotWindAnalysis(T, monthly, cfg)
    TT = timetable(T.Time,T.WindSpeed,'VariableNames',{'WindSpeed'});
    daily = retime(TT,'daily','mean');
    v = T.WindSpeed(isfinite(T.WindSpeed));

    figure('Color','w','Name','Windangebot 2018', ...
        'Position',[100 100 1150 760]);
    tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

    nexttile;
    plot(daily.Time,daily.WindSpeed,'LineWidth',1.0);
    grid on; box on;
    xlabel('Datum');
    ylabel('Tagesmittel [m/s]');
    title('Tagesmittelwerte 2018');

    nexttile;
    bar(monthly.MonatNr,monthly.Mittelwert_mps);
    grid on; box on;
    xticks(1:12);
    xticklabels(monthly.Monat);
    ylabel('Monatsmittel [m/s]');
    title('Monatsmittelwerte');

    nexttile;
    hHistogramm = histogram(v,'BinWidth',0.5, ...
        'Normalization','probability', ...
        'DisplayName','Messwerte');
    hold on;
    hMedian = xline(median(v),':','LineWidth',1.5, ...
        'DisplayName',sprintf('Median: %.2f m/s',median(v)));
    hMittelwert = xline(mean(v),'-.','LineWidth',1.4, ...
        'DisplayName',sprintf('Mittelwert: %.2f m/s',mean(v)));
    hEinschalt = xline(cfg.vCutIn,'--','LineWidth',1.4, ...
        'DisplayName',sprintf('Einschaltgrenze: %.1f m/s',cfg.vCutIn));
    grid on; box on;
    xlabel('Windgeschwindigkeit [m/s]');
    ylabel('relative Häufigkeit [-]');
    title('Häufigkeitsverteilung');
    legend([hHistogramm,hMedian,hMittelwert,hEinschalt], ...
        'Location','northoutside','Orientation','horizontal', ...
        'NumColumns',2);

    nexttile;
    bar(monthly.MonatNr,monthly.Datenverfuegbarkeit_Prozent);
    ylim([0 100]);
    grid on; box on;
    xticks(1:12);
    xticklabels(monthly.Monat);
    ylabel('Datenverfügbarkeit [%]');
    title('Monatliche Datenverfügbarkeit');
end


function result = checkSingleAnswer(name, value, reference, tolerance)
    status = evaluateAnswer(value, reference, tolerance);
    result = table(string(name), value, string(status), ...
        'VariableNames', {'Aufgabe','Eingabe','Pruefung'});
end


function result = checkWindPowerTask(Ain, P5in, P10in, ratioIn, PbetzIn, cfg)
    refA = cfg.A;
    refP5 = 0.5*cfg.rho*cfg.A*5^3;
    refP10 = 0.5*cfg.rho*cfg.A*10^3;
    refRatio = refP10/refP5;
    refBetz = (16/27)*refP10;

    names = ["Rotorfläche";"Windleistung bei 5 m/s"; ...
        "Windleistung bei 10 m/s";"Leistungsverhältnis"; ...
        "Betz-Leistung bei 10 m/s"];
    values = [Ain; P5in; P10in; ratioIn; PbetzIn];
    refs = [refA; refP5; refP10; refRatio; refBetz];
    tolerances = [0.01; 1.0; 2.0; 0.02; 2.0];

    status = strings(numel(values),1);
    for i = 1:numel(values)
        status(i) = evaluateAnswer(values(i), refs(i), tolerances(i));
    end

    result = table(names, values, status, ...
        'VariableNames', {'Aufgabe','Eingabe','Pruefung'});
end


function status = evaluateAnswer(value, reference, tolerance)
    if ~isscalar(value) || ~isfinite(value)
        status = "nicht bearbeitet";
    elseif abs(value-reference) <= tolerance
        status = "korrekt";
    else
        status = "nicht korrekt";
    end
end


function result = plotWindRoseInternal(direction, speed)
    valid = isfinite(direction) & isfinite(speed);
    nDirectionalTotal = sum(valid);
    direction = mod(direction(valid),360);
    speed = speed(valid);

    calmMask = speed < 0.5;
    calmShare = 100*mean(calmMask);
    direction = direction(~calmMask);
    speed = speed(~calmMask);

    sectorWidth = 22.5;
    sectorIndex = floor(mod(direction+sectorWidth/2,360)/sectorWidth)+1;
    speedEdges = [0.5 1.5 2.5 4 6 8 10 Inf];
    speedLabels = {'0,5–1,5','1,5–2,5','2,5–4', ...
        '4–6','6–8','8–10','≥10'};
    speedIndex = discretize(speed,speedEdges);

    counts = zeros(16,numel(speedLabels));
    for i = 1:16
        for j = 1:numel(speedLabels)
            counts(i,j) = sum(sectorIndex==i & speedIndex==j);
        end
    end

    frequency = 100*counts/max(1,nDirectionalTotal);
    sectorFrequency = sum(frequency,2);
    highWindFrequency = sum(frequency(:,4:end),2);

    figure('Color','w','Name','Windrose 2018', ...
        'Position',[150 100 850 800]);
    ax = axes;
    hold(ax,'on');
    axis(ax,'equal');
    axis(ax,'off');
    colors = parula(numel(speedLabels));
    maxR = max(sum(frequency,2));
    if maxR==0
        maxR=1;
    end

    legendHandles = gobjects(numel(speedLabels),1);
    for i = 1:16
        cumulative = 0;
        centerDeg = (i-1)*sectorWidth;
        metAngles = linspace(centerDeg-sectorWidth/2, ...
            centerDeg+sectorWidth/2,16);
        plotAngles = deg2rad(90-metAngles);
        for j = 1:numel(speedLabels)
            r0 = cumulative;
            r1 = cumulative + frequency(i,j);
            x = [r0*cos(plotAngles), fliplr(r1*cos(plotAngles))];
            y = [r0*sin(plotAngles), fliplr(r1*sin(plotAngles))];
            h = patch(x,y,colors(j,:),'EdgeColor','w','LineWidth',0.3);
            if i==1
                legendHandles(j)=h;
            end
            cumulative = r1;
        end
    end

    radialTicks = linspace(0,maxR,5);
    theta = linspace(0,2*pi,240);
    for r = radialTicks(2:end)
        plot(r*cos(theta),r*sin(theta),':','Color',[0.45 0.45 0.45]);
        text(0,r,sprintf('%.1f %%',r), ...
            'VerticalAlignment','bottom','HorizontalAlignment','left');
    end

    labels = {'N','NE','E','SE','S','SW','W','NW'};
    angles = deg2rad(90-(0:45:315));
    for k = 1:numel(labels)
        text(1.12*maxR*cos(angles(k)), ...
            1.12*maxR*sin(angles(k)),labels{k}, ...
            'HorizontalAlignment','center','FontWeight','bold');
    end

    title(sprintf('Windrose 2018 | Schwachwind < 0,5 m/s: %.1f %%', ...
        calmShare));
    lgd = legend(legendHandles,speedLabels,'Location','eastoutside');
    lgd.Title.String = 'Windgeschwindigkeit [m/s]';

    sectorNames = ["N";"NNE";"NE";"ENE";"E";"ESE";"SE";"SSE"; ...
        "S";"SSW";"SW";"WSW";"W";"WNW";"NW";"NNW"];
    sectorTable = table(sectorNames,sectorFrequency,highWindFrequency, ...
        'VariableNames',{'Sektor','RelativeHaeufigkeit_Prozent', ...
        'AnteilAb4mps_Prozent'});

    result = struct;
    result.FrequencyMatrix_percent = frequency;
    result.SectorTable = sectorTable;
    result.CalmShare_percent = calmShare;
end


function result = checkWestSectorShare(value, sectorTable)
    wanted = ismember(sectorTable.Sektor, ["SW","WSW","W"]);
    reference = sum(sectorTable.RelativeHaeufigkeit_Prozent(wanted));
    result = checkSingleAnswer( ...
        "Anteil SW + WSW + W", value, reference, 0.2);
end


function C = binPower(v,p,binWidth,minPoints)
    if isempty(v)
        C = emptyPowerCurve();
        return;
    end

    upper = max(binWidth,ceil(max(v)/binWidth)*binWidth);
    edges = 0:binWidth:upper+binWidth;
    centers = edges(1:end-1)+binWidth/2;

    meanP = nan(size(centers));
    medianP = nan(size(centers));
    stdP = nan(size(centers));
    q25 = nan(size(centers));
    q75 = nan(size(centers));
    N = zeros(size(centers));

    for i = 1:numel(centers)
        idx = v>=edges(i) & v<edges(i+1);
        N(i) = sum(idx);
        if N(i)>=minPoints
            values = p(idx);
            meanP(i) = mean(values,'omitnan');
            medianP(i) = median(values,'omitnan');
            stdP(i) = std(values,'omitnan');
            q = quantile(values,[0.25 0.75]);
            q25(i)=q(1);
            q75(i)=q(2);
        end
    end

    validBins = N>=minPoints;
    C = table(centers(:),meanP(:),medianP(:),stdP(:), ...
        q25(:),q75(:),N(:),validBins(:), ...
        'VariableNames',{'vBin','meanP','medianP','stdP', ...
        'q25P','q75P','N','validBins'});
end


function C = emptyPowerCurve()
    C = table(zeros(0,1),zeros(0,1),zeros(0,1),zeros(0,1), ...
        zeros(0,1),zeros(0,1),zeros(0,1),false(0,1), ...
        'VariableNames',{'vBin','meanP','medianP','stdP', ...
        'q25P','q75P','N','validBins'});
end


function plotMeasuredOperatingBehaviour(T, cfg)
    mask = isfinite(T.WindSpeed) & isfinite(T.Power);
    sample = deterministicSample(find(mask),45000);

    figure('Color','w','Name','Gesamtes Betriebsverhalten 2017');
    scatter(T.WindSpeed(sample),T.Power(sample),6,'filled', ...
        'MarkerFaceAlpha',0.08,'MarkerEdgeAlpha',0.08);
    hold on;
    xline(cfg.vCutIn,'--', ...
        sprintf('Einschaltgrenze %.1f m/s',cfg.vCutIn),'LineWidth',1.4);
    grid on; box on;
    xlabel('Windgeschwindigkeit [m/s]');
    ylabel('Generatorleistung [W]');
    title('Gemessenes Betriebsverhalten einschließlich Stillständen');
    xlim([0 min(22,max(T.WindSpeed(mask)))]);
end


function C = calcPowerCurve(T, minPower, binWidth, cfg)
    validateattributes(minPower,{'numeric'},{'scalar','finite','nonnegative'});
    validateattributes(binWidth,{'numeric'},{'scalar','finite','positive'});

    mask = isfinite(T.WindSpeed) & isfinite(T.Power) & ...
        T.WindSpeed >= cfg.vCutIn & T.Power > minPower;

    C = binPower(T.WindSpeed(mask),T.Power(mask), ...
        binWidth,cfg.minPowerBinPoints);
end


function manufacturerCurve = createManufacturerCurveGTO()
    % Näherungsweise Digitalisierung der grünen GTO-Leistungskennlinie aus
    % der Herstellerbroschüre. Die Punkte bis 20 m/s wurden visuell aus dem
    % Diagramm übernommen. Sie dienen der Orientierung und sind keine
    % normativ vermessene Referenzkurve.
    windSpeed = [2.5;4;5;6;7;8;9;10;11;12.5;14;15;16;17;18;19;20];
    power = [0;15;45;90;160;260;380;540;730;1100;1400;1700; ...
        2050;2450;2900;3450;4000];
    manufacturerCurve = table(windSpeed,power, ...
        'VariableNames',{'Windgeschwindigkeit_mps','Leistung_W'});
end


function plotGenerationCurve(C, manufacturerCurve, minPower, binWidth, cfg)
    valid = C.validBins;
    if ~any(valid)
        error("Mit den gewählten Parametern sind keine ausreichend besetzten Klassen vorhanden.");
    end

    x = C.vBin(valid);
    y = C.meanP(valid);

    figure('Color','w','Name','Erzeugungskennlinie 2017', ...
        'Position',[150 120 900 620]);
    plot(x,y,'o-','LineWidth',1.8,'MarkerSize',4, ...
        'DisplayName','Messdaten: Klassenmittel');
    hold on;
    plot(manufacturerCurve.Windgeschwindigkeit_mps, ...
        manufacturerCurve.Leistung_W,'--','LineWidth',1.8, ...
        'DisplayName','Herstellerkennlinie (näherungsweise)');
    xline(cfg.vCutIn,'--','Einschaltgrenze', ...
        'HandleVisibility','off');
    grid on; box on;
    xlabel('Windgeschwindigkeit [m/s]');
    ylabel('Generatorleistung [W]');
    title(sprintf(['Erzeugungskennlinie: P > %.0f W, ' ...
        'Klassenbreite %.2f m/s'],minPower,binWidth));
    xlim([0 20.5]);
    legend('Location','northwest');
end


function summary = createPowerCurveSummary(C, minPower, binWidth)
    valid = C.validBins;
    if ~any(valid)
        summary = table(minPower,binWidth,0,NaN,NaN, ...
            'VariableNames',{'Mindestleistung_W','Klassenbreite_mps', ...
            'GueltigeKlassen','KleinsteKlassenbelegung', ...
            'GroessteKlassenbelegung'});
        return;
    end

    summary = table(minPower,binWidth,sum(valid), ...
        min(C.N(valid)),max(C.N(valid)), ...
        'VariableNames',{'Mindestleistung_W','Klassenbreite_mps', ...
        'GueltigeKlassen','KleinsteKlassenbelegung', ...
        'GroessteKlassenbelegung'});
end


function result = createPowerClassTable(C)
    valid = C.validBins;
    result = table(C.vBin(valid),C.meanP(valid),C.stdP(valid),C.N(valid), ...
        'VariableNames',{'Klassenmitte_mps','MittlereLeistung_W', ...
        'Standardabweichung_W','Messpunkte'});
end


function result = selectRepresentativePowerClass(C, targetWind)
    valid = C.validBins & isfinite(C.meanP);
    if ~any(valid)
        error("Keine gültige Leistungsklasse verfügbar.");
    end

    validRows = find(valid);
    [~,localIndex] = min(abs(C.vBin(valid)-targetWind));
    row = validRows(localIndex);

    result = table(C.vBin(row),C.meanP(row),C.N(row), ...
        'VariableNames',{'Windgeschwindigkeit_mps', ...
        'MittlereElektrischeLeistung_W','Messpunkte'});
end


function result = checkPowerClassTask(PwindIn, cpIn, point, cfg)

    v = point.Windgeschwindigkeit_mps;
    Pel = point.MittlereElektrischeLeistung_W;

    refPwind = 0.5*cfg.rho*cfg.A*v^3;
    refCp = Pel/refPwind;

    names = [ ...
        "Windleistung der Klasse"; ...
        "Elektrisch abgeleiteter Leistungsbeiwert"];

    values = [PwindIn; cpIn];
    refs = [refPwind; refCp];

    tolerances = [ ...
        max(2,0.01*refPwind); ...
        0.005];

    status = strings(2,1);

    for i = 1:2
        status(i) = evaluateAnswer( ...
            values(i),refs(i),tolerances(i));
    end

    result = table( ...
        names,values,status, ...
        'VariableNames', ...
        {'Aufgabe','Eingabe','Pruefung'});
end


function C = calcBinnedRelationship(v,y,binWidth,minPoints)
    valid = isfinite(v) & isfinite(y);
    v = v(valid);
    y = y(valid);

    edges = 0:binWidth:(ceil(max(v)/binWidth)*binWidth+binWidth);
    centers = edges(1:end-1)+binWidth/2;

    meanY=nan(size(centers));
    medianY=nan(size(centers));
    q25=nan(size(centers));
    q75=nan(size(centers));
    N=zeros(size(centers));

    for i=1:numel(centers)
        idx=v>=edges(i)&v<edges(i+1);
        N(i)=sum(idx);
        if N(i)>=minPoints
            values=y(idx);
            meanY(i)=mean(values,'omitnan');
            medianY(i)=median(values,'omitnan');
            q=quantile(values,[0.25 0.75]);
            q25(i)=q(1);
            q75(i)=q(2);
        end
    end

    validBins=N>=minPoints;
    C=table(centers(:),meanY(:),medianY(:),q25(:), ...
        q75(:),N(:),validBins(:), ...
        'VariableNames',{'vBin','meanY','medianY','q25', ...
        'q75','N','validBins'});
end


function plotMomentRelationships(T,powerCurve,speedCurve,cfg)
    sample = deterministicSample((1:height(T))',50000);
    figure('Color','w','Name','Momentandaten 2013', ...
        'Position',[100 150 1200 520]);
    tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

    nexttile;
    scatter(T.WindSpeed(sample),T.Power(sample),4,'filled', ...
        'MarkerFaceAlpha',0.04,'MarkerEdgeAlpha',0.04, ...
        'DisplayName','Rohdatenstichprobe');
    hold on;
    plotQuantileBand(powerCurve,'Elektrische Leistung [W]');
    xline(cfg.vCutIn,'--','Einschaltgrenze','HandleVisibility','off');
    xlabel('Windgeschwindigkeit [m/s]');
    title('Windgeschwindigkeit und Leistung');
    grid on; box on;

    nexttile;
    scatter(T.WindSpeed(sample),T.RotorSpeed(sample),4,'filled', ...
        'MarkerFaceAlpha',0.04,'MarkerEdgeAlpha',0.04, ...
        'DisplayName','Rohdatenstichprobe');
    hold on;
    plotQuantileBand(speedCurve,'Rotordrehzahl [min^{-1}]');
    xline(cfg.vCutIn,'--','Einschaltgrenze','HandleVisibility','off');
    xlabel('Windgeschwindigkeit [m/s]');
    title('Windgeschwindigkeit und Drehzahl');
    grid on; box on;
end


function plotQuantileBand(C,yLabelText)
    valid=C.validBins;
    x=C.vBin(valid);
    y=C.meanY(valid);
    q25=C.q25(valid);
    q75=C.q75(valid);

    fill([x;flipud(x)],[q25;flipud(q75)],[0.8 0.8 0.8], ...
        'FaceAlpha',0.4,'EdgeColor','none', ...
        'DisplayName','25–75-%-Quantil');
    plot(x,y,'-o','LineWidth',2,'MarkerSize',4, ...
        'DisplayName','Klassenmittel');
    ylabel(yLabelText);
    legend('Location','best');
end


function [D, filterReport] = prepareCpRawData(filename,cfg)
    % Spezielle Aufbereitung der Momentandaten für die
    % c_p,el-Lambda-Auswertung.

    % -------------------------------------------------------------
    % 1. Datei einlesen
    % -------------------------------------------------------------
    Traw = readWindFile(filename);
    columns = detectColumns(Traw, "momentan");
    S = buildStandardTable(Traw, columns);

    rawRows = height(S);

    % -------------------------------------------------------------
    % 2. Betriebsstatus U-Konstant auswählen
    % -------------------------------------------------------------
    statusText = lower(strtrim(string(S.Status)));

    statusMask = contains(statusText,"u-konstant") | ...
        contains(statusText,"u konstant") | ...
        contains(statusText,"ukonstant");

    statusCount = sum(statusMask);
    S = S(statusMask,:);

    if statusCount < cfg.cpMinBinPoints
        error(['Der Betriebsstatus U-Konstant wurde nicht in ausreichender ' ...
            'Anzahl erkannt. Prüfen Sie die Statusspalte.']);
    end

    % -------------------------------------------------------------
    % 3. Grundbereinigung und Plausibilitätsprüfung
    % -------------------------------------------------------------
    validBase = ~isnat(S.Time) & ...
        isfinite(S.WindSpeed) & ...
        isfinite(S.Power) & ...
        isfinite(S.RotorSpeed) & ...
        S.WindSpeed >= cfg.vMomentanMin & ...
        S.WindSpeed <= cfg.vMomentanMax & ...
        S.Power >= cfg.powerMin & ...
        S.Power <= cfg.powerMax & ...
        S.RotorSpeed >= cfg.rotorSpeedMin & ...
        S.RotorSpeed <= cfg.rotorSpeedMax;

    S = S(validBase,:);
    S = sortrows(S,"Time");

    [~,ia] = unique(S.Time,'stable');
    S = S(ia,:);

    afterCleaningCount = height(S);

    if isempty(S)
        error("Nach der Grundbereinigung sind keine geeigneten U-Konstant-Daten vorhanden.");
    end

    % -------------------------------------------------------------
    % 4. Zusammenhängende Betriebsabschnitte bestimmen
    % -------------------------------------------------------------
    dt = seconds(diff(S.Time));

    blockID = cumsum([1; dt > cfg.cpMaxGap_s]);

    blockIDs = unique(blockID);

    keepLong = false(height(S),1);
    longBlockCount = 0;

    for k = 1:numel(blockIDs)

        id = blockIDs(k);
        idx = find(blockID == id);

        duration_s = seconds( ...
            S.Time(idx(end)) - S.Time(idx(1)));

        if duration_s >= cfg.cpMinBlockDuration_s
            keepLong(idx) = true;
            longBlockCount = longBlockCount + 1;
        end
    end

    S.BlockID = blockID;
    S = S(keepLong,:);

    longBlockPoints = height(S);

    if isempty(S)
        error("Keine U-Konstant-Abschnitte mit mindestens einer Stunde Dauer gefunden.");
    end

    % -------------------------------------------------------------
    % 5. Zeitliche Synchronisierung
    %
    % Positiver Zeitversatz:
    % Wind bei t wird mit Leistung und Drehzahl bei t + 2 s kombiniert.
    % -------------------------------------------------------------
    Ssync = synchronizeCpSignals(S,cfg.cpLag_s);

    synchronizedCount = height(Ssync);

    % -------------------------------------------------------------
    % 6. Technische Herstellergrenzen
    % -------------------------------------------------------------
    technicalMask = ...
        Ssync.RotorSpeed <= cfg.cpMaxRotorSpeed_rpm & ...
        Ssync.Power <= cfg.cpMaxPower_W;

    technicalRemoved = sum(~technicalMask);

    Ssync = Ssync(technicalMask,:);

    % -------------------------------------------------------------
    % 7. Aggregation zu nicht überlappenden 30-s-Fenstern
    % -------------------------------------------------------------
    D30 = aggregateCp30s(Ssync,cfg);

    windowsBeforeOperatingFilter = height(D30);

    % -------------------------------------------------------------
    % 8. Analysespezifischer Betriebsfilter auf 30-s-Ebene
    % -------------------------------------------------------------
    operatingMask = ...
        D30.WindSpeed >= cfg.cpMinWind_mps & ...
        D30.Power > cfg.cpMinPower_W & ...
        D30.RotorSpeed >= cfg.cpMinRotorSpeed_rpm;

    D30 = D30(operatingMask,:);

    % -------------------------------------------------------------
    % 9. Schnelllaufzahl und c_p,el berechnen
    % -------------------------------------------------------------
    omega = 2*pi*D30.RotorSpeed/60;

    lambda = ...
        omega*cfg.R ./ D30.WindSpeed;

    meanWindPower = ...
        0.5*cfg.rho*cfg.A .* D30.MeanV3;

    cpEl = ...
        D30.Power ./ meanWindPower;

    % Nur mathematisch bzw. für die Lambda-Auswertung ungültige
    % Betriebspunkte ausschließen.
    % Es wird keine obere c_p-Grenze verwendet.
    validDerived = ...
        isfinite(lambda) & ...
        isfinite(cpEl) & ...
        lambda > 0 & ...
        lambda < cfg.cpLambdaMaxRaw & ...
        cpEl >= 0;

    D30 = D30(validDerived,:);
    omega = omega(validDerived);
    lambda = lambda(validDerived);
    meanWindPower = meanWindPower(validDerived);
    cpEl = cpEl(validDerived);

    % -------------------------------------------------------------
    % 10. Finale Ausgabetabelle
    % -------------------------------------------------------------
    D = D30;

    D.Omega = omega;
    D.Lambda = lambda;
    D.MeanWindPower = meanWindPower;
    D.CpEl = cpEl;

    finalCount = height(D);
    finalBlockCount = numel(unique(D.BlockID));

    aboveBetz = sum(D.CpEl > 16/27);
    aboveBetzShare = ...
        100*aboveBetz/max(1,finalCount);

    % -------------------------------------------------------------
    % Kompakte Übersicht der Aufbereitung
    % -------------------------------------------------------------
    filterReport = table( ...
        [ ...
        "U-Konstant Rohdaten"; ...
        "Nach Grundbereinigung"; ...
        "Abschnitte >= 1 h"; ...
        "Werte in Abschnitten >= 1 h"; ...
        "Nach Synchronisierung"; ...
        "Durch Herstellergrenzen entfernt"; ...
        "30-s-Fenster vor Betriebsfilter"; ...
        "Finale 30-s-Betriebspunkte"; ...
        "Beteiligte Betriebsabschnitte"; ...
        "Anteil oberhalb Betz" ...
        ], ...
        [ ...
        statusCount; ...
        afterCleaningCount; ...
        longBlockCount; ...
        longBlockPoints; ...
        synchronizedCount; ...
        technicalRemoved; ...
        windowsBeforeOperatingFilter; ...
        finalCount; ...
        finalBlockCount; ...
        aboveBetzShare ...
        ], ...
        [ ...
        "Messpunkte"; ...
        "Messpunkte"; ...
        "Abschnitte"; ...
        "Messpunkte"; ...
        "Messpunkte"; ...
        "Messpunkte"; ...
        "Fenster"; ...
        "Fenster"; ...
        "Abschnitte"; ...
        "%" ...
        ], ...
        'VariableNames',{'Kennwert','Wert','Einheit'});
end


function X = synchronizeCpSignals(S,lag_s)
    % Positive Verschiebung:
    % Wind bei t wird mit Leistung und Drehzahl bei t + lag_s kombiniert.

    targetTime = ...
        S.Time + seconds(lag_s);

    [hasPartner,loc] = ...
        ismember(targetTime,S.Time);

    sameBlock = false(height(S),1);

    rowsWithPartner = find(hasPartner);

    if ~isempty(rowsWithPartner)
        sameBlock(rowsWithPartner) = ...
            S.BlockID(rowsWithPartner) == ...
            S.BlockID(loc(rowsWithPartner));
    end

    keep = hasPartner & sameBlock;

    windRows = find(keep);
    plantRows = loc(keep);

    X = table( ...
        S.Time(windRows), ...
        S.WindSpeed(windRows), ...
        S.Power(plantRows), ...
        S.RotorSpeed(plantRows), ...
        S.BlockID(windRows), ...
        'VariableNames', ...
        {'Time','WindSpeed','Power','RotorSpeed','BlockID'});
end


function D30 = aggregateCp30s(S,cfg)
    % Synchronisierte 2-s-Werte werden auf feste
    % nicht überlappende 30-s-Fenster abgebildet.

    if isempty(S)
        error("Keine synchronisierten Daten für die 30-s-Aggregation vorhanden.");
    end

    S = sortrows(S,"Time");

    % Raster an Kalenderjahr ausrichten.
    origin = dateshift(S.Time(1),'start','year');

    windowNumber = floor( ...
        seconds(S.Time-origin) / ...
        cfg.cpAggregation_s);

    [G,blockKey,windowKey] = ...
        findgroups(S.BlockID,windowNumber);

    points = ...
        splitapply(@numel,S.WindSpeed,G);

    meanWind = ...
        splitapply(@mean,S.WindSpeed,G);

    meanPower = ...
        splitapply(@mean,S.Power,G);

    meanRotorSpeed = ...
        splitapply(@mean,S.RotorSpeed,G);

    % Energetisch entscheidende Größe:
    % zuerst v^3 bilden, anschließend mitteln.
    meanV3 = ...
        splitapply(@(x) mean(x.^3),S.WindSpeed,G);

    windowStart = ...
        origin + ...
        seconds(windowKey*cfg.cpAggregation_s);

    D30 = table( ...
        windowStart, ...
        meanWind, ...
        meanPower, ...
        meanRotorSpeed, ...
        meanV3, ...
        blockKey, ...
        points, ...
        'VariableNames', ...
        {'Time','WindSpeed','Power','RotorSpeed', ...
        'MeanV3','BlockID','Points'});

    % Mindestens 80 % der theoretischen 15 Werte:
    % mindestens 12 Messpunkte je 30-s-Fenster.
    keep = ...
        D30.Points >= cfg.cpMinWindowPoints;

    D30 = D30(keep,:);
end


function [results,maxima,filterReport,D] = ...
        calcCpLambdaSensitivity(filename,cfg)

    [D,filterReport] = ...
        prepareCpRawData(filename,cfg);

    lambda = D.Lambda;
    cpEl = D.CpEl;

    widths = cfg.cpBinWidths;

    results = struct([]);

    maxima = table( ...
        'Size',[numel(widths) 4], ...
        'VariableTypes', ...
        {'double','double','double','double'}, ...
        'VariableNames', ...
        {'DeltaLambda','LambdaAmMaximum', ...
        'CpElMaximum','GueltigeKlassen'});

    for k = 1:numel(widths)

        width = widths(k);

        edges = ...
            0:width:cfg.cpLambdaPlotMax;

        centers = ...
            edges(1:end-1) + width/2;

        med = nan(size(centers));
        q25 = nan(size(centers));
        q75 = nan(size(centers));
        N = zeros(size(centers));

        for i = 1:numel(centers)

            idx = ...
                lambda >= edges(i) & ...
                lambda < edges(i+1);

            N(i) = sum(idx);

            if N(i) >= cfg.cpMinBinPoints

                values = cpEl(idx);

                med(i) = ...
                    median(values,'omitnan');

                q = ...
                    quantile(values,[0.25 0.75]);

                q25(i) = q(1);
                q75(i) = q(2);
            end
        end

        % Kein zusätzlicher Mindestwert des Medians.
        validBins = ...
            N >= cfg.cpMinBinPoints & ...
            isfinite(med);

        if any(validBins)

            validCenters = ...
                centers(validBins);

            validMed = ...
                med(validBins);

            [maxCp,idxMax] = ...
                max(validMed);

            lambdaMax = ...
                validCenters(idxMax);

        else
            maxCp = NaN;
            lambdaMax = NaN;
        end

        results(k).DeltaLambda = width;

        results(k).Curve = table( ...
            centers(:), ...
            med(:), ...
            q25(:), ...
            q75(:), ...
            N(:), ...
            validBins(:), ...
            'VariableNames', ...
            {'lambdaBin','cpElMedian', ...
            'cpElQ25','cpElQ75','N','validBins'});

        results(k).LambdaAtMaximum = ...
            lambdaMax;

        results(k).CpElMaximum = ...
            maxCp;

        maxima{k,:} = ...
            [width,lambdaMax,maxCp,sum(validBins)];
    end
end


function result = selectCpOperatingPoint( ...
        D,targetWind,halfWidth,cfg)

    % Zunächst Betriebspunkte in der Umgebung des Zielwerts suchen.
    idx = ...
        abs(D.WindSpeed-targetWind) <= halfWidth;

    candidates = find(idx);

    if isempty(candidates)

        [~,nearest] = ...
            min(abs(D.WindSpeed-targetWind));

        candidates = nearest;
    end

    % Einen realen 30-s-Betriebspunkt wählen, dessen c_p,el
    % möglichst nahe am Median der Kandidaten liegt.
    medianCp = ...
        median(D.CpEl(candidates),'omitnan');

    cpDistance = ...
        abs(D.CpEl(candidates)-medianCp);

    windDistance = ...
        abs(D.WindSpeed(candidates)-targetWind);

    scores = ...
        [cpDistance,windDistance];

    [~,order] = ...
        sortrows(scores,[1 2]);

    row = candidates(order(1));

    result = table( ...
        D.WindSpeed(row), ...
        D.RotorSpeed(row), ...
        D.Power(row), ...
        D.MeanV3(row), ...
        cfg.R, ...
        D.Points(row), ...
        'VariableNames', ...
        {'Windgeschwindigkeit_mps', ...
        'MittlereDrehzahl_rpm', ...
        'MittlereElektrischeLeistung_W', ...
        'Mittelwert_v3', ...
        'Rotorradius_m', ...
        'Messpunkte'});
end


function result = checkMomentCalculationTask( ...
        omegaIn,uIn,lambdaIn,PwindIn,cpIn,point,cfg)

    v = ...
        point.Windgeschwindigkeit_mps;

    n = ...
        point.MittlereDrehzahl_rpm;

    Pel = ...
        point.MittlereElektrischeLeistung_W;

    meanV3 = ...
        point.Mittelwert_v3;

    refOmega = ...
        2*pi*n/60;

    refU = ...
        refOmega*cfg.R;

    refLambda = ...
        refU/v;

    % Nicht v^3 der mittleren Windgeschwindigkeit verwenden.
    refPwind = ...
        0.5*cfg.rho*cfg.A*meanV3;

    refCp = ...
        Pel/refPwind;

    names = [ ...
        "Winkelgeschwindigkeit"; ...
        "Blattspitzengeschwindigkeit"; ...
        "Schnelllaufzahl"; ...
        "Windleistung"; ...
        "Elektrisch abgeleiteter Leistungsbeiwert"];

    values = [ ...
        omegaIn; ...
        uIn; ...
        lambdaIn; ...
        PwindIn; ...
        cpIn];

    refs = [ ...
        refOmega; ...
        refU; ...
        refLambda; ...
        refPwind; ...
        refCp];

    tolerances = [ ...
        0.1; ...
        0.1; ...
        0.03; ...
        max(2,0.01*refPwind); ...
        0.005];

    status = strings(numel(values),1);

    for i = 1:numel(values)

        status(i) = ...
            evaluateAnswer( ...
            values(i),refs(i),tolerances(i));
    end

    result = table( ...
        names,values,status, ...
        'VariableNames', ...
        {'Aufgabe','Eingabe','Pruefung'});
end


function plotCpLambda(results,D,cfg)

    widths = ...
        [results.DeltaLambda];

    [~,mainIndex] = ...
        min(abs(widths-0.50));

    main = ...
        results(mainIndex);

    C = ...
        main.Curve;

    valid = ...
        C.validBins;

    % =============================================================
    % Hauptdarstellung Delta-Lambda = 0.50
    % =============================================================
    figure( ...
        'Color','w', ...
        'Name','c_p,el-Lambda Hauptkennlinie');

    rawPlot = ...
        D.Lambda >= 0 & ...
        D.Lambda <= cfg.cpLambdaPlotMax & ...
        isfinite(D.CpEl);

    scatter( ...
        D.Lambda(rawPlot), ...
        D.CpEl(rawPlot), ...
        6,'filled', ...
        'MarkerFaceAlpha',0.08, ...
        'MarkerEdgeAlpha',0.08, ...
        'DisplayName','30-s-Betriebspunkte');

    hold on;

    x = ...
        C.lambdaBin(valid);

    y = ...
        C.cpElMedian(valid);

    q25 = ...
        C.cpElQ25(valid);

    q75 = ...
        C.cpElQ75(valid);

    errorbar( ...
        x,y, ...
        y-q25, ...
        q75-y, ...
        'o-', ...
        'LineWidth',1.5, ...
        'MarkerSize',4, ...
        'DisplayName', ...
        'Median mit 25-%-/75-%-Quantil');

    plot( ...
        main.LambdaAtMaximum, ...
        main.CpElMaximum, ...
        '^', ...
        'MarkerSize',8, ...
        'LineWidth',1.5, ...
        'DisplayName','empirisches Maximum');

    yline( ...
        16/27, ...
        '--', ...
        'Betz-Grenze', ...
        'DisplayName','Betz-Grenze');

    grid on;
    box on;

    xlim([0 cfg.cpLambdaPlotMax]);

    if any(rawPlot)

        yMax = ...
            max(D.CpEl(rawPlot));

        ylim([0 max(0.65,1.05*yMax)]);

    else
        ylim([0 0.65]);
    end

    xlabel('\lambda [-]');
    ylabel('c_{p,el} [-]');

    title( ...
        '\Delta\lambda = 0,50: 30-s-Betriebspunkte und Kennlinie');

    legend('Location','northwest');

    % =============================================================
    % Vergleich der Klassenbreiten
    % =============================================================
    figure( ...
        'Color','w', ...
        'Name','Vergleich der Lambda-Klassenbreiten');

    hold on;

    maximumCurveValue = 16/27;

    for k = 1:numel(results)

        Ck = ...
            results(k).Curve;

        validK = ...
            Ck.validBins;

        plot( ...
            Ck.lambdaBin(validK), ...
            Ck.cpElMedian(validK), ...
            '-o', ...
            'LineWidth',1.5, ...
            'MarkerSize',3, ...
            'DisplayName', ...
            sprintf('\\Delta\\lambda = %.2f', ...
            results(k).DeltaLambda));

        if any(validK)
            maximumCurveValue = max( ...
                maximumCurveValue, ...
                max(Ck.cpElMedian(validK)));
        end
    end

    yline( ...
        16/27, ...
        '--', ...
        'Betz-Grenze', ...
        'HandleVisibility','off');

    grid on;
    box on;

    xlim([0 cfg.cpLambdaPlotMax]);

    ylim([0 max(0.65,1.1*maximumCurveValue)]);

    xlabel('\lambda [-]');
    ylabel('Median von c_{p,el} [-]');

    title('Einfluss der \lambda-Klassenbreite');

    legend('Location','northwest');
end


function example = createEnergyExample(T,cfg,nIntervals)

    t = T.Time;
    dt = seconds(diff(t));

    % Für die Beispielrechnung werden nur zusammenhängende Intervalle
    % mit gültiger Windgeschwindigkeit und positiver elektrischer
    % Generatorleistung verwendet.
    valid = ...
        abs(dt-cfg.dtMittel_s) <= 0.5 & ...
        isfinite(T.Power(1:end-1)) & ...
        T.Power(1:end-1) > cfg.powerActiveMin_W & ...
        isfinite(T.WindSpeed(1:end-1));

    % Zusammenhängende gültige Bereiche bestimmen.
    [starts,ends] = runBounds(valid);

    selected = [];

    for k = 1:numel(starts)

        blockLength = ends(k)-starts(k)+1;

        if blockLength >= nIntervals

            selected = ...
                (starts(k):starts(k)+nIntervals-1)';

            break;
        end
    end

    if isempty(selected)
        error(['Keine zusammenhängende Folge von %d Intervallen mit ' ...
            'positiver Generatorleistung gefunden.'],nIntervals);
    end

    example = table( ...
        T.Time(selected), ...
        T.Power(selected), ...
        T.WindSpeed(selected), ...
        dt(selected), ...
        'VariableNames', ...
        {'Startzeit', ...
         'ElektrischeLeistung_W', ...
         'Windgeschwindigkeit_mps', ...
         'Intervall_s'});
end


function result = checkEnergyExample(value, example)
    reference = sum(example.ElektrischeLeistung_W .* ...
        example.Intervall_s)/3600;
    result = checkSingleAnswer( ...
        "Elektrische Energie der Beispielintervalle", ...
        value, reference, max(0.001,0.01*reference));
end


function result = calcEnergyCommonIntervals(T, cfg)
    t = T.Time;
    dt = seconds(diff(t));
    v = T.WindSpeed(1:end-1);
    p = T.Power(1:end-1);

    valid = abs(dt-cfg.dtMittel_s)<=0.5 & ...
        isfinite(v) & isfinite(p) & p>=0;

    dtValid = dt(valid);
    pValid = p(valid);
    vValid = v(valid);
    pWind = 0.5*cfg.rho*cfg.A.*vValid.^3;

    Eel_kWh = sum(pValid.*dtValid)/3.6e6;
    Ewind_kWh = sum(pWind.*dtValid)/3.6e6;
    integrated_h = sum(dtValid)/3600;

    y = year(t(find(~isnat(t),1,'first')));
    tz = t.TimeZone;
    yearHours = hours(datetime(y+1,1,1,'TimeZone',tz) - ...
        datetime(y,1,1,'TimeZone',tz));

    validPointMask = isfinite(T.WindSpeed) & ...
        isfinite(T.Power) & T.Power>=0;
    zeroShare = 100*mean(T.Power(validPointMask)==0);

    aboveCutIn = validPointMask & T.WindSpeed>=cfg.vCutIn;
    if any(aboveCutIn)
        zeroShareAbove = 100*mean(T.Power(aboveCutIn)==0);
    else
        zeroShareAbove = NaN;
    end

    if Ewind_kWh > 0
        ratio = 100*Eel_kWh/Ewind_kWh;
    else
        ratio = NaN;
    end

    result = table(integrated_h,100*integrated_h/yearHours, ...
        Eel_kWh,Ewind_kWh,ratio,zeroShare,zeroShareAbove, ...
        'VariableNames',{'IntegrierteZeit_h','Intervallabdeckung_Prozent', ...
        'ElektrischeEnergie_kWh','TheoretischeWindenergie_kWh', ...
        'ElektrischZuWind_Prozent','Nullleistungsanteil_Prozent', ...
        'NullleistungsanteilOberhalbCutIn_Prozent'});
end


function available = hasWeibullFunctions()
    available = exist('wblfit','file')==2 && exist('wblpdf','file')==2;
end


function result = fitAndPlotWeibull(windSpeed,cfg)
    if ~hasWeibullFunctions()
        error('Die Statistics and Machine Learning Toolbox ist nicht verfügbar.');
    end

    v = windSpeed(isfinite(windSpeed) & windSpeed>0);

    parameters = wblfit(v);
    a = parameters(1);
    k = parameters(2);

    x = linspace(0,max(12,ceil(max(v))),1000);
    y = wblpdf(x,a,k);

    figure('Color','w','Name','Weibull-Verteilung 2018');

    histogram(v, ...
        'BinWidth',0.5, ...
        'Normalization','pdf', ...
        'DisplayName','Messdaten');

    hold on;

    plot(x,y, ...
        'LineWidth',2, ...
        'DisplayName','Weibull-Anpassung');

    xline(cfg.vCutIn,'--','Einschaltgrenze', ...
        'HandleVisibility','off');

    grid on;
    box on;

    xlabel('Windgeschwindigkeit [m/s]');
    ylabel('Wahrscheinlichkeitsdichte [(m/s)^{-1}]');
    title('Messdaten und angepasste Weibull-Verteilung');

    legend('Location','best');

    result = table(k,a, ...
        'VariableNames', ...
        {'Formparameter_k','Skalenparameter_a_mps'});
end


function result = checkWeibullTask(f3In,f6In,parameters)
    k = parameters.Formparameter_k;
    a = parameters.Skalenparameter_a_mps;

    v3 = 3;
    v6 = 6;

    refF3 = (k/a) * (v3/a)^(k-1) * exp(-(v3/a)^k);
    refF6 = (k/a) * (v6/a)^(k-1) * exp(-(v6/a)^k);

    names = [ ...
        "Weibull-Dichte bei v = 3 m/s"; ...
        "Weibull-Dichte bei v = 6 m/s"];

    values = [f3In; f6In];
    refs = [refF3; refF6];

    tolerances = [0.002; 0.002];

    status = strings(2,1);

    for i = 1:2
        status(i) = evaluateAnswer( ...
            values(i), refs(i), tolerances(i));
    end

    result = table(names,values,status, ...
        'VariableNames',{'Aufgabe','Eingabe','Pruefung'});
end


function result = checkHeightTask(value)
    v1 = 4.0;
    h1 = 10;
    h2 = 30;
    z0 = 0.5;
    d = 0;
    reference = v1*log((h2-d)/z0)/log((h1-d)/z0);
    result = checkSingleAnswer( ...
        "Windgeschwindigkeit in 30 m Höhe",value,reference,0.02);
end


function showIntegratedMusterloesung(windStats, monthly, sectorTable, ...
        powerClass, cpPoint, cpMaxima, energyExample, energyResult, ...
        weibullParameters, cfg)
    disp(" ");
    disp("============================================================");
    disp("INTEGRIERTE MUSTERLÖSUNG ZUR SELBSTKONTROLLE");
    disp("============================================================");
    disp("Die Lösungen folgen der Reihenfolge des Live-Skripts.");

    shareCutIn = 100*windStats.AnzahlOberhalbCutIn / windStats.GueltigeWerte;
    A = pi*(cfg.D/2)^2;
    P5 = 0.5*cfg.rho*A*5^3;
    P10 = 0.5*cfg.rho*A*10^3;
    ratio = P10/P5;
    Pbetz10 = (16/27)*P10;

    wanted = ismember(sectorTable.Sektor,["SW","WSW","W"]);
    westShare = sum(sectorTable.RelativeHaeufigkeit_Prozent(wanted));

    vClass = powerClass.Windgeschwindigkeit_mps;
    PelClass = powerClass.MittlereElektrischeLeistung_W;
    PwindClass = 0.5*cfg.rho*cfg.A*vClass^3;
    cpClass = PelClass/PwindClass;

    vCp = cpPoint.Windgeschwindigkeit_mps;
    nCp = cpPoint.MittlereDrehzahl_rpm;
    PelCp = cpPoint.MittlereElektrischeLeistung_W;
    meanV3Cp = cpPoint.Mittelwert_v3;
    
    omega = 2*pi*nCp/60;
    uTip = omega*cfg.R;
    lambda = uTip/vCp;
    
    PwindCp = 0.5*cfg.rho*cfg.A*meanV3Cp;
    cpEl = PelCp/PwindCp;

    [~,iMax] = max(monthly.Mittelwert_mps,[],'omitnan');
    [~,iMin] = min(monthly.Mittelwert_mps,[],'omitnan');
    [~,iDom] = max(sectorTable.RelativeHaeufigkeit_Prozent);

    solutionHeading("1 Datenbasis");
    possibleAnswer(1, ...
        "Die Datenverfügbarkeit von 2018 ist hoch und über die Monate ausreichend verteilt. Damit ist eine saisonale Auswertung grundsätzlich möglich.");
    possibleAnswer(2, ...
        "Fehlen Messwerte überwiegend in einer Jahreszeit, wird diese im Jahresmittel und im saisonalen Vergleich unterrepräsentiert. Dadurch können Mittelwerte verzerrt werden.");

    solutionHeading("2 Windangebot 2018");
    calculationSolution("2.1 Anteil oberhalb der Einschaltwindgeschwindigkeit", ...
        "Anteil = 100 * N(v >= v_ci) / N_gueltig", ...
        shareCutIn, "%");

    disp(" ");
    disp("2.2 Windleistung und Betz-Grenze");
    calculationSolution("Rotorfläche", ...
        "A = pi * (D/2)^2", A, "m^2");
    calculationSolution("Windleistung bei 5 m/s", ...
        "P_Wind = 0.5 * rho * A * 5^3", P5, "W");
    calculationSolution("Windleistung bei 10 m/s", ...
        "P_Wind = 0.5 * rho * A * 10^3", P10, "W");
    calculationSolution("Leistungsverhältnis", ...
        "P_Wind,10 / P_Wind,5", ratio, "-");
    calculationSolution("Betz-Leistung bei 10 m/s", ...
        "P_Betz = (16/27) * P_Wind,10", Pbetz10, "W");

    disp(" ");
    disp("2.3 Mögliche Antworten zur Interpretation");
    fprintf([ ...
        '1. Windreichster Monat: %s (%.2f m/s; ' ...
        'Datenverfügbarkeit %.1f %%). ' ...
        'Windärmster Monat: %s (%.2f m/s; ' ...
        'Datenverfügbarkeit %.1f %%).\n'], ...
        char(monthly.Monat(iMax)), ...
        monthly.Mittelwert_mps(iMax), ...
        monthly.Datenverfuegbarkeit_Prozent(iMax), ...
        char(monthly.Monat(iMin)), ...
        monthly.Mittelwert_mps(iMin), ...
        monthly.Datenverfuegbarkeit_Prozent(iMin));
    possibleAnswer(2, ...
        "Die Monatsmittel zeigen ein höheres Windniveau vor allem im Winter und frühen Frühjahr sowie niedrigere Werte im Spätsommer und Herbst. Die Monatswerte sind gemeinsam mit der Datenverfügbarkeit zu beurteilen.");
    possibleAnswer(3, ...
        "Die Betz-Grenze besagt, dass ein idealer Rotor höchstens 16/27 beziehungsweise rund 59,3 % der Windleistung entnehmen kann. Die Luft muss den Rotor weiterhin durchströmen und kann daher nicht vollständig abgebremst werden.");
    possibleAnswer(4, ...
        "Die Windleistung hängt von v^3 ab. Deshalb ist der Mittelwert der dritten Potenz nicht gleich der dritten Potenz des Mittelwerts. Wenige hohe Windgeschwindigkeiten wirken überproportional stark.");
    possibleAnswer(5, ...
        "Nein. Oberhalb der Einschaltwindgeschwindigkeit können Stillstände, Anfahrvorgänge, Regelungseingriffe oder Unterschiede zwischen Sensor- und Rotoranströmung weiterhin zu fehlender elektrischer Leistung führen.");

    solutionHeading("3 Windrichtungsverteilung 2018");
    calculationSolution("3.1 Anteil SW + WSW + W", ...
        "H_West = H_SW + H_WSW + H_W", westShare, "%");
    disp(" ");
    disp("3.2 Mögliche Antworten zur Windrose");
    fprintf('1. Häufigster einzelner Sektor: %s. Der dominierende zusammenhängende Bereich liegt im westlichen bis südwestlichen Sektor.\n', ...
        char(sectorTable.Sektor(iDom)));
    possibleAnswer(2, ...
        "Die Windgeschwindigkeiten ab 4 m/s treten ebenfalls überwiegend aus dem westlichen bis südwestlichen Hauptbereich auf. Die genaue Gewichtung der einzelnen Richtungssektoren unterscheidet sich jedoch von der Gesamthäufigkeit.");
    possibleAnswer(3, ...
        "Mögliche Einflüsse sind Gebäudeform, Dachkanten, umliegende Bebauung, Gelände, Messhöhe und Position des Windsensors.");
    possibleAnswer(4, ...
        "Die Windrose zeigt die Herkunftsrichtung und die richtungsabhängige Geschwindigkeitsverteilung. Ein Monatsmittel enthält diese räumliche Information nicht.");

    solutionHeading("4 Leistungskennlinie 2017");
    disp("4.1 Mögliche Beobachtungen bei der Parametervariation");
    possibleAnswer(1, ...
        "Eine höhere Mindestleistung entfernt schwache Erzeugungszustände. Besonders im unteren Windbereich kann die gefilterte Kennlinie dadurch ansteigen und später beginnen.");
    possibleAnswer(2, ...
        "Eine größere Klassenbreite glättet die Kennlinie und erhöht häufig die Belegung je Klasse, reduziert jedoch die Auflösung lokaler Änderungen.");

    disp(" ");
    disp("4.2 Elektrisch abgeleiteter Leistungsbeiwert der Klasse nahe 10 m/s");
    fprintf('Gegebene Klassenmitte: %.2f m/s\n',vClass);
    fprintf('Mittlere elektrische Leistung: %.2f W\n',PelClass);
    calculationSolution("Theoretische Windleistung", ...
        "P_Wind = 0.5 * rho * A * v_Klasse^3", PwindClass, "W");
    calculationSolution("Elektrisch abgeleiteter Leistungsbeiwert", ...
        "c_p,el = P_el / P_Wind", cpClass, "-");

    disp(" ");
    disp("4.3 Mögliche Antworten zur Leistungskennlinie");
    possibleAnswer(1, ...
        "Der erkennbare Leistungsanstieg beginnt ungefähr im Bereich zwischen 3 und 4 m/s und damit etwas oberhalb der Einschaltwindgeschwindigkeit von 2,5 m/s. Wegen Anfahrvorgängen, Regelung und Messstreuung besteht kein einzelner scharfer Übergang.");
    possibleAnswer(2, ...
        "Die Erzeugungskennlinie enthält nur ausgewählte aktive Zustände. Stillstände und Nullleistung werden entfernt, wodurch sie besonders im unteren Windbereich oberhalb des vollständigen Betriebsverhaltens liegt.");
    possibleAnswer(3, ...
        "Bei 50 W werden zusätzliche schwache Erzeugungszustände ausgeschlossen. Der untere Kennlinienbereich verschiebt sich dadurch nach oben und kann später beginnen.");
    possibleAnswer(4, ...
        "Bei 1,0 m/s wird die Kurve glatter, einzelne lokale Änderungen sind jedoch schlechter aufgelöst.");
    possibleAnswer(5, ...
        "Hohe Windgeschwindigkeitsklassen sind häufig schwach besetzt. Ihre Mittelwerte reagieren deshalb stärker auf einzelne Betriebszustände und sind vorsichtiger zu interpretieren.");
    possibleAnswer(6, ...
        "Abweichungen zur Herstellerkennlinie entstehen durch andere Messbedingungen, Luftdichte, Mittelungszeiten, Sensorposition, Anlagenzustände, Regelung und Filterung. Die digitalisierte Herstellerlinie ist zudem nur eine Näherung.");
    possibleAnswer(7, ...
        "c_p,el enthält aerodynamische, mechanische und elektrische Verluste sowie Regelungseinflüsse und Messabweichungen. Er ist kein rein aerodynamischer Rotorleistungsbeiwert.");

    solutionHeading("5 Kurzfristiges Anlagenverhalten 2013");
    disp("5.1 Mögliche Antworten");
    possibleAnswer(1, ...
        "Ja. Das Drehzahldiagramm zeigt Rotationszustände bereits unterhalb der elektrischen Einschaltwindgeschwindigkeit.");
    possibleAnswer(2, ...
        "Der erkennbare elektrische Leistungsanstieg beginnt ungefähr zwischen 3 und 4 m/s und damit später als die erste Rotorbewegung. Rotation und nutzbare elektrische Erzeugung sind daher nicht gleichzusetzen.");
    possibleAnswer(3, ...
        "Bei höheren Windgeschwindigkeiten flacht der Drehzahlverlauf ab. Wahrscheinlich begrenzt die Anlagenregelung die weitere Drehzahlzunahme.");
    possibleAnswer(4, ...
        "Mögliche Ursachen sind Turbulenz, zeitlicher Versatz der Signale, unterschiedliche Betriebszustände, Sensorposition, Regelungseingriffe und Messunsicherheiten.");

    solutionHeading("6 Schnelllaufzahl und elektrisch abgeleiteter Leistungsbeiwert");
    disp("6.1 Rechenlösung für den realen Betriebspunkt");
    fprintf('Windgeschwindigkeit: %.3f m/s\n',vCp);
    fprintf('Mittlere Drehzahl: %.3f min^-1\n',nCp);
    fprintf('Mittlere elektrische Leistung: %.3f W\n',PelCp);
    calculationSolution("Winkelgeschwindigkeit", ...
        "omega = 2*pi*n/60", omega, "rad/s");
    calculationSolution("Blattspitzengeschwindigkeit", ...
        "u_Spitze = omega * R", uTip, "m/s");
    calculationSolution("Schnelllaufzahl", ...
        "lambda = u_Spitze / v", lambda, "-");
    calculationSolution("Theoretische Windleistung", ...
        "P_Wind = 0.5 * rho * A * Mittelwert(v^3)", PwindCp, "W");
    calculationSolution("Elektrisch abgeleiteter Leistungsbeiwert", ...
        "c_p,el = P_el / P_Wind", cpEl, "-");

    disp(" ");
    disp("6.2 Empirische Maxima der c_p,el-Lambda-Kennlinie");
    disp(cpMaxima);

    disp(" ");
    disp("6.3 Mögliche Antworten zur Kennlinie");
    possibleAnswer(1, ...
       "Der manuell berechnete 30-s-Betriebspunkt sollte in der Nähe der klassenweise gebildeten Kennlinie liegen. Abweichungen entstehen, weil er einen einzelnen Betriebspunkt darstellt, während die Kennlinie den Median vieler Betriebspunkte einer Lambda-Klasse beschreibt. Zusätzlich streuen die Messwerte.");
    possibleAnswer(2, ...
        "Delta-Lambda = 0,25 besitzt die höchste Auflösung. Delta-Lambda = 1,00 glättet am stärksten.");
    possibleAnswer(3, ...
        "Die Lage des Maximums ist üblicherweise stabiler als seine absolute Höhe. Daher ist der günstige Schnelllaufzahlbereich belastbarer als ein einzelner maximaler c_p,el-Wert.");
    possibleAnswer(4, ...
        "Der Median ist gegenüber einzelnen Ausreißern robuster als der Mittelwert und beschreibt bei stark streuenden Daten den typischen Klassenwert besser.");
    possibleAnswer(5, ...
        "Einzelwerte oberhalb der Betz-Grenze können durch Windmessfehler, Zeitversatz, dynamische Betriebszustände und die kubische Abhängigkeit des Nenners entstehen. Sie stellen keine reale Überschreitung der aerodynamischen Grenze dar.");
    possibleAnswer(6, ...
        "c_p,el verwendet die elektrische Generatorleistung. Neben der Aerodynamik sind deshalb mechanische und elektrische Verluste, Regelung und Messabweichungen enthalten.");

    solutionHeading("7 Vertiefung: Energieintegration");
    Eexample = sum(energyExample.ElektrischeLeistung_W .* ...
        energyExample.Intervall_s)/3600;
    calculationSolution("Energie der Beispielintervalle", ...
        "E_Wh = Summe(P_i * Delta_t_i) / 3600", Eexample, "Wh");
    possibleAnswer(1, ...
        "Beide Energiemengen müssen über dieselben Intervalle integriert werden, damit ihr Verhältnis nicht durch unterschiedliche zeitliche Abdeckung verzerrt wird.");
    possibleAnswer(2, ...
        "E_el/E_Wind enthält neben Anlagenverlusten auch Stillstände, Regelung, Messunsicherheiten und mögliche Unterschiede zwischen Sensor- und Rotoranströmung. Es ist daher kein einzelner Anlagenwirkungsgrad.");
    if ~isempty(energyResult)
        disp("Automatisch berechnete Energieübersicht:");
        disp(energyResult);
    end

    solutionHeading("8 Vertiefung: Weibull-Verteilung");

    disp("Verwendete Formel:");
    disp("f(v) = (k/a) * (v/a)^(k-1) * exp(-(v/a)^k)");

    if ~isempty(weibullParameters)

        k = weibullParameters.Formparameter_k;
        a = weibullParameters.Skalenparameter_a_mps;

        f3 = (k/a) * (3/a)^(k-1) * exp(-(3/a)^k);
        f6 = (k/a) * (6/a)^(k-1) * exp(-(6/a)^k);

        disp(" ");
        fprintf('Formparameter k: %.3f\n',k);
        fprintf('Skalenparameter a: %.3f m/s\n',a);

        calculationSolution( ...
            "Wahrscheinlichkeitsdichte bei v = 3 m/s", ...
            "f(3) = (k/a) * (3/a)^(k-1) * exp(-(3/a)^k)", ...
            f3, "(m/s)^-1");

        calculationSolution( ...
            "Wahrscheinlichkeitsdichte bei v = 6 m/s", ...
            "f(6) = (k/a) * (6/a)^(k-1) * exp(-(6/a)^k)", ...
            f6, "(m/s)^-1");

    possibleAnswer(1, ...
        "Die größten sichtbaren Abweichungen treten vor allem im niedrigen Windgeschwindigkeitsbereich auf. Zwischen ungefähr 1 und 2 m/s liegen die gemessenen Häufigkeiten teilweise über der Weibull-Kurve, während sie im Bereich von etwa 3 bis 4 m/s darunter liegen. Der grundsätzliche Schwerpunkt der Verteilung zwischen 1 und 3 m/s wird dennoch plausibel wiedergegeben.");

    else
        disp("Dieser Vertiefungsabschnitt wurde nicht ausgeführt.");
    end

    solutionHeading("9 Vertiefung: Höhen- und Rauigkeitseinfluss");
    vHeight = 4.0*log((30-0)/0.5)/log((10-0)/0.5);
    calculationSolution("Windgeschwindigkeit in 30 m Höhe", ...
        "v(h2) = v(h1) * ln((h2-d)/z0) / ln((h1-d)/z0)", ...
        vHeight, "m/s");
    possibleAnswer(1, ...
        "Das logarithmische Profil setzt idealisierte, stationäre und horizontal homogene Bedingungen voraus. Auf einem Gebäudedach beeinflussen Dachkanten, Ablösung, Turbulenz, umliegende Gebäude und eine schwer definierbare Rauigkeit das Ergebnis.");

    disp(" ");
    disp("============================================================");
end


function solutionHeading(text)
    disp(" ");
    disp("------------------------------------------------------------");
    disp(text);
    disp("------------------------------------------------------------");
end


function calculationSolution(label, formula, value, unit)
    disp(" ");
    disp(label);
    disp("Formel: " + formula);
    fprintf('Ergebnis: %.4g %s\n',value,char(unit));
end


function possibleAnswer(number, text)
    fprintf('%d. Mögliche Antwort: %s\n',number,char(text));
end


function idx = deterministicSample(indexVector,maxPoints)
    indexVector=indexVector(:);
    if numel(indexVector)<=maxPoints
        idx=indexVector;
    else
        positions=round(linspace(1,numel(indexVector),maxPoints));
        idx=indexVector(positions);
    end
end
