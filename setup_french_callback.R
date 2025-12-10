# ============================================================
# Install / update French callback .Rprofile + folder content
# ============================================================

install_french_callback <- function() {
  
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
  
  cat(step_col("Step 1:"), info_col(" Checking LOCALAPPDATA path...\n"))
  local_app <- Sys.getenv("LOCALAPPDATA")
  scripts_dir <- file.path(local_app, "R", "scripts")
  
  cat(info_col("  LOCALAPPDATA resolved to: "), path_col(local_app), "\n", sep = "")
  cat(info_col("  Scripts folder will be:  "), path_col(scripts_dir), "\n", sep = "")
  
  # ------------------------------------------------------------
  # Step 2: Create the scripts directory if needed
  # ------------------------------------------------------------
  cat("\n", step_col("Step 2:"), info_col(" Creating scripts directory\n"), sep = "")
  if (!dir.exists(scripts_dir)) {
    dir.create(scripts_dir, recursive = TRUE)
    cat(ok_col("  Created directory: "), path_col(scripts_dir), "\n", sep = "")
  } else {
    cat(info_col("  Directory already exists: "), path_col(scripts_dir), "\n", sep = "")
  }
  
  # ------------------------------------------------------------
  # Step 3: Copy files into scripts directory
  # ------------------------------------------------------------
  cat("\n", step_col("Step 3:"), info_col(" Copying 'french_callback.R' and 'french_words.csv'...\n"), sep = "")
  
  src_callback <- "french_callback.R"
  src_words    <- "french_words.csv"
  
  dest_callback <- file.path(scripts_dir, "french_callback.R")
  dest_words    <- file.path(scripts_dir, "french_words.csv")
  
  if (!file.exists(src_callback)) stop("File not found: french_callback.R")
  if (!file.exists(src_words))    stop("File not found: french_words.csv")
  
  file.copy(src_callback, dest_callback, overwrite = TRUE)
  cat(ok_col("  Copied: "), path_col(src_callback), info_col("  ->  "), path_col(dest_callback), "\n", sep = "")
  
  file.copy(src_words, dest_words, overwrite = TRUE)
  cat(ok_col("  Copied: "), path_col(src_words), info_col("  ->  "), path_col(dest_words), "\n", sep = "")
  
  # ------------------------------------------------------------
  # Step 4: Read & backup .Rprofile
  # ------------------------------------------------------------
  cat("\n", step_col("Step 4:"), info_col(" Updating .Rprofile safely...\n"), sep = "")
  
  rprof <- path.expand("~/.Rprofile")
  
  # Create backups/ folder in working directory
  backup_dir <- file.path(getwd(), "backups")
  if (!dir.exists(backup_dir)) {
    dir.create(backup_dir, recursive = TRUE)
    cat(ok_col("  Created backup directory: "), path_col(backup_dir), "\n", sep = "")
  } else {
    cat(info_col("  Backup directory already exists: "), path_col(backup_dir), "\n", sep = "")
  }
  
  if (file.exists(rprof)) {
    cat(info_col("  Existing .Rprofile found.\n"))
    contents <- readLines(rprof, warn = FALSE)
    
    timestamp   <- format(Sys.time(), "%Y%m%d-%H%M%S")
    backup_path <- file.path(backup_dir, paste0(".Rprofile.bak-", timestamp))
    
    file.copy(rprof, backup_path, overwrite = FALSE)
    cat(ok_col("  .Rprofile backup created: "), path_col(backup_path), "\n", sep = "")
    
  } else {
    cat(warn_col("  No existing .Rprofile found — one will be created.\n"))
    contents <- character(0)
  }
  
  # ------------------------------------------------------------
  # Build the block to insert between markers
  # ------------------------------------------------------------
  marker_start <- "# --- French callback auto-source (BEGIN) ---"
  marker_end   <- "# --- French callback auto-source (END) ---"
  
  block_lines <- c(
    marker_start,
    "cb_path <- file.path(Sys.getenv('LOCALAPPDATA'), 'R', 'scripts', 'french_callback.R')",
    "if (file.exists(cb_path)) {",
    "  ok <- try(source(cb_path), silent = TRUE)",
    "  if (inherits(ok, 'try-error')) message('Error running french_callback.R')",
    "}",
    marker_end
  )
  
  # ------------------------------------------------------------
  # Step 5: Insert or replace block between markers
  # ------------------------------------------------------------
  cat("\n", step_col("Step 5:"), info_col(" Writing loader block into .Rprofile\n"), sep = "")
  
  start_idx <- which(contents == marker_start)
  end_idx   <- which(contents == marker_end)
  
  if (length(start_idx) == 1L && length(end_idx) == 1L && start_idx < end_idx) {
    cat(info_col("  Existing marker block found. Replacing contents between markers...\n"))
    
    new_contents <- c(
      if (start_idx > 1) contents[1:(start_idx - 1)] else character(0),
      block_lines,
      if (end_idx < length(contents)) contents[(end_idx + 1):length(contents)] else character(0)
    )
    
    writeLines(new_contents, rprof, useBytes = TRUE)
    cat(info_col("  French callback block replaced between markers.\n"))
    
  } else if (length(start_idx) == 0L && length(end_idx) == 0L) {
    cat(info_col("  No existing marker block found. Appending new block...\n"))
    
    new_contents <- c(contents, "", block_lines, "")
    
    writeLines(new_contents, rprof, useBytes = TRUE)
    cat(info_col("  French callback block appended to .Rprofile.\n"))
    
  } else {
    cat(warn_col("  Inconsistent marker state detected. No changes made.\n"))
  }
  
  # ------------------------------------------------------------
  # Step 6: Wrap up + instructions
  # ------------------------------------------------------------
  cat("\n", step_col("Step 6:"), ok_col(" Finished!\n"), sep = "")
  cat(info_col("French callback installation/update complete.\n"))
  cat(info_col("Restart R to activate auto-loading.\n\n"))
  
  # ---- Print user instructions ----
  cat(step_col("French Callback Options (defaults):\n"))
  cat(info_col("  options(french.callback = TRUE)           # Enable/disable callback\n"))
  cat(info_col("  options(french.callback.frequency = 3)    # Trigger every N executions\n"))
  cat(info_col("  options(french.callback.interval = 10)    # Minimum seconds between triggers\n\n"))
}

# ============================================================
# AUTO-RUN THE INSTALLER
# ============================================================

install_french_callback()
