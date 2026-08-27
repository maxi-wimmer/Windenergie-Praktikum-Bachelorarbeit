# Windenergie-Praktikum auf Basis realer Messdaten

Dieses Repository enthält das im Rahmen der Bachelorarbeit

**„Entwicklung eines Windenergie-Praktikums auf Basis realer Messdaten“**

entwickelte MATLAB-Live-Skript. Das Praktikum verbindet die Auswertung realer Messdaten einer Kleinwindkraftanlage mit fachlichen Erläuterungen, Rechenaufgaben, Interpretationsfragen und einer integrierten Selbstkontrolle.

## Autor und Projekt

**Autor:** Maximilian Wimmer  
**Hochschule:** Hochschule München  
**Studiengang:** Sustainable Engineering  
**Projekt:** Bachelorarbeit  
**Jahr:** 2026  
**Veröffentlichte Version:** `v1.0.0`

## Inhalt des Praktikums

Das Praktikum behandelt unter anderem:

- Jahres-, Monats- und Tagesverläufe der Windgeschwindigkeit
- Häufigkeitsverteilung der Windgeschwindigkeit
- Windrichtungsverteilung und Windrose
- theoretische Windleistung und Betz-Grenze
- Leistungskennlinie der Kleinwindkraftanlage
- Zusammenhang zwischen Windgeschwindigkeit, Leistung und Rotordrehzahl
- Schnelllaufzahl und elektrisch abgeleiteter Leistungsbeiwert
- optionale Vertiefungen zur Energieintegration, Weibull-Verteilung sowie zum Höhen- und Rauigkeitseinfluss

Neben den Auswertungen enthält das Live-Skript Rechenaufgaben, qualitative Fragen, automatische Rückmeldungen zu numerischen Eingaben und eine integrierte Musterlösung zur Selbstkontrolle.

## Enthaltene Dateien

Das Repository enthält zwei Fassungen des Skripts:

- `Windenergie_Praktikum_LiveSkript.mlx`  
  Ausführbare Praktikumsversion für den MATLAB Live Editor.

- `Windenergie_Praktikum_LiveSkript.m`  
  Textbasierte Fassung zur Einsicht, Versionierung und Nachvollziehbarkeit des Programmcodes. Die Datei kann außerdem im MATLAB Live Editor geöffnet und als `.mlx` gespeichert werden. Sie kann dadurch auch als Ausgangspunkt für ein neu gespeichertes Live-Skript verwendet werden.

Für die reguläre Bearbeitung des Praktikums sollte die Datei `Windenergie_Praktikum_LiveSkript.mlx` verwendet werden.

## Vollständiges Downloadpaket

Die Messdatendateien sind wegen ihrer Größe nicht als einzelne Dateien im Repository gespeichert. Das vollständige Praktikumspaket wird unter **Releases** bereitgestellt.

Für die Durchführung ist die Datei

```text
Windenergie-Praktikum_v1.0.0.zip
```

herunterzuladen. Die von GitHub automatisch erzeugten Archive `Source code (zip)` und `Source code (tar.gz)` enthalten die Messdaten nicht.

## MATLAB-Version

Das Live-Skript wurde mit **MATLAB R2025b** entwickelt und getestet.

Die Verwendung einer älteren MATLAB-Version kann zu Abweichungen bei der Darstellung, beim Datenimport oder bei der Ausführung lokaler Funktionen führen.

## Benötigte Toolbox

Der überwiegende Teil des Live-Skripts kann ohne zusätzliche Toolbox bearbeitet werden.

Für den Abschnitt zur Weibull-Verteilung wird die **Statistics and Machine Learning Toolbox** benötigt. Ist diese Toolbox nicht installiert, wird der entsprechende Abschnitt automatisch übersprungen. Die übrigen Praktikumsabschnitte bleiben nutzbar.

## Inhalt des Release-Pakets

Das vollständige Downloadpaket besitzt folgende Ordnerstruktur:

```text
Windenergie-Praktikum_v1.0.0/
├── README.md
├── Windenergie_Praktikum_LiveSkript.mlx
├── Windenergie_Praktikum_LiveSkript.m
└── Daten/
    ├── Wind_Mittel-2017.csv
    ├── Wind_Mittel-2018.csv
    └── Wind_Momentan-2013.csv
```

Die Dateinamen und die Ordnerstruktur dürfen nicht verändert werden, da sie vom Live-Skript automatisch verwendet werden.

## Schnellstart

1. Unter **Releases** die Datei `Windenergie-Praktikum_v1.0.0.zip` herunterladen.
2. Das ZIP-Archiv vollständig entpacken.
3. `Windenergie_Praktikum_LiveSkript.mlx` mit MATLAB R2025b öffnen.
4. Zuerst Abschnitt 0 ausführen.
5. Prüfen, ob alle drei Messdatendateien als gefunden angezeigt werden.
6. Die Abschnitte anschließend in der vorgegebenen Reihenfolge bearbeiten.

Wenn mindestens eine Messdatendatei fehlt oder falsch benannt ist, wird die weitere Ausführung abgebrochen.

## Bearbeitungshinweise

- Ausschließlich Variablen verändern oder ergänzen, deren Namen auf `_eingabe` enden.
- Im MATLAB-Code einen Dezimalpunkt verwenden, beispielsweise `0.5` statt `0,5`.
- Numerische Eingaben werden automatisch als `korrekt`, `nicht korrekt` oder `nicht bearbeitet` bewertet.
- Qualitative Antworten direkt unter den jeweiligen Fragen eintragen.
- Nach Bearbeitung der Rechenfelder des Kernteils kann mit `FERTIG` die integrierte Musterlösung angezeigt werden.
- Mit `RESET` werden die Eingabevariablen im aktuellen MATLAB-Arbeitsbereich zurückgesetzt. Bereits im Skripttext gespeicherte Zahlen werden dadurch nicht entfernt.
- Die bearbeitete Datei unter einem neuen Dateinamen speichern, beispielsweise `Windenergie_Praktikum_Nachname.mlx`.

## Empfohlene Darstellung im MATLAB Live Editor

Für die Bearbeitung wird die Ansicht **`Output inline`** empfohlen. Die Ergebnisse erscheinen dadurch direkt unter dem jeweils ausgeführten Codeabschnitt.

Zusätzlich ist es zweckmäßig,

- das `Command Window` zu verkleinern,
- das Fenster `Current Folder` schmal einzustellen und
- dem Live Editor den größten Teil der Bildschirmfläche zur Verfügung zu stellen.

Diese Einstellungen sind nicht technisch erforderlich, verbessern jedoch die Übersichtlichkeit.

## Lizenz und Datennutzung

Der MATLAB-Programmcode in den Dateien `Windenergie_Praktikum_LiveSkript.m` und `Windenergie_Praktikum_LiveSkript.mlx` steht unter der MIT-Lizenz. Der vollständige Lizenztext befindet sich in der Datei [`LICENSE`](LICENSE).

Die im Release-Paket enthaltenen Messdaten werden mit Genehmigung der Hochschule München ausschließlich für die Durchführung, Nachvollziehung und Auswertung dieses Windenergie-Praktikums bereitgestellt. Eine kommerzielle Nutzung, separate Weitergabe, eigenständige Veröffentlichung oder Nutzung für andere Projekte ist ohne Zustimmung der Hochschule München nicht gestattet.

Die Messdaten sind nicht Bestandteil der MIT-Lizenz.
