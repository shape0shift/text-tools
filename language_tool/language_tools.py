import tkinter as tk
from tkinter import messagebox
import subprocess
import os
import sys

# Function to run the selected script
def run_script(script_name):
    try:
        subprocess.run(["bash", script_name], check=True)
    except subprocess.CalledProcessError as e:
        messagebox.showerror("Error", f"An error occurred while running {script_name}:\n{e}")

# Function to get the correct path for the image
def resource_path(relative_path):
    """ Get the absolute path to the resource, works for dev and for PyInstaller """
    try:
        # PyInstaller creates a temporary folder and stores path in _MEIPASS
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)

# Create the main window
root = tk.Tk()
root.title("Text Tool Suite")
root.geometry("500x500")  # Increased window size

# Load the background image (GIF)
background_image = tk.PhotoImage(file=resource_path("nestor.gif"))  # Use resource_path function
background_label = tk.Label(root, image=background_image)
background_label.place(relwidth=1, relheight=1)  # Make the image fill the window

# Create a label for the title
title_label = tk.Label(root, text="Select a Tool", font=("Arial", 20), bg="white")
title_label.pack(pady=20)

# Create buttons for each tool
buttons = [
    ("Compare two input texts", "comp_2_texts_gui.sh"),
    ("Compare phrases (3+ words)", "comp_same_phrases_3+_gui.sh"),
    ("Find same words", "same_words_gui.sh"),
    ("Generate similarity report", "similarity_report_gui.sh"),
    ("Word frequency analysis", "word_Frequency_gui.sh"),
    ("Wrap lines", "wrap_lines_gui.sh"),
    ("Exit", None)
]

for (text, script) in buttons:
    if script:
        button = tk.Button(root, text=text, command=lambda s=script: run_script(s), width=30)
    else:
        button = tk.Button(root, text=text, command=root.quit, width=30)
    button.pack(pady=10)

# Start the Tkinter event loop
root.mainloop()
