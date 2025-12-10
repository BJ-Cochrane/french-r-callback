# French R Callback

🔁 Periodic French vocabulary callback while working in R

This repository contains a small utility that installs a personal R “callback” which runs periodically while you work.  
It is designed for lightweight language practice while coding in R.

---

## 📦 Files in this repository

| File | Purpose |
|------|---------|
| `setup_french_callback.R` | Main installer script (run this once). |
| `french_callback.R` | The callback logic that runs during your R sessions. |
| `french_words.csv` | The word list used by the callback. |
| `backups/` | Folder automatically created to store `.Rprofile` backups. |

---

## 🚀 How to Install

### **Open Rproj and run `setup_french_callback.R`**

The installer:

1. Creates a user-level scripts directory inside  
   `%LOCALAPPDATA%/R/scripts/`
2. Copies two files into that directory:
   - `french_callback.R`
   - `french_words.csv`
3. Makes a timestamped backup of your `.Rprofile` in a local `backups/` folder
4. Safely updates your `~/.Rprofile` to automatically load the callback
5. Prints instructions and default configuration options

The installation is safe, reversible, and only affects your own R session.

---

## 🗑️ Uninstalling the Callback

If you decide you no longer want the French callback, simply run:

```r
source("uninstall_french_callback.R")
```

## ⚙️ Configuration

Defaults can be modified:
```r
options(french.callback = TRUE)            # On/off switch
options(french.callback.frequency = 3)     # Trigger callback every N commands
options(french.callback.interval = 10)     # Minimum seconds between triggers
```
