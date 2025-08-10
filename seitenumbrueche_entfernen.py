#!/usr/bin/env python3
import re
import subprocess

# Zenity-Dateiauswahl
file_path = subprocess.getoutput('zenity --file-selection --title="Textdatei auswählen"')

if not file_path.strip():
    subprocess.run(['zenity', '--error', '--text=Keine Datei ausgewählt.'])
    exit()

# Datei einlesen (UTF-8 mit BOM-Entfernung)
with open(file_path, 'r', encoding='utf-8-sig') as f:
    text = f.read()

# 1. Mehrfache Leerzeilen zu einem Leerzeichen machen
text = re.sub(r'\n\s*\n', ' ', text)

# 2. Einzelne Zeilenumbrüche zu Leerzeichen machen
text = re.sub(r'\n', ' ', text)

# 3. Mehrfache Leerzeichen reduzieren
text = re.sub(r'\s+', ' ', text)

# 4. Wiederholung am Seitenumbruch entfernen:
#    Falls dasselbe Wort am Ende und Anfang aufeinanderfolgender Segmente steht → einmal löschen
#    Beispiel: "bey Er Erschaffung" → "bey Erschaffung"
text = re.sub(r'\b(\w+)\s+\1\b', r'\1', text, flags=re.IGNORECASE)

# 5. Mehrfache Leerzeichen nochmal reduzieren
text = re.sub(r'\s+', ' ', text).strip()

# Ergebnis speichern
out_path = file_path.rsplit('.', 1)[0] + "_bereinigt.txt"
with open(out_path, 'w', encoding='utf-8') as f:
    f.write(text)

# Erfolgsmeldung
subprocess.run(['zenity', '--info', '--width=400',
                '--text', f"Bereinigter Text gespeichert unter:\n{out_path}"])
