# Windenergie-Praktikum auf Basis realer Messdaten

Dieses Repository enthält das im Rahmen der Bachelorarbeit

**„Entwicklung eines Windenergie-Praktikums auf Basis realer Messdaten“**

entwickelte MATLAB-Live-Skript.

Das Skript verbindet die Auswertung realer Messdaten einer Kleinwindkraftanlage mit fachlichen Erläuterungen, Rechenaufgaben, Interpretationsfragen und einer integrierten Selbstkontrolle.

## Autor und Projekt

**Autor:** Maximilian Wimmer  
**Hochschule:** Hochschule München  
**Studiengang:** Sustainable Engineering  
**Projekt:** Bachelorarbeit  
**Jahr:** 2026  

## Inhalt des Live-Skripts

Das Praktikum behandelt unter anderem:

- Jahres-, Monats- und Tagesverläufe der Windgeschwindigkeit
- Häufigkeitsverteilung der Windgeschwindigkeit
- Windrichtungsverteilung und Windrose
- theoretische Windleistung und Betz-Grenze
- Leistungskennlinie der Kleinwindkraftanlage
- Zusammenhang zwischen Windgeschwindigkeit, Leistung und Rotordrehzahl
- Schnelllaufzahl und elektrisch abgeleiteter Leistungsbeiwert

Das Live-Skript enthält neben den Auswertungen auch Rechenaufgaben, qualitative Fragen und automatische Rückmeldungen zu den numerischen Eingaben.

## Enthaltene Dateien

Das Repository enthält zwei Fassungen des Skripts:

- `Windenergie_Praktikum_LiveSkript.mlx`  
  Ausführbare Praktikumsversion für den MATLAB Live Editor.

- `Windenergie_Praktikum_LiveSkript.m`  
  Textbasierte Fassung zur Einsicht, Versionierung und Nachvollziehbarkeit des Programmcodes.

Für die Bearbeitung des Praktikums sollte die Datei `Windenergie_Praktikum_LiveSkript.mlx` verwendet werden.

## MATLAB-Version

Das Live-Skript wurde mit **MATLAB R2025b** entwickelt und getestet.

Die Verwendung einer älteren MATLAB-Version kann zu Abweichungen bei der Darstellung, beim Datenimport oder bei der Ausführung lokaler Funktionen führen.

## Benötigte Toolbox

Der überwiegende Teil des Live-Skripts kann ohne zusätzliche Toolbox bearbeitet werden.

Für den Abschnitt zur Weibull-Verteilung wird die **Statistics and Machine Learning Toolbox** benötigt.

Ist diese Toolbox nicht installiert, wird der entsprechende Abschnitt automatisch übersprungen. Die übrigen Praktikumsabschnitte bleiben nutzbar.

## Benötigte Messdaten

Für die vollständige Ausführung werden folgende Dateien benötigt:

- `Wind_Mittel-2018.csv`
- `Wind_Mittel-2017.csv`
- `Wind_Momentan-2013.csv`

Die Messdatendateien sind nicht Bestandteil dieses Repositories und müssen separat bereitgestellt werden.

## Erforderliche Ordnerstruktur

Das Live-Skript und der Ordner `Daten` müssen sich im selben Hauptordner befinden.

```text
Windenergie-Praktikum/
├── Windenergie_Praktikum_LiveSkript.mlx
├── Windenergie_Praktikum_LiveSkript.m
└── Daten/
    ├── Wind_Mittel-2018.csv
    ├── Wind_Mittel-2017.csv
    └── Wind_Momentan-2013.csv
```

Die Dateinamen dürfen nicht verändert werden, da sie im Live-Skript automatisch verwendet werden.

## Vorbereitung

1. Repository herunterladen oder klonen.
2. Die drei benötigten Messdatendateien separat beschaffen.
3. Im Hauptordner einen Unterordner mit dem Namen `Daten` anlegen.
4. Die drei CSV-Dateien im Ordner `Daten` ablegen.
5. `Windenergie_Praktikum_LiveSkript.mlx` mit MATLAB R2025b öffnen.
6. Zuerst Abschnitt 0 ausführen.
7. Prüfen, ob alle benötigten Dateien als gefunden angezeigt werden.

Wenn mindestens eine Datendatei fehlt oder falsch benannt ist, wird die weitere Ausführung abgebrochen.

## Empfohlene Darstellung im MATLAB Live Editor

Für die Bearbeitung wird ausdrücklich die Ansicht **`Output inline`** empfohlen.

Nach dem Öffnen des Live-Skripts befinden sich auf der rechten Seite des Live Editors drei Symbole für die Darstellung der Ausgaben. Die mittlere Option entspricht `Output inline`.

In der MATLAB-Standardeinstellung ist häufig `Output on right` ausgewählt. Diese Darstellung verkleinert den verfügbaren Platz für Text, Code, Tabellen und Diagramme und ist für dieses umfangreiche Live-Skript weniger übersichtlich.

Bei `Output inline` erscheinen die Ergebnisse direkt unter dem jeweils ausgeführten Codeabschnitt. Dadurch bleiben Aufgabenstellung, Berechnung und zugehörige Ausgabe unmittelbar zusammen sichtbar.

### Empfohlene Anordnung der MATLAB-Oberfläche

Nach dem erfolgreichen Start des Skripts wird folgende Anordnung empfohlen:

- Ausgabeansicht auf `Output inline` stellen.
- Das `Command Window` vollständig nach unten ziehen oder auf eine geringe Höhe verkleinern.
- Das Fenster `Current Folder` beziehungsweise `Aktueller Ordner` möglichst schmal einstellen.
- Dem Live Editor den größten Teil der Bildschirmfläche zur Verfügung stellen.

Das `Command Window` wird für die reguläre Bearbeitung kaum benötigt, da Tabellen, Diagramme und Rückmeldungen direkt im Live-Skript ausgegeben werden.

Diese Einstellungen sind nicht technisch erforderlich, verbessern jedoch die Lesbarkeit und Übersichtlichkeit deutlich.

## Speicherung der bearbeiteten Version

Die bearbeitete Datei sollte unter einem neuen Dateinamen gespeichert werden.

Beispiel:

```text
Windenergie_Praktikum_Nachname.mlx
```

Die ursprüngliche Datei sollte unverändert aufbewahrt werden.
