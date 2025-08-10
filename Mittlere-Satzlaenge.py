#!/usr/bin/env python3
import re
import subprocess

# Zenity-Dateiauswahl
file_path = subprocess.getoutput('zenity --file-selection --title="Textdatei auswählen"')

if not file_path.strip():
    subprocess.run(['zenity', '--error', '--text=Keine Datei ausgewählt.'])
    exit()

# Datei einlesen (UTF-8, BOM entfernen)
with open(file_path, 'r', encoding='utf-8-sig') as f:
    text = f.read()

# ------------------------------
# Alle Leerzeilen im Text entfernen
# ------------------------------
# Entfernt Zeilen, die nur aus Leerzeichen/Tab bestehen
text = re.sub(r'\n\s*\n', ' ', text)
# Mehrfache Leerzeichen zusammenfassen
text = re.sub(r'\s+', ' ', text).strip()

# Gesamtwortzahl
word_count = len(text.split())

# Sätze splitten an ., !, ?
sentences = re.split(r"[.!?]", text)
# Satzlängen nur für nicht-leere Sätze
sent_lengths = [len(s.split()) for s in sentences if s.strip()]

# Gesamtanzahl Sätze
sentence_count = len(sent_lengths)

# Mittlere Satzlänge
avg_length = round(sum(sent_lengths) / sentence_count, 2) if sentence_count > 0 else 0

# Sätze > 40 Wörter
over_40_count = sum(1 for l in sent_lengths if l > 40)
over_40_percent = round(over_40_count / sentence_count * 100, 2) if sentence_count > 0 else 0

# ------------------------------

# Ergebnisanzeige
result = f"""Datei: {file_path}

Gesamtwortzahl: {word_count}
Anzahl der Sätze: {sentence_count}
Mittlere Satzlänge (Wörter): {avg_length}
Sätze > 40 Wörter: {over_40_count} ({over_40_percent} %)
"""

subprocess.run(['zenity', '--info', '--width=400', '--title=Textstatistik', '--text', result])
