# ============================================================
# Uninstall French callback: remove .Rprofile block + files
# ============================================================

uninstall_french_callback <- function() {
  
  # Try to load crayon, install if needed
  if (!requireNamespace("crayon", quietly = TRUE)) {
    install.packages("crayon", quiet = TRUE)
  }
  
  # Define styling + crayon fallback
  if (requireNamespace("crayon", quietly = TRUE)) {
    step_col  <- crayon::bold$cyan
    info_col  <- crayon::cyan
    ok_col    <- crayon::green
    warn_col  <- crayon::yellow
    path_col  <- crayon::blue
  } else {
    step_col <- info_col <- ok_col <- warn_col <- path_col <- identity
  }
  
  # ------------------------------------------------------------
  # Step 1: Resolve LOCALAPPDATA + script paths
  # ------------------------------------------------------------
  cat(step_col("Step 1:"), info_col(" Checking LOCALAPPDATA path...\n"))
  local_app <- Sys.getenv("LOCALAPPDATA")
  
  if (!nzchar(local_app)) {
    stop("LOCALAPPDATA is not set. This uninstall script only works on Windows.")
  }
  
  scripts_dir   <- file.path(local_app, "R", "scripts")
  dest_callback <- file.path(scripts_dir, "french_callback.R")
  dest_words    <- file.path(scripts_dir, "french_words.csv")
  
  cat(info_col("  LOCALAPPDATA resolved to: "), path_col(local_app), "\n", sep = "")
  cat(info_col("  Scripts folder is:        "), path_col(scripts_dir), "\n", sep = "")
  
  # ------------------------------------------------------------
  # Step 2: Remove installed files (if present)
  # ------------------------------------------------------------
  cat("\n", step_col("Step 2:"), info_col(" Removing installed files (if they exist)\n"), sep = "")
  
  if (file.exists(dest_callback)) {
    file.remove(dest_callback)
    cat(ok_col("  Removed: "), path_col(dest_callback), "\n", sep = "")
  } else {
    cat(warn_col("  Not found (skipped): "), path_col(dest_callback), "\n", sep = "")
  }
  
  if (file.exists(dest_words)) {
    file.remove(dest_words)
    cat(ok_col("  Removed: "), path_col(dest_words), "\n", sep = "")
  } else {
    cat(warn_col("  Not found (skipped): "), path_col(dest_words), "\n", sep = "")
  }
  
  # ------------------------------------------------------------
  # Step 3: Backup .Rprofile
  # ------------------------------------------------------------
  cat("\n", step_col("Step 3:"), info_col(" Backing up .Rprofile (just incase you accidentally delete something...\n"), sep = "")
  
  rprof <- path.expand("~/.Rprofile")
  
  backup_dir <- file.path(getwd(), "backups")
  if (!dir.exists(backup_dir)) {
    dir.create(backup_dir, recursive = TRUE)
    cat(ok_col("  Created backup directory: "), path_col(backup_dir), "\n", sep = "")
  } else {
    cat(info_col("  Backup directory already exists: "), path_col(backup_dir), "\n", sep = "")
  }
  
  if (file.exists(rprof)) {
    contents   <- readLines(rprof, warn = FALSE)
    timestamp  <- format(Sys.time(), "%Y%m%d-%H%M%S")
    backup_path <- file.path(backup_dir, paste0(".Rprofile.bak-", timestamp))
    
    file.copy(rprof, backup_path, overwrite = FALSE)
    cat(ok_col("  .Rprofile backup created: "), path_col(backup_path), "\n", sep = "")
  } else {
    cat(warn_col("  No .Rprofile found. Nothing to back up or modify.\n"))
    contents <- character(0)
  }
  
  # ------------------------------------------------------------
  # Step 4: Remove loader block between markers
  # ------------------------------------------------------------
  cat("\n", step_col("Step 4:"), info_col(" Removing loader block from .Rprofile\n"), sep = "")
  
  marker_start <- "# --- French callback auto-source (BEGIN) ---"
  marker_end   <- "# --- French callback auto-source (END) ---"
  
  start_idx <- which(contents == marker_start)
  end_idx   <- which(contents == marker_end)
  
  if (!length(contents)) {
    cat(warn_col("  .Rprofile is empty or missing. Skipping edit.\n"))
    
  } else if (length(start_idx) == 1L && length(end_idx) == 1L && start_idx < end_idx) {
    cat(info_col("  Found marker block. Removing it...\n"))
    
    new_contents <- c(
      if (start_idx > 1) contents[1:(start_idx - 1)] else character(0),
      if (end_idx < length(contents)) contents[(end_idx + 1):length(contents)] else character(0)
    )
    
    writeLines(new_contents, rprof, useBytes = TRUE)
    cat(ok_col("  Loader block removed from .Rprofile.\n"))
    
  } else if (length(start_idx) == 0L && length(end_idx) == 0L) {
    cat(info_col("  No marker block found. .Rprofile left unchanged.\n"))
  } else {
    cat(warn_col("  Inconsistent marker state detected. No changes made to .Rprofile.\n"))
  }
  
  # ------------------------------------------------------------
  # Step 5: Wrap up
  # ------------------------------------------------------------
  cat("\n", step_col("Step 5:"), ok_col(" Uninstall complete.\n"), sep = "")
  cat(info_col("French callback has been removed from .Rprofile and its files deleted (if present).\n"))
  cat(info_col("Restart R to ensure the callback is no longer loaded.\n"))
}

# ============================================================
# AUTO-RUN THE UNINSTALLER
# ============================================================

uninstall_french_callback()
