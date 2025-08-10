#!/usr/bin/env python3
import re
import subprocess
from pathlib import Path

# Zenity-Dateiauswahl
file_path = subprocess.getoutput('zenity --file-selection --title="Textdatei auswählen"')

if not file_path.strip():
    subprocess.run(['zenity', '--error', '--text=Keine Datei ausgewählt.'])
    exit()

# Datei einlesen (UTF-8, BOM entfernen)
with open(file_path, 'r', encoding='utf-8-sig') as f:
    text = f.read()

# Gesamtwortzahl
words = text.split()
word_count = len(words)

# Ausschlussliste
exclude_list = {"darum", "warum", "herum", "daraus", "woraus", "hinwiederum", "hinwiderum", "wiederum", "Paulus", "heraus", "Ausflus", "Beschlus", "hierum", "überaus"}

# Latein-Pattern (Case-insensitive, inkl. erweiterte Suffixe, Mindestlänge 4 Zeichen, kein -nis)
latin_pattern = r"\b[a-zA-ZäöüÄÖÜ]{4,}(?:us|um|is|ae|æ|orum|arum|ibus|iren|irt|iret)\b"

# Alle Treffer suchen
latin_matches_raw = re.findall(latin_pattern, text, flags=re.IGNORECASE)

# Filtern: keine -nis-Endungen, keine Ausschlussliste
latin_matches = [
    w for w in latin_matches_raw
    if not w.lower().endswith("nis")
    and not w.lower().endswith("thum")
    and not w.lower().endswith("haus")
    and not w.lower().endswith("kreis")
    and w.lower() not in exclude_list
]

# Absolute und relative Häufigkeit
latin_count = len(latin_matches)
latin_per_1000 = round(latin_count / word_count * 1000, 2) if word_count > 0 else 0

# Ergebnistext
result = f"""Datei: {file_path}

Gesamtwortzahl: {word_count}
Lateinische Wörter (Anzahl, gefiltert): {latin_count}
Lateinische Wörter (pro 1.000 Wörter): {latin_per_1000}

Gefundene lateinische Wörter:
{' '.join(latin_matches)}
"""

# Ausgabe-Datei speichern
out_path = Path(file_path).with_name(Path(file_path).stem + "_latein_auswertung.txt")
with open(out_path, 'w', encoding='utf-8') as f:
    f.write(result)

# GUI-Anzeige
subprocess.run([
    'zenity', '--info', '--width=500', '--title=Lateinische Wörter',
    '--text', f"{result}\n\nErgebnisse gespeichert unter:\n{out_path}"
])
