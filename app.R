# ============================================================================ #
#                     APP.R - ENVIROANALYZER V1.0.0                            #
# ============================================================================ #
# UI/UX Refinements: Top-anchored toggle, dark mode optimization, minimalist KPIs
# Features: Error boundaries, input validation, stress testing, localStorage
# ============================================================================ #

# ---- LOAD PACKAGES ----
library(shiny)
library(shinyjs)
library(bslib)
library(thematic)
library(tidyverse)
library(gt)
library(DT)
library(shinyWidgets)
library(rhandsontable)
library(writexl)
library(scales)
library(colourpicker)

# ---- SOURCE MODULES ----
source("src/constants.R")
source("src/functions.R")
source("src/visuals.R")
source("src/config/config_manager.R")

# AI Integration (optional - only if files exist)
if (file.exists("src/n8n_config.R")) {
  source("src/n8n_config.R")
  source("src/ai_helper.R")
} else {
  # Fallback - AI disabled
  is_ai_available <- function() FALSE
  N8N_CONFIG <- list(
    default_endpoint = "",
    allow_custom_endpoint = FALSE,
    auto_enable = FALSE
  )
}

# ---- THEMATIC AUTO-THEMING ----
thematic_shiny(font = "auto")

# ---- CUSTOM CSS ----
custom_css <- HTML("
  /* ===== ROOT VARIABLES ===== */
  :root {
    --accent-color: #1565C0;
    --accent-light: #42a5f5;
    --bg-primary: #ffffff;
    --bg-secondary: #f8fafc;
    --text-primary: #1e293b;
    --text-secondary: #64748b;
    --border-color: #e2e8f0;
    --success: #10b981;
    --warning: #f59e0b;
    --danger: #ef4444;
    --sidebar-width: 340px;
  }
  
  /* ===== DARK MODE - HIGH CONTRAST ===== */
  .dark-mode {
    --bg-primary: #0f172a;
    --bg-secondary: #1e293b;
    --text-primary: #f8fafc;
    --text-secondary: #cbd5e1;
    --border-color: #475569;
  }
  
  .dark-mode body { 
    background: var(--bg-primary) !important; 
    color: var(--text-primary) !important; 
  }
  
  .dark-mode .card,
  .dark-mode .modern-card { 
    background: var(--bg-secondary) !important; 
    border-color: var(--border-color) !important; 
  }
  
  .dark-mode .sidebar-container { 
    background: var(--bg-secondary) !important; 
  }
  
  .dark-mode h1, .dark-mode h2, .dark-mode h3, 
  .dark-mode h4, .dark-mode h5, .dark-mode h6,
  .dark-mode .kpi-label,
  .dark-mode .settings-label,
  .dark-mode .tab-line-item,
  .dark-mode .alert-param,
  .dark-mode .modern-card-header h3 {
    color: var(--text-primary) !important;
  }
  
  .dark-mode .text-muted,
  .dark-mode small {
    color: var(--text-secondary) !important;
  }
  
  .dark-mode .kpi-card {
    background: transparent !important;
    border-color: var(--border-color) !important;
  }
  
  .dark-mode .kpi-value {
    color: var(--text-primary) !important;
  }
  
  .dark-mode .modern-card-header {
    background: var(--bg-primary) !important;
    border-color: var(--border-color) !important;
  }
  
  /* Dark mode for Handsontable */
  .dark-mode .handsontable th {
    background: linear-gradient(180deg, #334155, #1e293b) !important;
    color: #e2e8f0 !important;
    border-color: #475569 !important;
  }
  
  .dark-mode .handsontable .htCore thead th {
    background: linear-gradient(180deg, #334155, #1e293b) !important;
    color: #e2e8f0 !important;
    font-weight: 600;
  }
  
  .dark-mode .handsontable .ht_clone_top th {
    background: linear-gradient(180deg, #334155, #1e293b) !important;
  }
  
  /* Dark mode for selectize inputs */
  .dark-mode .selectize-input,
  .dark-mode .selectize-dropdown,
  .dark-mode .selectize-dropdown-content {
    background: var(--bg-primary) !important;
    color: var(--text-primary) !important;
    border-color: var(--border-color) !important;
  }
  
  .dark-mode .selectize-dropdown .option,
  .dark-mode .selectize-dropdown .optgroup-header {
    color: var(--text-primary) !important;
  }
  
  .dark-mode .selectize-dropdown .option:hover,
  .dark-mode .selectize-dropdown .option.active {
    background: var(--accent-color) !important;
    color: white !important;
  }
  
  /* Enhanced QCVN Select Box Styling */
  .modern-card-body .selectize-control {
    position: relative !important;
  }
  
  .modern-card-body .selectize-input {
    background: var(--bg-secondary) !important;
    border: 2px solid var(--border-color) !important;
    border-radius: 10px !important;
    padding: 12px 16px !important;
    font-size: 14px !important;
    color: var(--text-primary) !important;
    box-shadow: none !important;
    transition: border-color 0.2s ease, box-shadow 0.2s ease;
    min-height: 48px !important;
    cursor: pointer !important;
  }
  
  .modern-card-body .selectize-input:focus,
  .modern-card-body .selectize-input.focus {
    border-color: var(--accent-color) !important;
    box-shadow: 0 0 0 3px rgba(21, 101, 192, 0.15) !important;
  }
  
  .modern-card-body .selectize-dropdown {
    position: relative !important;
    top: 0 !important;
    left: 0 !important;
    background: var(--bg-primary) !important;
    border: 2px solid var(--accent-color) !important;
    border-radius: 12px !important;
    box-shadow: 0 4px 16px rgba(0,0,0,0.12) !important;
    margin-top: 8px !important;
    margin-bottom: 8px !important;
    overflow: hidden;
    width: 100% !important;
  }
  
  .dark-mode .modern-card-body .selectize-input {
    background: var(--bg-primary) !important;
    border-color: var(--border-color) !important;
  }
  
  .dark-mode .modern-card-body .selectize-dropdown {
    background: var(--bg-secondary) !important;
    border-color: var(--accent-color) !important;
  }
  
  .modern-card-body .selectize-dropdown .option {
    padding: 14px 18px !important;
    font-size: 13px !important;
    border-bottom: 1px solid var(--border-color);
    transition: background 0.15s ease, padding-left 0.15s ease;
    cursor: pointer !important;
  }
  
  .modern-card-body .selectize-dropdown .option:last-child {
    border-bottom: none;
  }
  
  .modern-card-body .selectize-dropdown .option:hover,
  .modern-card-body .selectize-dropdown .option.active {
    background: var(--accent-color) !important;
    color: white !important;
    padding-left: 24px !important;
  }
  
  .modern-card-body .selectize-dropdown .option.selected {
    background: rgba(21, 101, 192, 0.1) !important;
    color: var(--accent-color) !important;
    font-weight: 600;
  }
  
  .modern-card-body .selectize-dropdown .option.selected:hover {
    background: var(--accent-color) !important;
    color: white !important;
  }
  
  /* Dark mode alerts - Balanced color scheme */
  .dark-mode .critical-alerts {
    background: rgba(185, 80, 80, 0.15) !important;
    border: 1px solid rgba(185, 80, 80, 0.3) !important;
    border-left: 4px solid #b95050 !important;
  }
  
  .dark-mode .warning-alerts {
    background: rgba(194, 139, 52, 0.15) !important;
    border: 1px solid rgba(194, 139, 52, 0.3) !important;
    border-left: 4px solid #c28b34 !important;
  }
  
  .dark-mode .critical-alerts-header {
    color: #e09090 !important;
  }
  
  .dark-mode .warning-alerts-header {
    color: #e0b860 !important;
  }
  
  .dark-mode .alert-item {
    background: rgba(255,255,255,0.05) !important;
  }
  
  .dark-mode .alert-value {
    color: #e09090 !important;
  }
  
  .dark-mode .warning-item .alert-value {
    color: #e0b860 !important;
  }
  
  /* ===== SIDEBAR WITH FIXED BLUE STRIP & TOP TOGGLE ===== */
  .sidebar-container {
    position: relative !important;
    background: var(--bg-secondary) !important;
    border-right: none !important;
    transition: width 0.3s ease, padding 0.3s ease;
    overflow: hidden !important;
    min-width: 6px;
  }
  
  .sidebar-handle {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 6px;
    background: linear-gradient(180deg, var(--accent-color), var(--accent-light));
    z-index: 100;
    flex-shrink: 0;
  }
  
  .flex-grow-1 {
    min-width: 0;
    overflow-x: auto;
  }
  
  /* File Upload Styling */
  .file-upload-area {
    border: 2px dashed var(--border-color);
    border-radius: 12px;
    padding: 20px;
    text-align: center;
    transition: all 0.2s ease;
    cursor: pointer;
    background: var(--bg-secondary);
  }
  
  .file-upload-area:hover {
    border-color: var(--accent-color);
    background: rgba(21, 101, 192, 0.05);
  }
  
  .file-upload-area i {
    font-size: 24px;
    color: var(--accent-color);
    margin-bottom: 8px;
  }
  
  .dark-mode .file-upload-area {
    background: var(--bg-primary);
  }
  
  /* Custom QCVN Modal */
  .qcvn-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0,0,0,0.5);
    display: none;
    align-items: center;
    justify-content: center;
    z-index: 2000;
  }
  
  .qcvn-modal-overlay.show {
    display: flex;
  }
  
  .qcvn-modal {
    background: var(--bg-primary);
    border-radius: 16px;
    width: 90%;
    max-width: 800px;
    max-height: 80vh;
    overflow: hidden;
    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
  }
  
  .qcvn-modal-header {
    padding: 20px;
    border-bottom: 1px solid var(--border-color);
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .qcvn-modal-body {
    padding: 20px;
    max-height: 60vh;
    overflow-y: auto;
  }
  
  .qcvn-modal-footer {
    padding: 16px 20px;
    border-top: 1px solid var(--border-color);
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }
  
  .dark-mode .qcvn-modal {
    background: var(--bg-secondary);
  }
  
  /* ===== TAB-LINE NAVIGATION ===== */
  .tab-line-nav {
    display: flex;
    flex-direction: column;
    gap: 2px;
    position: relative;
    border-bottom: 2px solid var(--border-color);
    padding-bottom: 4px;
  }
  
  .tab-line-nav.horizontal {
    flex-direction: row;
    gap: 0;
    border-bottom: none;
  }
  
  .tab-line-item {
    background: transparent;
    border: none;
    padding: 10px 16px;
    font-size: 14px;
    font-weight: 500;
    color: var(--text-secondary);
    cursor: pointer;
    transition: all 0.2s ease;
    position: relative;
    text-align: left;
    white-space: nowrap;
  }
  
  .tab-line-item:hover {
    color: var(--accent-color);
    background: rgba(21, 101, 192, 0.05);
  }
  
  .tab-line-item.active {
    color: var(--accent-color);
    font-weight: 600;
  }
  
  .tab-line-item.active::after {
    content: '';
    position: absolute;
    left: 0;
    bottom: -6px;
    width: 100%;
    height: 3px;
    background: var(--accent-color);
    border-radius: 3px 3px 0 0;
    animation: slideIn 0.2s ease;
  }
  
  .tab-line-nav.horizontal .tab-line-item.active::after {
    bottom: -2px;
  }
  
  @keyframes slideIn {
    from { width: 0; }
    to { width: 100%; }
  }
  
  /* ===== MINIMALIST KPI CARDS (OUTLINE STYLE) ===== */
  .kpi-card {
    background: transparent;
    border: 2px solid var(--border-color);
    border-radius: 12px;
    padding: 20px;
    text-align: center;
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
  }
  
  .kpi-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 4px;
    background: var(--border-color);
    transition: all 0.3s ease;
  }
  
  .kpi-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 20px rgba(0,0,0,0.08);
  }
  
  .kpi-value {
    font-size: 2.5rem;
    font-weight: 700;
    line-height: 1.1;
    color: var(--text-primary);
  }
  
  .kpi-label {
    font-size: 12px;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 500;
    margin-top: 8px;
  }
  
  /* KPI Color Variants - Outline Style */
  .kpi-info { border-color: var(--accent-color); }
  .kpi-info::before { background: var(--accent-color); }
  .kpi-info .kpi-value { color: var(--accent-color); }
  
  .kpi-success { border-color: var(--success); }
  .kpi-success::before { background: var(--success); }
  .kpi-success .kpi-value { color: var(--success); }
  
  .kpi-warning { border-color: var(--warning); }
  .kpi-warning::before { background: var(--warning); }
  .kpi-warning .kpi-value { color: var(--warning); }
  
  .kpi-danger { border-color: var(--danger); }
  .kpi-danger::before { background: var(--danger); }
  .kpi-danger .kpi-value { color: var(--danger); }
  
  .kpi-purple { border-color: #8b5cf6; }
  .kpi-purple::before { background: #8b5cf6; }
  .kpi-purple .kpi-value { color: #8b5cf6; }
  
  /* ===== CRITICAL ALERTS ===== */
  .critical-alerts {
    background: linear-gradient(135deg, #fef2f2, #fee2e2);
    border: 1px solid #fecaca;
    border-left: 4px solid var(--danger);
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 16px;
  }
  
  .critical-alerts-header {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
    color: var(--danger);
    margin-bottom: 12px;
  }
  
  .alert-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 12px;
    background: rgba(255,255,255,0.7);
    border-radius: 8px;
    margin-bottom: 6px;
  }
  
  .alert-param { font-weight: 500; color: var(--text-primary); }
  .alert-value { font-size: 13px; color: var(--danger); font-weight: 600; }
  
  /* ===== WARNING ALERTS ===== */
  .warning-alerts {
    background: linear-gradient(135deg, #fffbeb, #fef3c7);
    border: 1px solid #fde68a;
    border-left: 4px solid var(--warning);
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 16px;
  }
  
  .warning-alerts-header {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
    color: var(--warning);
    margin-bottom: 12px;
  }
  
  .warning-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 12px;
    background: rgba(255,255,255,0.7);
    border-radius: 8px;
    margin-bottom: 6px;
  }
  
  /* ===== EXCEL-STYLE GRID ===== */
  .excel-grid-container {
    border: 1px solid var(--border-color);
    border-radius: 8px;
    overflow: hidden;
  }
  
  .handsontable {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif !important;
    font-size: 13px !important;
  }
  
  .handsontable th {
    background: linear-gradient(180deg, #f8fafc, #f1f5f9) !important;
    font-weight: 600 !important;
    color: var(--text-primary) !important;
    border-color: var(--border-color) !important;
    text-transform: uppercase;
    font-size: 11px;
    letter-spacing: 0.3px;
  }
  
  .handsontable td {
    background: #ffffff !important;
    color: #1e293b !important;
    border-color: #e2e8f0 !important;
    padding: 8px 12px !important;
  }
  
  .handsontable td:hover {
    background: #f8fafc !important;
  }
  
  .handsontable td:focus,
  .handsontable td.current {
    background: #ffffff !important;
    outline: 2px solid var(--accent-color) !important;
    outline-offset: -2px;
  }
  
  .handsontable .htCore tbody td.area {
    background: rgba(21, 101, 192, 0.1) !important;
  }
  
  /* Dark mode cells */
  .dark-mode .handsontable td {
    background: #1e293b !important;
    color: #e2e8f0 !important;
    border-color: #334155 !important;
  }
  
  .dark-mode .handsontable td:hover {
    background: #334155 !important;
  }
  
  .dark-mode .handsontable td:focus,
  .dark-mode .handsontable td.current {
    background: #1e293b !important;
    outline: 2px solid var(--accent-color) !important;
  }
  
  .dark-mode .handsontable .htCore tbody td.area {
    background: rgba(96, 165, 250, 0.15) !important;
  }
  
  /* Invalid cell highlighting */
  .handsontable td.htInvalid {
    background: #fef2f2 !important;
    border: 2px solid var(--danger) !important;
  }
  
  .dark-mode .handsontable td.htInvalid {
    background: rgba(239, 68, 68, 0.2) !important;
  }
  
  .cell-error {
    background: #fef2f2 !important;
    border: 2px solid var(--danger) !important;
  }
  
  /* Editable header styling */
  .handsontable th.editable-header {
    cursor: text !important;
    position: relative;
  }
  
  .handsontable th.editable-header:hover::after {
    content: '✏️';
    position: absolute;
    right: 4px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 10px;
  }
  
  /* ===== HEADER SETTINGS COG ===== */
  .header-settings {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  
  .settings-cog {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: var(--bg-secondary);
    border: 1px solid var(--border-color);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
    pointer-events: auto;
    position: relative;
    z-index: 10;
  }
  
  .settings-cog:hover {
    background: var(--accent-color);
    color: white;
    border-color: var(--accent-color);
  }
  
  .settings-cog i {
    transition: transform 0.3s ease;
  }
  
  .settings-cog:hover i {
    transform: rotate(45deg);
  }
  
  .settings-dropdown {
    position: absolute;
    top: calc(100% + 10px);
    right: 0;
    width: 280px;
    background: var(--bg-primary);
    border: 1px solid var(--border-color);
    border-radius: 16px;
    padding: 20px;
    box-shadow: 0 10px 40px rgba(0,0,0,0.15);
    z-index: 1000;
    display: none;
    transform: none !important;
    transform-origin: top right;
  }
  
  .settings-dropdown.show {
    display: block;
    animation: fadeIn 0.2s ease;
  }
  
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
  
  .dark-mode .settings-dropdown {
    background: var(--bg-secondary);
    border-color: var(--border-color);
  }
  
  @keyframes slideDown {
    from { opacity: 0; transform: translateY(-10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  
  .settings-section {
    margin-bottom: 16px;
  }
  
  .settings-section:last-child {
    margin-bottom: 0;
  }
  
  .settings-label {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 10px;
    display: block;
  }
  
  /* ===== COLOR PICKER PILLS ===== */
  .color-pills {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }
  
  .color-pill {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    border: 3px solid transparent;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  
  .color-pill:hover {
    transform: scale(1.1);
  }
  
  .color-pill.active {
    border-color: var(--text-primary);
    box-shadow: 0 0 0 2px var(--bg-primary);
  }
  
  /* ===== THEME TOGGLE SWITCH ===== */
  .theme-switch {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 14px;
    background: var(--bg-secondary);
    border-radius: 10px;
  }
  
  .dark-mode .theme-switch {
    background: var(--bg-primary);
  }
  
  .theme-switch-label {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 14px;
    color: var(--text-primary);
  }
  
  /* ===== REAL-TIME INDICATOR ===== */
  .realtime-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 6px 14px;
    background: linear-gradient(135deg, #10b981, #34d399);
    color: white;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 500;
  }
  
  .realtime-dot {
    width: 8px;
    height: 8px;
    background: white;
    border-radius: 50%;
    animation: blink 1.5s infinite;
  }
  
  @keyframes blink {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.3; }
  }
  
  /* ===== STRESS TEST BADGE ===== */
  .stress-test-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 12px;
    background: linear-gradient(135deg, #8b5cf6, #a78bfa);
    color: white;
    border-radius: 16px;
    font-size: 11px;
    font-weight: 600;
    margin-left: 8px;
  }
  
  /* ===== MODERN CARD STYLING ===== */
  .modern-card {
    background: var(--bg-primary);
    border: 1px solid var(--border-color);
    border-radius: 16px;
    overflow: hidden;
  }
  
  .modern-card-header {
    padding: 16px 20px;
    border-bottom: 1px solid var(--border-color);
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: var(--bg-secondary);
  }
  
  .modern-card-header h3 {
    margin: 0;
    font-size: 15px;
    font-weight: 600;
    color: var(--text-primary);
  }
  
  .modern-card-body {
    padding: 20px;
  }
  
  /* ===== BUTTON STYLES ===== */
  .btn-modern {
    padding: 10px 20px;
    border-radius: 10px;
    font-weight: 500;
    font-size: 14px;
    border: none;
    cursor: pointer;
    transition: all 0.2s ease;
    display: inline-flex;
    align-items: center;
    gap: 8px;
  }
  
  .btn-modern-primary {
    background: var(--accent-color);
    color: white;
  }
  
  .btn-modern-primary:hover {
    background: var(--accent-light);
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(21, 101, 192, 0.3);
  }
  
  .btn-modern-outline {
    background: transparent;
    border: 1px solid var(--border-color);
    color: var(--text-primary);
  }
  
  .btn-modern-outline:hover {
    border-color: var(--accent-color);
    color: var(--accent-color);
  }
  
  .btn-stress-test {
    background: linear-gradient(135deg, #8b5cf6, #a78bfa);
    color: white;
    border: none;
  }
  
  .btn-stress-test:hover {
    background: linear-gradient(135deg, #7c3aed, #8b5cf6);
    transform: translateY(-1px);
  }
  
  /* ===== SLIDER STYLING ===== */
  .modern-slider .irs--shiny {
    margin-top: 8px;
  }
  
  .modern-slider .irs--shiny .irs-bar {
    background: linear-gradient(90deg, var(--accent-color), var(--accent-light));
    border: none;
    height: 6px;
  }
  
  .modern-slider .irs--shiny .irs-line {
    background: var(--border-color);
    height: 6px;
    border-radius: 3px;
  }
  
  .modern-slider .irs--shiny .irs-handle {
    width: 20px;
    height: 20px;
    background: var(--accent-color);
    border: 3px solid white;
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    border-radius: 50%;
    top: 22px;
  }
  
  .modern-slider .irs--shiny .irs-single {
    background: var(--accent-color);
    font-size: 12px;
    font-weight: 600;
    padding: 4px 10px;
    border-radius: 6px;
  }
  
  /* Remove black marks/shadows under slider values */
  .modern-slider .irs--shiny .irs-min,
  .modern-slider .irs--shiny .irs-max {
    visibility: hidden !important;
    display: none !important;
  }
  
  .modern-slider .irs--shiny .irs-grid-text {
    color: var(--text-secondary) !important;
    font-size: 10px;
  }
  
  .modern-slider .form-group {
    margin-bottom: 0;
  }
  
  /* Fix label badge alignment */
  .settings-label {
    display: inline-block;
    line-height: 1;
  }
  
  .badge {
    vertical-align: middle;
  }
  
  /* ===== PERFORMANCE METRICS ===== */
  .perf-metrics {
    background: var(--bg-secondary);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 12px 16px;
    margin-top: 12px;
    font-size: 12px;
  }
  
  .perf-metrics-title {
    font-weight: 600;
    color: var(--text-primary);
    margin-bottom: 8px;
  }
  
  .perf-metric-row {
    display: flex;
    justify-content: space-between;
    padding: 4px 0;
    border-bottom: 1px dashed var(--border-color);
  }
  
  .perf-metric-row:last-child {
    border-bottom: none;
  }
  
  /* ===== ERROR BOUNDARY ===== */
  .error-boundary {
    background: #fef2f2;
    border: 1px solid #fecaca;
    border-radius: 12px;
    padding: 20px;
    text-align: center;
    color: var(--danger);
  }
  
  .error-boundary i {
    font-size: 48px;
    margin-bottom: 12px;
    opacity: 0.7;
  }
  
  /* ===== SPSS-STYLE VIEW TOGGLE ===== */
  .view-toggle-container {
    display: flex;
    background: var(--bg-secondary);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 4px;
    gap: 4px;
  }
  
  .view-toggle-btn {
    flex: 1;
    padding: 8px 16px;
    background: transparent;
    border: none;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 500;
    color: var(--text-secondary);
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }
  
  .view-toggle-btn:hover {
    color: var(--text-primary);
    background: rgba(21, 101, 192, 0.05);
  }
  
  .view-toggle-btn.active {
    background: var(--accent-color);
    color: white;
    box-shadow: 0 2px 8px rgba(21, 101, 192, 0.3);
  }
  
  .dark-mode .view-toggle-container {
    background: var(--bg-primary);
  }
  
  /* Variable View Styling */
  .variable-view-table {
    width: 100%;
    border-collapse: collapse;
  }
  
  .variable-view-table th {
    background: linear-gradient(180deg, #f8fafc, #f1f5f9);
    padding: 12px 16px;
    text-align: left;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: var(--text-secondary);
    border-bottom: 2px solid var(--border-color);
  }
  
  .variable-view-table td {
    padding: 12px 16px;
    border-bottom: 1px solid var(--border-color);
    font-size: 13px;
    color: var(--text-primary);
  }
  
  .variable-view-table tr:hover td {
    background: rgba(21, 101, 192, 0.03);
  }
  
  .dark-mode .variable-view-table th {
    background: var(--bg-secondary);
  }
  
  .dark-mode .variable-view-table td {
    border-color: var(--border-color);
  }
  
  .type-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px 10px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
  }
  
  .type-badge.numeric {
    background: rgba(16, 185, 129, 0.1);
    color: #10b981;
  }
  
  .type-badge.string {
    background: rgba(139, 92, 246, 0.1);
    color: #8b5cf6;
  }
  
  .type-badge.readonly {
    background: rgba(100, 116, 139, 0.1);
    color: #64748b;
  }
  
  /* ===== RESPONSIVE ===== */
  @media (max-width: 768px) {
    .kpi-card { padding: 15px; }
    .kpi-value { font-size: 2rem; }
  }
")

# ---- UI ----
ui <- page_fluid(
  useShinyjs(),
  
  # Head content
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"),
    tags$style(custom_css),
    tags$style(HTML("body { font-family: 'Inter', sans-serif; }"))
  ),
  
  theme = bs_theme(
    version = 5,
    primary = "#1565C0",
    base_font = font_google("Inter"),
    heading_font = font_google("Inter")
  ),
  
  # ===== HEADER =====
  div(
    class = "d-flex justify-content-between align-items-center p-3 border-bottom",
    style = "background: var(--bg-primary);",
    
    # Logo & Title
    div(
      class = "d-flex align-items-center gap-3",
      tags$i(class = "fas fa-leaf", style = "font-size: 28px; color: #10b981;"),
      div(
        h4("EnviroAnalyzer", class = "mb-0", style = "font-weight: 700;"),
        tags$small("Environmental Quality Assessment v1.0.0", class = "text-muted")
      )
    ),
    
    # Header Right - Settings Cog
    div(
      class = "header-settings",
      style = "position: relative;",
      
      # Realtime badge
      div(class = "realtime-badge",
          div(class = "realtime-dot"),
          "Live Analysis"
      ),
      
      # Performance indicator (shown after stress test)
      uiOutput("perf_badge"),
      
      # Settings Button - Opens All Settings Modal
      actionLink(
        inputId = "open_settings_modal",
        label = NULL,
        class = "settings-button",
        tags$i(class = "fas fa-cog")
      )
    )
  ),
  
  # ===== MAIN LAYOUT =====
  div(
    class = "d-flex",
    style = "min-height: calc(100vh - 80px);",
    
    # ===== SIDEBAR =====
    div(
      id = "sidebar",
      class = "sidebar-container p-3",
      style = "width: var(--sidebar-width); flex-shrink: 0; position: relative; padding-left: 20px !important;",
      
      # Sidebar Handle (fixed blue strip)
      div(class = "sidebar-handle"),
      
      # ===== MATRIX TYPE - Tab Line Navigation =====
      div(
        class = "mb-4",
        h6(class = "text-muted mb-3", style = "font-size: 11px; text-transform: uppercase; letter-spacing: 1px;", "Matrix Type"),
        div(
          class = "tab-line-nav",
          tags$button(id = "tab-water", class = "tab-line-item active", 
                      onclick = "selectMatrix('Water', this)", "💧 Water"),
          tags$button(id = "tab-air", class = "tab-line-item", 
                      onclick = "selectMatrix('Air', this)", "🌬️ Air"),
          tags$button(id = "tab-soil", class = "tab-line-item", 
                      onclick = "selectMatrix('Soil', this)", "🌍 Soil"),
          tags$button(id = "tab-noise", class = "tab-line-item", 
                      onclick = "selectMatrix('Noise', this)", "🔊 Noise")
        ),
        # Hidden input for Shiny
        hidden(textInput("matrix_type", "", value = "Water"))
      ),
      
      # ===== QCVN SELECTION =====
      div(
        class = "modern-card mb-3",
        div(class = "modern-card-header", 
            h3(tags$i(class = "fas fa-scroll me-2"), "QCVN Standard"),
            tags$button(
              id = "add-qcvn-btn",
              class = "btn-modern btn-modern-outline btn-sm",
              onclick = "openQCVNModal()",
              tags$i(class = "fas fa-plus me-1"),
              "Add"
            )
        ),
        div(
          class = "modern-card-body",
          uiOutput("qcvn_selector_ui"),
          hr(style = "border-color: var(--border-color);"),
          uiOutput("qcvn_column_ui")
        )
      ),
      
      # ===== FILE UPLOAD =====
      div(
        class = "modern-card mb-3",
        div(class = "modern-card-header", 
            h3(tags$i(class = "fas fa-upload me-2"), "Import Data")),
        div(
          class = "modern-card-body",
          fileInput(
            "excel_upload",
            label = NULL,
            accept = c(".xlsx", ".xls", ".csv"),
            placeholder = "Choose Excel/CSV file",
            buttonLabel = tagList(tags$i(class = "fas fa-folder-open me-1"), "Browse")
          ),
          tags$small(class = "text-muted d-block mt-2",
                     tags$i(class = "fas fa-info-circle me-1"),
                     "Supports .xlsx, .xls, .csv formats")
        )
      ),
      
      # ===== SETTINGS =====
      div(
        class = "modern-card mb-3",
        div(class = "modern-card-header", 
            h3(tags$i(class = "fas fa-sliders-h me-2"), "Parameters")),
        div(
          class = "modern-card-body modern-slider",
          
          # Sample Count
          div(
            class = "mb-4",
            div(class = "d-flex justify-content-between mb-2",
                span(class = "settings-label", "Sample Columns"),
                span(id = "sample-count-display", class = "badge bg-primary", "5")
            ),
            sliderInput(
              "n_samples",
              label = NULL,
              min = 1,
              max = 20,
              value = 5,
              step = 1,
              ticks = FALSE
            )
          ),
          
          # Warning Threshold
          div(
            div(class = "d-flex justify-content-between mb-2",
                span(class = "settings-label", "Warning Threshold"),
                span(id = "threshold-display", class = "badge bg-warning", "80%")
            ),
            sliderInput(
              "safety_margin",
              label = NULL,
              min = 50,
              max = 100,
              value = 80,
              step = 5,
              post = "%",
              ticks = FALSE
            )
          )
        )
      ),
      
      # ===== ACTION BUTTONS =====
      div(
        class = "d-grid gap-2",
        actionButton(
          "btn_generate_sample",
          label = tagList(tags$i(class = "fas fa-random me-2"), "Generate Sample Data"),
          class = "btn-modern btn-modern-primary"
        ),
        actionButton(
          "btn_stress_test",
          label = tagList(tags$i(class = "fas fa-bolt me-2"), "Stress Test (100+ cols)"),
          class = "btn-modern btn-stress-test"
        ),
        actionButton(
          "btn_clear_data",
          label = tagList(tags$i(class = "fas fa-eraser me-2"), "Clear All"),
          class = "btn-modern btn-modern-outline"
        )
      ),
      
      # Performance Metrics
      uiOutput("perf_metrics_ui")
    ),
    
    # ===== MAIN CONTENT =====
    div(
      class = "flex-grow-1 p-4",
      style = "background: var(--bg-secondary); overflow-y: auto;",
      
      # ===== DATA ENTRY TAB =====
      div(
        id = "data-entry-section",
        
        # SPSS-Style View Toggle
        div(
          class = "d-flex justify-content-between align-items-center mb-3",
          div(
            class = "view-toggle-container",
            style = "width: 280px;",
            tags$button(
              id = "view-data-btn",
              class = "view-toggle-btn active",
              onclick = "switchView('data', this)",
              tags$i(class = "fas fa-table"),
              "Data View"
            ),
            tags$button(
              id = "view-variable-btn",
              class = "view-toggle-btn",
              onclick = "switchView('variable', this)",
              tags$i(class = "fas fa-list-alt"),
              "Variable View"
            )
          ),
          # Hidden input for Shiny
          hidden(textInput("current_view", "", value = "data"))
        ),
        
        # Data View - Excel Grid Card
        div(
          id = "data-view-panel",
          class = "modern-card mb-4",
          div(
            class = "modern-card-header",
            h3(tags$i(class = "fas fa-table me-2"), "Data Entry Grid"),
            div(
              class = "d-flex gap-2 align-items-center",
              tags$button(
                id = "clear-data-btn",
                class = "btn-modern btn-modern-outline btn-sm",
                onclick = "Shiny.setInputValue('clear_data', Math.random())",
                tags$i(class = "fas fa-eraser me-1"),
                "Clear"
              ),
              downloadButton("download_template", 
                             label = tagList(tags$i(class = "fas fa-download me-1"), "Template"),
                             class = "btn-modern btn-modern-outline btn-sm"),
              downloadButton("download_excel",
                             label = tagList(tags$i(class = "fas fa-file-excel me-1"), "Excel"),
                             class = "btn-modern btn-modern-outline btn-sm"),
              downloadButton("download_pdf",
                             label = tagList(tags$i(class = "fas fa-file-pdf me-1"), "PDF"),
                             class = "btn-modern btn-modern-outline btn-sm")
            )
          ),
          div(
            class = "modern-card-body p-0",
            div(
              class = "excel-grid-container",
              rHandsontableOutput("data_table", height = "450px")
            )
          )
        ),
        
        # Variable View Panel (SPSS-style)
        div(
          id = "variable-view-panel",
          class = "modern-card mb-4",
          style = "display: none;",
          div(
            class = "modern-card-header",
            h3(tags$i(class = "fas fa-list-alt me-2"), "Variable Definitions"),
            tags$small(class = "text-muted", "View and define variable properties")
          ),
          div(
            class = "modern-card-body p-0",
            style = "max-height: 450px; overflow-y: auto;",
            uiOutput("variable_view_table")
          )
        ),
        
        # Validation Messages
        uiOutput("validation_messages"),
        
        # ===== RESULTS SECTION =====
        h5(class = "mb-3", style = "font-weight: 600;", 
           tags$i(class = "fas fa-chart-bar me-2 text-primary"), "Analysis Results"),
        
        # KPI Cards Row
        div(
          class = "row g-3 mb-4",
          div(class = "col-md-2", uiOutput("kpi_total")),
          div(class = "col-md-2", uiOutput("kpi_compliant")),
          div(class = "col-md-2", uiOutput("kpi_warning")),
          div(class = "col-md-2", uiOutput("kpi_critical")),
          div(class = "col-md-4", uiOutput("kpi_rate"))
        ),
        
        # AI Analysis Section
        div(
          id = "ai-analysis-section",
          class = "modern-card mb-4",
          style = "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; display: none;",
          div(
            class = "modern-card-header",
            style = "border-bottom: 1px solid rgba(255,255,255,0.2);",
            h3(tags$i(class = "fas fa-robot me-2"), "AI Analysis"),
            actionButton(
              inputId = "run_ai_analysis",
              label = "Analyze with AI",
              class = "btn-sm",
              style = "background: white; color: #667eea; border: none; padding: 6px 16px; border-radius: 8px; font-weight: 600;",
              icon = icon("magic")
            )
          ),
          div(
            class = "modern-card-body",
            div(
              id = "ai-result-container",
              style = "min-height: 100px; max-height: 300px; overflow-y: auto; padding: 15px; background: rgba(255,255,255,0.1); border-radius: 8px;",
              uiOutput("ai_analysis_result")
            )
          )
        ),
        
        # Critical Alerts Section
        uiOutput("critical_alerts_section"),
        
        # Charts Section
        div(
          class = "modern-card mt-4",
          div(
            class = "modern-card-header",
            h3(tags$i(class = "fas fa-chart-area me-2"), "Visualization"),
            # Chart Type Tab Line
            div(
              class = "tab-line-nav horizontal mb-0",
              style = "border-bottom: none;",
              tags$button(id = "chart-bar", class = "tab-line-item active", 
                          onclick = "selectChart('bar', this)", "📊 Compare"),
              tags$button(id = "chart-radar", class = "tab-line-item", 
                          onclick = "selectChart('radar', this)", "🎯 Radar"),
              tags$button(id = "chart-gauge", class = "tab-line-item", 
                          onclick = "selectChart('gauge', this)", "⏱️ Gauge"),
              tags$button(id = "chart-heatmap", class = "tab-line-item", 
                          onclick = "selectChart('heatmap', this)", "🔥 Heatmap"),
              tags$button(id = "chart-pie", class = "tab-line-item", 
                          onclick = "selectChart('pie', this)", "🥧 Summary")
            ),
            hidden(textInput("chart_type", "", value = "bar"))
          ),
          div(
            class = "modern-card-body",
            plotOutput("main_chart", height = "500px")
          )
        ),
        
        # Compliance Table
        div(
          class = "modern-card mt-4",
          div(class = "modern-card-header",
              h3(tags$i(class = "fas fa-clipboard-check me-2"), "Detailed Assessment"),
              div(
                class = "d-flex gap-2",
                downloadButton("download_assessment_excel",
                               label = tagList(tags$i(class = "fas fa-file-excel me-1"), "Excel"),
                               class = "btn-modern btn-modern-outline btn-sm"),
                downloadButton("download_assessment_pdf",
                               label = tagList(tags$i(class = "fas fa-file-pdf me-1"), "PDF"),
                               class = "btn-modern btn-modern-outline btn-sm")
              )
          ),
          div(
            class = "modern-card-body",
            gt_output("compliance_table")
          )
        )
      )
    )
  ),
  
  # ===== QCVN MODAL =====
  div(
    id = "qcvn-modal-overlay",
    class = "qcvn-modal-overlay",
    onclick = "if(event.target === this) closeQCVNModal()",
    div(
      class = "qcvn-modal",
      div(
        class = "qcvn-modal-header",
        h4(tags$i(class = "fas fa-plus-circle me-2"), "Add Custom QCVN Standard", style = "margin: 0;"),
        tags$button(
          class = "btn-close",
          onclick = "closeQCVNModal()",
          tags$i(class = "fas fa-times")
        )
      ),
      div(
        class = "qcvn-modal-body",
        div(
          class = "row g-3",
          div(
            class = "col-md-6",
            tags$label(class = "form-label", "Standard Name"),
            textInput("new_qcvn_name", NULL, placeholder = "e.g., QCVN 09:2023/BTNMT")
          ),
          div(
            class = "col-md-6",
            tags$label(class = "form-label", "Matrix Type"),
            selectInput("new_qcvn_matrix", NULL, 
                        choices = c("Water" = "Water", "Air" = "Air", "Soil" = "Soil", "Noise" = "Noise"))
          ),
          div(
            class = "col-12",
            tags$label(class = "form-label", "Description"),
            textInput("new_qcvn_desc", NULL, placeholder = "Brief description of the standard")
          ),
          div(
            class = "col-12",
            tags$label(class = "form-label", "Parameters (one per line: Parameter, Unit, Limit, Type)"),
            tags$textarea(
              id = "new_qcvn_params",
              class = "form-control",
              rows = "8",
              style = "font-family: monospace; font-size: 12px;",
              placeholder = "pH, -, 6.5-8.5, range\nBOD5, mg/L, 15, max\nDO, mg/L, 4, min"
            )
          )
        )
      ),
      div(
        class = "qcvn-modal-footer",
        tags$button(
          class = "btn-modern btn-modern-outline",
          onclick = "closeQCVNModal()",
          "Cancel"
        ),
        actionButton(
          "save_custom_qcvn",
          tagList(tags$i(class = "fas fa-save me-1"), "Save Standard"),
          class = "btn-modern btn-modern-primary"
        )
      )
    )
  ),
  
  # ===== JAVASCRIPT =====
  tags$script(HTML("
    // ===== QCVN MODAL =====
    function openQCVNModal() {
      document.getElementById('qcvn-modal-overlay').classList.add('show');
    }
    
    function closeQCVNModal() {
      document.getElementById('qcvn-modal-overlay').classList.remove('show');
    }
    
    // ===== SETTINGS DROPDOWN =====
    function toggleSettings() {
      var dropdown = document.getElementById('settings-dropdown');
      dropdown.classList.toggle('show');
    }
    
    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
      var dropdown = document.getElementById('settings-dropdown');
      var cog = document.getElementById('settings-cog-btn');
      if (dropdown && cog && !dropdown.contains(e.target) && !cog.contains(e.target)) {
        dropdown.classList.remove('show');
      }
    });
    
    // ===== MATRIX TYPE SELECTION WITH DEBOUNCE =====
    var matrixDebounceTimer = null;
    var lastMatrixType = 'Water';
    function selectMatrix(type, el) {
      // Prevent rapid clicking
      if (matrixDebounceTimer) {
        clearTimeout(matrixDebounceTimer);
      }
      
      // Update UI immediately
      document.querySelectorAll('#sidebar .tab-line-nav:first-of-type .tab-line-item').forEach(function(tab) {
        tab.classList.remove('active');
      });
      el.classList.add('active');
      
      // Debounce the Shiny update
      matrixDebounceTimer = setTimeout(function() {
        if (type !== lastMatrixType) {
          lastMatrixType = type;
          Shiny.setInputValue('matrix_type', type, {priority: 'event'});
        }
      }, 300);
    }
    
    // ===== CHART TYPE SELECTION =====
    function selectChart(type, el) {
      document.querySelectorAll('.modern-card-header .tab-line-item').forEach(function(tab) {
        tab.classList.remove('active');
      });
      el.classList.add('active');
      Shiny.setInputValue('chart_type', type);
    }
    
    // ===== SPSS-STYLE VIEW SWITCHING =====
    function switchView(view, el) {
      // Update toggle buttons
      document.querySelectorAll('.view-toggle-btn').forEach(function(btn) {
        btn.classList.remove('active');
      });
      el.classList.add('active');
      
      // Toggle panels
      var dataPanel = document.getElementById('data-view-panel');
      var variablePanel = document.getElementById('variable-view-panel');
      
      if (view === 'data') {
        if (dataPanel) dataPanel.style.display = 'block';
        if (variablePanel) variablePanel.style.display = 'none';
      } else {
        if (dataPanel) dataPanel.style.display = 'none';
        if (variablePanel) variablePanel.style.display = 'block';
      }
      
      // Update Shiny input
      Shiny.setInputValue('current_view', view);
      
      // Save preference
      saveToLocalStorage('enviro_current_view', view);
    }
    
    // ===== ACCENT COLOR PICKER =====
    function setAccentColor(color, el) {
      document.documentElement.style.setProperty('--accent-color', color);
      document.querySelectorAll('.color-pill').forEach(function(pill) {
        pill.classList.remove('active');
      });
      el.classList.add('active');
      Shiny.setInputValue('accent_color', color);
      
      // Save to localStorage
      if (localStorage) {
        localStorage.setItem('enviro_accent_color', color);
      }
    }
    
    // ===== LOCAL STORAGE PERSISTENCE =====
    function saveToLocalStorage(key, data) {
      if (localStorage) {
        try {
          localStorage.setItem(key, JSON.stringify(data));
        } catch(e) {
          console.warn('LocalStorage save failed:', e);
        }
      }
    }
    
    function loadFromLocalStorage(key) {
      if (localStorage) {
        try {
          var data = localStorage.getItem(key);
          return data ? JSON.parse(data) : null;
        } catch(e) {
          console.warn('LocalStorage load failed:', e);
          return null;
        }
      }
      return null;
    }
    
    // Load saved preferences on page load
    document.addEventListener('DOMContentLoaded', function() {
      // Restore accent color
      var savedColor = loadFromLocalStorage('enviro_accent_color');
      if (savedColor) {
        document.documentElement.style.setProperty('--accent-color', savedColor);
        document.querySelectorAll('.color-pill').forEach(function(pill) {
          pill.classList.remove('active');
          if (pill.getAttribute('data-color') === savedColor) {
            pill.classList.add('active');
          }
        });
      }
      
      // Restore dark mode
      var savedDarkMode = loadFromLocalStorage('enviro_dark_mode');
      if (savedDarkMode === true) {
        document.body.classList.add('dark-mode');
        // Update Shiny input after a small delay
        setTimeout(function() {
          if (Shiny.setInputValue) {
            Shiny.setInputValue('dark_mode', true);
          }
        }, 500);
      }
      
      // Restore column names
      var savedColumns = loadFromLocalStorage('enviro_column_names');
      if (savedColumns) {
        Shiny.setInputValue('restored_columns', savedColumns);
      }
      
      // Restore current view (Data/Variable)
      var savedView = loadFromLocalStorage('enviro_current_view');
      if (savedView) {
        setTimeout(function() {
          var btn = document.getElementById(savedView === 'variable' ? 'view-variable-btn' : 'view-data-btn');
          if (btn) {
            switchView(savedView, btn);
          }
        }, 300);
      }
      
      // Restore saved matrix data if persistence enabled
      var savedMatrixData = loadFromLocalStorage('enviro_matrix_data');
      if (savedMatrixData) {
        setTimeout(function() {
          Shiny.setInputValue('restored_matrix_data', savedMatrixData);
        }, 600);
      }
    });
    
    // ===== SLIDER DISPLAY UPDATES =====
    Shiny.addCustomMessageHandler('updateSliderDisplay', function(data) {
      if (data.id === 'sample-count-display') {
        document.getElementById('sample-count-display').innerText = data.value;
      }
      if (data.id === 'threshold-display') {
        document.getElementById('threshold-display').innerText = data.value + '%';
      }
    });
    
    // ===== COLUMN HEADER RENAMING =====
    var columnRenameSetup = false;
    Shiny.addCustomMessageHandler('setupColumnRename', function(data) {
      // Wait for table to fully render
      setTimeout(function() {
        // Target the header row specifically
        var headerRow = document.querySelector('.handsontable thead tr:first-child');
        if (!headerRow) {
          console.log('Header row not found, retrying...');
          setTimeout(function() { Shiny.onInputChange('setupColumnRename', Math.random()); }, 500);
          return;
        }
        
        var headers = headerRow.querySelectorAll('th');
        headers.forEach(function(th, index) {
          // Only allow renaming sample columns (index >= 4, which are Sample_1, Sample_2, etc.)
          if (index >= 4 && !th.hasAttribute('data-rename-enabled')) {
            th.setAttribute('data-rename-enabled', 'true');
            th.classList.add('editable-header');
            th.style.cursor = 'pointer';
            
            th.addEventListener('dblclick', function(e) {
              e.preventDefault();
              e.stopPropagation();
              var currentName = th.innerText.trim();
              var newName = prompt('Rename column: ' + currentName, currentName);
              if (newName && newName.trim() !== '' && newName.trim() !== currentName) {
                th.innerText = newName.trim();
                Shiny.setInputValue('column_renamed', {
                  index: index,
                  oldName: currentName,
                  newName: newName.trim(),
                  timestamp: Date.now()
                });
                
                // Save to localStorage
                var savedColumns = loadFromLocalStorage('enviro_column_names') || {};
                savedColumns[index] = newName.trim();
                saveToLocalStorage('enviro_column_names', savedColumns);
              }
            });
          }
        });
      }, 800);
    });
    
    // ===== INPUT VALIDATION - HIGHLIGHT INVALID CELLS =====
    Shiny.addCustomMessageHandler('highlightInvalidCells', function(data) {
      setTimeout(function() {
        // Clear previous highlights
        document.querySelectorAll('.handsontable td.cell-error').forEach(function(td) {
          td.classList.remove('cell-error');
        });
        
        // Add new highlights
        if (data.cells && data.cells.length > 0) {
          var table = document.querySelector('.handsontable tbody');
          if (table) {
            data.cells.forEach(function(cell) {
              var row = table.querySelectorAll('tr')[cell.row];
              if (row) {
                var td = row.querySelectorAll('td')[cell.col];
                if (td) {
                  td.classList.add('cell-error');
                }
              }
            });
          }
        }
      }, 100);
    });
    
    // ===== SAVE DARK MODE PREFERENCE =====
    Shiny.addCustomMessageHandler('saveDarkMode', function(data) {
      saveToLocalStorage('enviro_dark_mode', data.enabled);
    });
    
    // ===== SAVE MATRIX DATA =====
    Shiny.addCustomMessageHandler('saveMatrixData', function(data) {
      if (data.enabled) {
        saveToLocalStorage('enviro_matrix_data', data.matrixData);
      }
    });
  "))
)

# ---- SERVER ----
server <- function(input, output, session) {
  
  # ---- Load User Config ----
  user_config <- reactiveVal(load_user_config())
  
  # ---- Reactive Values ----
  rv <- reactiveValues(
    data = NULL,
    assessed_data = NULL,
    stats = NULL,
    current_standard = "Surface_Water",
    current_column = "A1",
    column_names = list(),
    validation_errors = list(),
    perf_time = NULL,
    perf_columns = NULL,
    custom_qcvn = list(),  # Store custom QCVN standards
    ai_enabled = FALSE,  # AI on/off
    ai_ready = FALSE  # AI ready to use
  )
  
  # ---- Initialize from Config ----
  observe({
    config <- user_config()
    
    # Apply theme colors
    theme_config <- config$theme
    if (!is.null(theme_config)) {
      accent_color <- get_config_value(config, c("theme", "accent_color"), "#1565C0")
      
      shinyjs::runjs(sprintf("
        document.documentElement.style.setProperty('--accent-color', '%s');
        document.documentElement.style.setProperty('--success', '%s');
        document.documentElement.style.setProperty('--warning', '%s');
        document.documentElement.style.setProperty('--danger', '%s');
        document.documentElement.style.setProperty('--bg-primary', '%s');
        document.documentElement.style.setProperty('--text-primary', '%s');
        document.documentElement.style.setProperty('--text-secondary', '%s');
      ",
        accent_color,
        get_config_value(config, c("theme", "success_color"), "#10b981"),
        get_config_value(config, c("theme", "warning_color"), "#f59e0b"),
        get_config_value(config, c("theme", "danger_color"), "#ef4444"),
        get_config_value(config, c("theme", "background"), "#ffffff"),
        get_config_value(config, c("theme", "text_primary"), "#1e293b"),
        get_config_value(config, c("theme", "text_secondary"), "#64748b")
      ))
      
      # Apply dark mode if set
      theme_mode <- get_config_value(config, c("theme", "mode"), "light")
      if (theme_mode == "dark") {
        shinyjs::runjs("document.body.classList.add('dark-mode');")
      } else {
        shinyjs::runjs("document.body.classList.remove('dark-mode');")
      }
    }
    
    # Load last selected QCVN
    last_qcvn <- get_config_value(config, c("qcvn", "last_selected"), "")
    if (last_qcvn != "" && last_qcvn %in% names(QCVN_Standards)) {
      rv$current_standard <- last_qcvn
    }
    
    # Load AI settings
    ai_enabled <- get_config_value(config, c("ai", "enabled"), FALSE)
    if (is_ai_available() && ai_enabled) {
      updateSwitchInput(session, "enable_ai", value = TRUE)
    }
  })
  
  # ---- Save Config on Changes ----
  observeEvent(rv$current_standard, {
    config <- user_config()
    config <- set_config_value(config, c("qcvn", "last_selected"), rv$current_standard)
    user_config(config)
    save_user_config(config)
  }, ignoreInit = TRUE)
  
  # ---- Initialize AI on Startup ----
  observe({
    if (is_ai_available() && N8N_CONFIG$auto_enable) {
      updateSwitchInput(session, "enable_ai", value = TRUE)
    }
  })
  
  # ---- AI Status Message ----
  output$ai_status_message <- renderUI({
    if (rv$ai_ready) {
      div(
        style = "color: #10b981;",
        tags$i(class = "fas fa-check-circle me-1"),
        "AI is online and ready"
      )
    } else {
      div(
        style = "color: var(--text-secondary);",
        tags$i(class = "fas fa-info-circle me-1"),
        "Enable AI to get intelligent insights"
      )
    }
  })
  
  # ---- AI Enable/Disable Handler ----
  observeEvent(input$enable_ai, {
    if (input$enable_ai) {
      if (!is_ai_available()) {
        showNotification(
          "⚠️ AI service is not configured. Please contact the developer.",
          type = "warning",
          duration = 5
        )
        updateSwitchInput(session, "enable_ai", value = FALSE)
        return()
      }
      
      endpoint <- DEFAULT_N8N_ENDPOINT
      showNotification("🔌 Connecting to AI service...", type = "message", duration = 2)
      
      result <- test_n8n_connection(endpoint)
      
      if (result) {
        rv$ai_enabled <- TRUE
        rv$ai_ready <- TRUE
        
        # Save AI enabled state to config
        config <- user_config()
        config <- set_config_value(config, c("ai", "enabled"), TRUE)
        user_config(config)
        save_user_config(config)
        
        showNotification("✅ AI Assistant is ready!", type = "message", duration = 3)
        shinyjs::runjs("
          document.getElementById('ai_status_indicator').style.display = 'block';
          document.getElementById('ai_status_indicator').style.background = '#10b98120';
          document.getElementById('ai_status_indicator').style.borderLeft = '3px solid #10b981';
          document.getElementById('ai-analysis-section').style.display = 'block';
        ")
      } else {
        rv$ai_enabled <- FALSE
        rv$ai_ready <- FALSE
        showNotification(
          "❌ Cannot connect to AI service. Check internet connection.",
          type = "error",
          duration = 5
        )
        updateSwitchInput(session, "enable_ai", value = FALSE)
        shinyjs::runjs("
          document.getElementById('ai_status_indicator').style.display = 'block';
          document.getElementById('ai_status_indicator').style.background = '#ef444420';
          document.getElementById('ai_status_indicator').style.borderLeft = '3px solid #ef4444';
        ")
      }
    } else {
      rv$ai_enabled <- FALSE
      rv$ai_ready <- FALSE
      
      # Save AI disabled state to config
      config <- user_config()
      config <- set_config_value(config, c("ai", "enabled"), FALSE)
      user_config(config)
      save_user_config(config)
      
      shinyjs::runjs("
        document.getElementById('ai_status_indicator').style.display = 'none';
        document.getElementById('ai-analysis-section').style.display = 'none';
      ")
      showNotification("AI Assistant disabled", type = "message", duration = 2)
    }
  })
  
  # ---- AI Analysis UI ----
  output$ai_analysis_result <- renderUI({
    div(
      style = "text-align: center; padding: 30px; color: rgba(255,255,255,0.7);",
      tags$i(class = "fas fa-robot", style = "font-size: 48px; margin-bottom: 15px;"),
      p("Click 'Analyze with AI' to get intelligent insights", 
        style = "margin: 0; font-size: 14px;")
    )
  })
  
  observeEvent(input$run_ai_analysis, {
    req(rv$assessed_data, rv$ai_ready)
    
    output$ai_analysis_result <- renderUI({
      div(
        style = "text-align: center; padding: 40px;",
        tags$i(class = "fas fa-spinner fa-spin", 
               style = "font-size: 32px; margin-bottom: 15px; color: white;"),
        p("AI is analyzing your data...", 
          style = "margin: 0; color: white; font-size: 14px;")
      )
    })
    
    qcvn_name <- QCVN_Standards[[rv$current_standard]]$name
    endpoint <- DEFAULT_N8N_ENDPOINT
    
    analysis <- ai_analyze_results(rv$assessed_data, qcvn_name, endpoint)
    
    output$ai_analysis_result <- renderUI({
      div(
        style = "padding: 15px; color: white; line-height: 1.6;",
        div(
          style = "background: rgba(255,255,255,0.15); padding: 12px; border-radius: 8px; border-left: 4px solid white;",
          tags$strong(style = "font-size: 15px;", "🤖 AI Analysis:"),
          tags$p(style = "margin: 8px 0 0 0; white-space: pre-wrap;", analysis)
        )
      )
    })
  })
  
  # ---- ERROR BOUNDARY WRAPPER ----
  safe_render <- function(expr) {
    tryCatch(
      expr,
      error = function(e) {
        div(
          class = "error-boundary",
          tags$i(class = "fas fa-exclamation-triangle"),
          p("An error occurred while rendering this component."),
          tags$small(class = "text-muted", e$message)
        )
      }
    )
  }
  
  # ---- Excel/CSV File Upload ----
  observeEvent(input$excel_upload, {
    req(input$excel_upload)
    
    file <- input$excel_upload
    ext <- tools::file_ext(file$name)
    
    tryCatch({
      # Read file based on extension
      if (ext %in% c("xlsx", "xls")) {
        # Need readxl package
        if (!requireNamespace("readxl", quietly = TRUE)) {
          showNotification("Installing readxl package...", type = "message")
          install.packages("readxl", repos = "https://cloud.r-project.org", quiet = TRUE)
        }
        imported_data <- readxl::read_excel(file$datapath)
      } else if (ext == "csv") {
        imported_data <- read.csv(file$datapath, stringsAsFactors = FALSE)
      } else {
        showNotification("Unsupported file format", type = "error")
        return()
      }
      
      # Convert to data frame
      imported_data <- as.data.frame(imported_data)
      
      # Update the data
      rv$data <- imported_data
      
      showNotification(
        paste("Imported", nrow(imported_data), "rows,", ncol(imported_data), "columns"),
        type = "message",
        duration = 3
      )
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })
  
  # ---- Clear Data ----
  observeEvent(input$clear_data, {
    rv$data <- NULL
    rv$assessed_data <- NULL
    rv$stats <- NULL
    showNotification("Data cleared", type = "message", duration = 2)
  })
  
  # ---- Save Custom QCVN ----
  observeEvent(input$save_custom_qcvn, {
    req(input$new_qcvn_name)
    
    # Parse parameters from textarea
    params_text <- input$new_qcvn_params
    if (is.null(params_text) || params_text == "") {
      showNotification("Please enter at least one parameter", type = "warning")
      return()
    }
    
    lines <- strsplit(params_text, "\n")[[1]]
    params_df <- data.frame(
      Parameter = character(),
      Unit = character(),
      Limit = character(),
      Type = character(),
      stringsAsFactors = FALSE
    )
    
    for (line in lines) {
      if (trimws(line) == "") next
      parts <- strsplit(line, ",")[[1]]
      if (length(parts) >= 4) {
        params_df <- rbind(params_df, data.frame(
          Parameter = trimws(parts[1]),
          Unit = trimws(parts[2]),
          Limit = trimws(parts[3]),
          Type = trimws(parts[4]),
          stringsAsFactors = FALSE
        ))
      }
    }
    
    if (nrow(params_df) == 0) {
      showNotification("Could not parse any parameters. Use format: Parameter, Unit, Limit, Type", type = "error")
      return()
    }
    
    # Create unique ID for custom standard
    custom_id <- paste0("Custom_", gsub("[^A-Za-z0-9]", "_", input$new_qcvn_name))
    
    # Store in reactive values
    rv$custom_qcvn[[custom_id]] <- list(
      name = input$new_qcvn_name,
      description = input$new_qcvn_desc,
      matrix = input$new_qcvn_matrix,
      parameters = params_df
    )
    
    showNotification(
      paste("Custom standard", input$new_qcvn_name, "saved with", nrow(params_df), "parameters"),
      type = "message",
      duration = 3
    )
    
    # Close modal
    shinyjs::runjs("closeQCVNModal();")
    
    # Clear inputs
    updateTextInput(session, "new_qcvn_name", value = "")
    updateTextInput(session, "new_qcvn_desc", value = "")
    shinyjs::runjs("document.getElementById('new_qcvn_params').value = '';")
  })
  
  # ---- Theme Switching ----
  observe({
    if (input$dark_mode) {
      shinyjs::runjs("document.body.classList.add('dark-mode');")
      session$sendCustomMessage('saveDarkMode', list(enabled = TRUE))
    } else {
      shinyjs::runjs("document.body.classList.remove('dark-mode');")
      session$sendCustomMessage('saveDarkMode', list(enabled = FALSE))
    }
  }) %>% bindEvent(input$dark_mode)
  
  # ---- Update Slider Displays ----
  observe({
    session$sendCustomMessage('updateSliderDisplay', 
                               list(id = 'sample-count-display', value = input$n_samples))
  }) %>% bindEvent(input$n_samples)
  
  observe({
    session$sendCustomMessage('updateSliderDisplay', 
                               list(id = 'threshold-display', value = input$safety_margin))
  }) %>% bindEvent(input$safety_margin)
  
  # ---- Dynamic QCVN Selector ----
  output$qcvn_selector_ui <- renderUI({
    # Isolate to prevent reactivity issues with rapid clicks
    matrix <- isolate(input$matrix_type)
    if (is.null(matrix) || matrix == "") matrix <- "Water"
    
    tryCatch({
      standards <- MATRIX_TYPES[[matrix]]$standards
      if (is.null(standards) || length(standards) == 0) {
        return(div(class = "text-muted", "No standards available"))
      }
      
      choices <- standards
      names(choices) <- sapply(standards, function(s) {
        if (!is.null(QCVN_Standards[[s]])) {
          QCVN_Standards[[s]]$name
        } else {
          s
        }
      })
      
      selectInput(
        "qcvn_standard",
        label = NULL,
        choices = choices,
        selected = standards[1],
        width = "100%"
      )
    }, error = function(e) {
      div(class = "text-danger small", "Error loading standards")
    })
  }) %>% bindEvent(input$matrix_type, ignoreNULL = FALSE, ignoreInit = FALSE)
  
  # ---- Dynamic Column Selector ----
  output$qcvn_column_ui <- renderUI({
    standard <- input$qcvn_standard
    if (is.null(standard) || standard == "") {
      return(div(class = "text-muted small", "Select a standard first"))
    }
    
    tryCatch({
      columns <- get_available_columns(standard)
      std <- QCVN_Standards[[standard]]
      
      if (is.null(columns) || length(columns) == 0) {
        return(div(class = "text-muted", "No columns available"))
      }
      
      choices <- columns
      names(choices) <- sapply(columns, function(c) {
        desc <- std$column_descriptions[[c]]
        if (!is.null(desc)) {
          paste0(c, " - ", desc)
        } else {
          c
        }
      })
      
      selectInput(
        "qcvn_column",
        label = NULL,
        choices = choices,
        selected = columns[1],
        width = "100%"
      )
    }, error = function(e) {
      div(class = "text-danger small", "Error loading columns")
    })
  }) %>% bindEvent(input$qcvn_standard, ignoreNULL = FALSE, ignoreInit = FALSE)
  
  # ---- Initialize Data Template (with debounce) ----
  observe({
    # Use tryCatch to prevent crashes
    tryCatch({
      req(input$qcvn_standard, input$qcvn_column, input$n_samples)
      
      # Validate inputs exist in QCVN_Standards
      if (is.null(QCVN_Standards[[input$qcvn_standard]])) {
        return()
      }
      
      rv$data <- create_data_template(
        input$qcvn_standard,
        input$qcvn_column,
        input$n_samples
      )
      rv$current_standard <- input$qcvn_standard
      rv$current_column <- input$qcvn_column
      
      # Enable column renaming after delay
      shinyjs::delay(500, {
        session$sendCustomMessage('setupColumnRename', list())
      })
    }, error = function(e) {
      # Silently handle errors from rapid switching
      message("Template creation skipped: ", e$message)
    })
  }) %>% bindEvent(input$qcvn_standard, input$qcvn_column, input$n_samples, 
                   ignoreNULL = TRUE, ignoreInit = FALSE)
  
  # ---- Render Handsontable ----
  output$data_table <- renderRHandsontable({
    req(rv$data)
    
    rhandsontable(rv$data, rowHeaders = FALSE, stretchH = "all") %>%
      hot_col("Parameter", readOnly = TRUE, width = 150) %>%
      hot_col("Unit", readOnly = TRUE, width = 70) %>%
      hot_col("Limit", readOnly = TRUE, width = 80) %>%
      hot_col("Type", readOnly = TRUE, width = 60) %>%
      hot_context_menu(allowRowEdit = FALSE, allowColEdit = FALSE) %>%
      hot_cols(columnSorting = FALSE)
  })
  
  # ---- INPUT VALIDATION ----
  validate_data <- function(data) {
    errors <- list()
    
    # Get sample columns (columns 5 and beyond)
    sample_cols <- names(data)[5:ncol(data)]
    
    for (i in seq_along(sample_cols)) {
      col <- sample_cols[i]
      values <- data[[col]]
      
      for (j in seq_along(values)) {
        val <- values[j]
        
        # Check for non-numeric
        if (!is.na(val) && !is.numeric(val)) {
          tryCatch({
            as.numeric(val)
          }, warning = function(w) {
            errors[[length(errors) + 1]] <- list(row = j - 1, col = i + 3, msg = "Non-numeric value")
          })
        }
        
        # Check for negative values
        if (!is.na(val) && is.numeric(val) && val < 0) {
          errors[[length(errors) + 1]] <- list(row = j - 1, col = i + 3, msg = "Negative value")
        }
      }
    }
    
    return(errors)
  }
  
  # ---- Update Data from Handsontable ----
  observeEvent(input$data_table, {
    if (!is.null(input$data_table)) {
      rv$data <- hot_to_r(input$data_table)
      
      # Validate input
      rv$validation_errors <- validate_data(rv$data)
      
      # Highlight invalid cells
      if (length(rv$validation_errors) > 0) {
        session$sendCustomMessage('highlightInvalidCells', 
                                   list(cells = rv$validation_errors))
      } else {
        session$sendCustomMessage('highlightInvalidCells', list(cells = list()))
      }
      
      # Process data
      processed <- process_handsontable_data(rv$data)
      
      if (!is.null(processed)) {
        rv$assessed_data <- check_compliance(
          processed,
          rv$current_standard,
          rv$current_column,
          input$safety_margin
        )
        rv$stats <- calculate_compliance_stats(rv$assessed_data)
      }
      
      # Auto-save to localStorage if persistence is enabled
      if (isTRUE(input$enable_persistence)) {
        # Convert data to JSON-safe format
        data_list <- as.list(rv$data)
        session$sendCustomMessage('saveMatrixData', 
                                   list(enabled = TRUE, 
                                        matrixData = list(
                                          data = data_list,
                                          standard = rv$current_standard,
                                          column = rv$current_column,
                                          timestamp = as.character(Sys.time())
                                        )))
      }
    }
  })
  
  # ---- Validation Messages ----
  output$validation_messages <- renderUI({
    if (length(rv$validation_errors) > 0) {
      div(
        class = "alert alert-warning d-flex align-items-center mb-3",
        style = "border-radius: 10px;",
        tags$i(class = "fas fa-exclamation-triangle me-2"),
        paste0(length(rv$validation_errors), " validation issue(s) found. ",
               "Check cells highlighted in red.")
      )
    }
  })
  
  # ---- Generate Sample Data ----
  observeEvent(input$btn_generate_sample, {
    req(input$qcvn_standard, input$qcvn_column, input$n_samples)
    
    rv$data <- generate_sample_data(
      input$qcvn_standard,
      input$qcvn_column,
      input$n_samples,
      compliance_rate = 0.7,
      seed = as.numeric(Sys.time())
    )
    
    # Re-enable column renaming
    session$sendCustomMessage('setupColumnRename', list())
    
    showNotification("Sample data generated!", type = "message", duration = 3)
  })
  
  # ---- STRESS TEST (100+ Columns) ----
  observeEvent(input$btn_stress_test, {
    req(input$qcvn_standard, input$qcvn_column)
    
    showNotification("Running stress test with 100+ columns...", type = "message", duration = 2)
    
    # Start timing
    start_time <- Sys.time()
    
    # Generate large dataset
    n_stress_cols <- 120
    rv$data <- generate_sample_data(
      input$qcvn_standard,
      input$qcvn_column,
      n_stress_cols,
      compliance_rate = 0.7,
      seed = as.numeric(Sys.time())
    )
    
    # Process and assess
    processed <- process_handsontable_data(rv$data)
    if (!is.null(processed)) {
      rv$assessed_data <- check_compliance(
        processed,
        rv$current_standard,
        rv$current_column,
        input$safety_margin
      )
      rv$stats <- calculate_compliance_stats(rv$assessed_data)
    }
    
    # End timing
    end_time <- Sys.time()
    rv$perf_time <- round(as.numeric(difftime(end_time, start_time, units = "secs")), 2)
    rv$perf_columns <- n_stress_cols
    
    showNotification(
      paste0("Stress test complete! ", n_stress_cols, " columns processed in ", rv$perf_time, "s"),
      type = "message",
      duration = 5
    )
    
    # Re-enable column renaming
    session$sendCustomMessage('setupColumnRename', list())
  })
  
  # ---- Performance Badge ----
  output$perf_badge <- renderUI({
    if (!is.null(rv$perf_time)) {
      div(
        class = "stress-test-badge",
        tags$i(class = "fas fa-bolt"),
        paste0(rv$perf_columns, " cols in ", rv$perf_time, "s")
      )
    }
  })
  
  # ---- Performance Metrics Panel ----
  output$perf_metrics_ui <- renderUI({
    if (!is.null(rv$perf_time)) {
      div(
        class = "perf-metrics mt-3",
        div(class = "perf-metrics-title", 
            tags$i(class = "fas fa-tachometer-alt me-2"), "Performance Metrics"),
        div(class = "perf-metric-row",
            span("Columns Processed:"),
            span(class = "fw-bold", rv$perf_columns)),
        div(class = "perf-metric-row",
            span("Processing Time:"),
            span(class = "fw-bold", paste0(rv$perf_time, " seconds"))),
        div(class = "perf-metric-row",
            span("Throughput:"),
            span(class = "fw-bold", paste0(round(rv$perf_columns / rv$perf_time, 1), " cols/sec")))
      )
    }
  })
  
  # ---- Clear Data ----
  observeEvent(input$btn_clear_data, {
    req(input$qcvn_standard, input$qcvn_column, input$n_samples)
    
    rv$data <- create_data_template(
      input$qcvn_standard,
      input$qcvn_column,
      input$n_samples
    )
    rv$assessed_data <- NULL
    rv$stats <- NULL
    rv$validation_errors <- list()
    rv$perf_time <- NULL
    rv$perf_columns <- NULL
    
    showNotification("Data cleared!", type = "warning", duration = 2)
  })
  
  # ---- KPI Cards (Minimalist Outline Style) ----
  output$kpi_total <- renderUI({
    val <- if (!is.null(rv$stats)) rv$stats$total_parameters else 0
    div(class = "kpi-card kpi-info",
        div(class = "kpi-value", val),
        div(class = "kpi-label", "Total Parameters"))
  })
  
  output$kpi_compliant <- renderUI({
    val <- if (!is.null(rv$stats)) rv$stats$compliant else 0
    div(class = "kpi-card kpi-success",
        div(class = "kpi-value", val),
        div(class = "kpi-label", "Compliant"))
  })
  
  output$kpi_warning <- renderUI({
    val <- if (!is.null(rv$stats)) rv$stats$warning else 0
    div(class = "kpi-card kpi-warning",
        div(class = "kpi-value", val),
        div(class = "kpi-label", "Warning"))
  })
  
  output$kpi_critical <- renderUI({
    val <- if (!is.null(rv$stats)) rv$stats$non_compliant else 0
    div(class = "kpi-card kpi-danger",
        div(class = "kpi-value", val),
        div(class = "kpi-label", "Critical"))
  })
  
  # ---- SPSS-Style Variable View Table ----
  output$variable_view_table <- renderUI({
    # Show variable definitions even without data
    if (is.null(rv$data) || nrow(rv$data) == 0) {
      # Show default variable structure
      default_vars <- data.frame(
        Name = c("Parameter", "Unit", "Limit", "Type", "Sample_1", "Sample_2", "Sample_3"),
        Type = c("String", "String", "Numeric", "String", "Numeric", "Numeric", "Numeric"),
        Status = c("Read-only", "Read-only", "Read-only", "Read-only", "Editable", "Editable", "Editable"),
        Description = c("Tên thông số môi trường", "Đơn vị đo", "Ngưỡng giới hạn QCVN", "Loại ngưỡng (min/max/range)", 
                        "Giá trị mẫu 1", "Giá trị mẫu 2", "Giá trị mẫu 3")
      )
      
      rows <- lapply(1:nrow(default_vars), function(i) {
        type_class <- if(default_vars$Type[i] == "Numeric") "numeric" else "string"
        if(default_vars$Status[i] == "Read-only") type_class <- "readonly"
        
        tags$tr(
          tags$td(i),
          tags$td(tags$strong(default_vars$Name[i])),
          tags$td(
            span(class = paste("type-badge", type_class),
                 tags$i(class = if(default_vars$Type[i] == "Numeric") "fas fa-hashtag" else "fas fa-font"),
                 default_vars$Type[i])
          ),
          tags$td(default_vars$Status[i]),
          tags$td(class = "text-muted", default_vars$Description[i])
        )
      })
      
      return(tags$table(
        class = "variable-view-table",
        tags$thead(
          tags$tr(
            tags$th("#"),
            tags$th("Tên biến"),
            tags$th("Kiểu dữ liệu"),
            tags$th("Trạng thái"),
            tags$th("Mô tả")
          )
        ),
        tags$tbody(rows)
      ))
    }
    
    # Build variable definitions from current data structure
    col_names <- names(rv$data)
    
    rows <- lapply(seq_along(col_names), function(i) {
      col_name <- col_names[i]
      
      # Determine type and properties
      if (col_name %in% c("Parameter", "Unit", "Type")) {
        type <- "String"
        editable <- "Read-only"
        type_class <- "readonly"
      } else if (col_name == "Limit") {
        type <- "Numeric"
        editable <- "Read-only"
        type_class <- "readonly"
      } else {
        type <- "Numeric"
        editable <- "Editable"
        type_class <- "numeric"
      }
      
      # Get sample values
      sample_val <- if (nrow(rv$data) > 0 && !is.null(rv$data[[col_name]])) {
        val <- rv$data[[col_name]][1]
        if (is.na(val)) "NA" else as.character(val)
      } else {
        "-"
      }
      
      tags$tr(
        tags$td(i),
        tags$td(tags$strong(col_name)),
        tags$td(
          span(class = paste("type-badge", type_class),
               tags$i(class = if(type == "Numeric") "fas fa-hashtag" else "fas fa-font"),
               type)
        ),
        tags$td(editable),
        tags$td(class = "text-muted", sample_val)
      )
    })
    
    tags$table(
      class = "variable-view-table",
      tags$thead(
        tags$tr(
          tags$th("#"),
          tags$th("Variable Name"),
          tags$th("Data Type"),
          tags$th("Status"),
          tags$th("Sample Value")
        )
      ),
      tags$tbody(rows)
    )
  })
  
  output$kpi_rate <- renderUI({
    val <- if (!is.null(rv$stats)) paste0(rv$stats$compliance_rate, "%") else "0%"
    div(class = "kpi-card kpi-purple",
        div(class = "kpi-value", val),
        div(class = "kpi-label", "Compliance Rate"))
  })
  
  # ---- Critical Alerts Section ----
  output$critical_alerts_section <- renderUI({
    safe_render({
      if (is.null(rv$stats)) return(NULL)
      
      alerts <- list()
      
      # Critical alerts
      if (length(rv$stats$critical_params) > 0) {
        critical_data <- rv$assessed_data %>%
          filter(Parameter %in% rv$stats$critical_params) %>%
          select(Parameter, Percent_of_Limit)
        
        alerts[[1]] <- div(
          class = "critical-alerts",
          div(
            class = "critical-alerts-header",
            tags$i(class = "fas fa-exclamation-triangle"),
            paste("Critical Alerts (", length(rv$stats$critical_params), " parameters exceeding limits)")
          ),
          lapply(1:nrow(critical_data), function(i) {
            div(
              class = "alert-item",
              span(class = "alert-param", critical_data$Parameter[i]),
              span(class = "alert-value", paste0(round(critical_data$Percent_of_Limit[i], 1), "% of limit"))
            )
          })
        )
      }
      
      # Warning alerts
      if (length(rv$stats$warning_params) > 0) {
        warning_data <- rv$assessed_data %>%
          filter(Parameter %in% rv$stats$warning_params) %>%
          select(Parameter, Percent_of_Limit)
        
        alerts[[2]] <- div(
          class = "warning-alerts",
          div(
            class = "warning-alerts-header",
            tags$i(class = "fas fa-exclamation-circle"),
            paste("Warnings (", length(rv$stats$warning_params), " parameters approaching limits)")
          ),
          lapply(1:nrow(warning_data), function(i) {
            div(
              class = "warning-item",
              span(class = "alert-param", warning_data$Parameter[i]),
              span(class = "alert-value", style = "color: #d97706;", 
                   paste0(round(warning_data$Percent_of_Limit[i], 1), "% of limit"))
            )
          })
        )
      }
      
      if (length(alerts) == 0) {
        return(
          div(
            class = "p-4 text-center",
            style = "background: linear-gradient(135deg, #ecfdf5, #d1fae5); border-radius: 12px;",
            tags$i(class = "fas fa-check-circle fa-2x text-success mb-2"),
            p(class = "text-success mb-0 fw-bold", "All parameters within acceptable limits")
          )
        )
      }
      
      tagList(alerts)
    })
  })
  
  # ---- Main Chart ----
  output$main_chart <- renderPlot({
    safe_render({
      req(rv$assessed_data)
      
      dark_mode <- input$dark_mode
      accent <- input$accent_color
      if (is.null(accent)) accent <- "#1565C0"
      
      chart_type <- input$chart_type
      if (is.null(chart_type) || chart_type == "") chart_type <- "bar"
      
      chart <- switch(
        chart_type,
        "bar" = create_comparison_bar_chart(rv$assessed_data, accent_color = accent, dark_mode = dark_mode),
        "radar" = create_radar_chart(rv$assessed_data, accent_color = accent, dark_mode = dark_mode),
        "gauge" = create_gauge_grid(rv$assessed_data, n_cols = 4, dark_mode = dark_mode),
        "heatmap" = create_heatmap_chart(rv$assessed_data, accent_color = accent, dark_mode = dark_mode),
        "pie" = create_summary_pie_chart(rv$stats, dark_mode = dark_mode)
      )
      
      if (is.null(chart)) {
        return(
          ggplot() +
            annotate("text", x = 0.5, y = 0.5, 
                     label = "Enter data to visualize results",
                     size = 6, color = "gray50") +
            theme_void()
        )
      }
      
      print(chart)
    })
  })
  
  # ---- Compliance Table ----
  output$compliance_table <- render_gt({
    # Don't use safe_render here - render_gt expects a gt object, not a shiny.tag
    tryCatch({
      req(rv$assessed_data)
      
      # Verify assessed_data has required columns
      required_cols <- c("Parameter", "Unit", "Mean_Value", "Min_Value", 
                         "Max_Value", "Percent_of_Limit", "Status")
      if (!all(required_cols %in% names(rv$assessed_data))) {
        return(NULL)
      }
      
      accent <- input$accent_color
      if (is.null(accent)) accent <- "#1565C0"
      
      create_compliance_gt_table(
        rv$assessed_data,
        title = paste("Assessment:", QCVN_Standards[[rv$current_standard]]$name),
        accent_color = accent
      )
    }, error = function(e) {
      message("Compliance table error: ", e$message)
      return(NULL)
    })
  })
  
  # ---- Downloads ----
  output$download_template <- downloadHandler(
    filename = function() {
      paste0("template_", input$qcvn_standard, "_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      tryCatch({
        template <- create_data_template(input$qcvn_standard, input$qcvn_column, input$n_samples)
        write_xlsx(list("Template" = template), file)
      }, error = function(e) {
        showNotification(paste("Export error:", e$message), type = "error")
      })
    }
  )
  
  output$download_excel <- downloadHandler(
    filename = function() {
      paste0("report_", input$qcvn_standard, "_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      tryCatch({
        req(rv$assessed_data, rv$stats)
        sheets <- prepare_excel_report(
          rv$assessed_data,
          rv$stats,
          metadata = list(
            standard_name = QCVN_Standards[[rv$current_standard]]$name,
            column = rv$current_column
          )
        )
        write_xlsx(sheets, file)
        showNotification("Excel exported!", type = "message")
      }, error = function(e) {
        showNotification(paste("Export error:", e$message), type = "error")
      })
    }
  )
  
  output$download_pdf <- downloadHandler(
    filename = function() {
      paste0("report_", input$qcvn_standard, "_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      tryCatch({
        req(rv$assessed_data)
        accent <- input$accent_color
        if (is.null(accent)) accent <- "#1565C0"
        chart <- create_comparison_bar_chart(rv$assessed_data, accent_color = accent)
        ggsave(file, plot = chart, width = 12, height = 8, device = "pdf")
        showNotification("PDF exported!", type = "message")
      }, error = function(e) {
        showNotification(paste("Export error:", e$message), type = "error")
      })
    }
  )
  
  # ---- Download Assessment Excel ----
  output$download_assessment_excel <- downloadHandler(
    filename = function() {
      paste0("assessment_", input$qcvn_standard, "_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      tryCatch({
        req(rv$assessed_data)
        
        # Prepare assessment data for export
        export_data <- rv$assessed_data
        
        # Select relevant columns
        export_cols <- c("Parameter", "Unit", "Limit", "Type", 
                        "Mean_Value", "Max_Value", "Min_Value", 
                        "Status", "Percent_of_Limit")
        export_cols <- export_cols[export_cols %in% names(export_data)]
        
        if (length(export_cols) > 0) {
          export_data <- export_data[, export_cols, drop = FALSE]
        }
        
        # Create workbook with sheets
        sheets <- list(
          "Assessment" = export_data,
          "Summary" = data.frame(
            Metric = c("Total Parameters", "Compliant", "Warning", "Critical", "Compliance Rate"),
            Value = c(
              nrow(export_data),
              sum(export_data$Status == "Compliant", na.rm = TRUE),
              sum(export_data$Status == "Warning", na.rm = TRUE),
              sum(export_data$Status == "Critical", na.rm = TRUE),
              paste0(round(sum(export_data$Status == "Compliant", na.rm = TRUE) / nrow(export_data) * 100, 1), "%")
            )
          )
        )
        
        write_xlsx(sheets, file)
        showNotification("Assessment exported to Excel!", type = "message")
      }, error = function(e) {
        showNotification(paste("Export error:", e$message), type = "error")
      })
    }
  )
  
  # ---- Download Assessment PDF ----
  output$download_assessment_pdf <- downloadHandler(
    filename = function() {
      paste0("assessment_", input$qcvn_standard, "_", Sys.Date(), ".html")
    },
    content = function(file) {
      tryCatch({
        req(rv$assessed_data)
        
        # Create GT table and save as HTML (PDF requires additional packages)
        tbl <- create_compliance_gt_table(rv$assessed_data, show_samples = FALSE)
        gtsave(tbl, file)
        showNotification("Assessment exported!", type = "message")
      }, error = function(e) {
        showNotification(paste("Export error:", e$message), type = "error")
      })
    }
  )
  
  # ---- SETTINGS MODAL ----
  observeEvent(input$open_settings_modal, {
    config <- user_config()
    
    # Get current theme mode for modal styling
    theme_mode <- get_config_value(config, c("theme", "mode"), "light")
    is_dark <- theme_mode == "dark"
    
    # Modal colors based on theme
    modal_bg <- if(is_dark) "#1e293b" else "#ffffff"
    modal_text <- if(is_dark) "#e2e8f0" else "#1e293b"
    modal_border <- if(is_dark) "#334155" else "#e2e8f0"
    modal_input_bg <- if(is_dark) "#334155" else "#ffffff"
    section_bg <- if(is_dark) "#0f172a" else "#f8fafc"
    
    showModal(modalDialog(
      title = tagList(
        tags$i(class = "fas fa-cog me-2"),
        "User Settings"
      ),
      size = "l",
      easyClose = TRUE,
      footer = tagList(
        actionButton("save_settings", "Save Settings", class = "btn btn-primary"),
        actionButton("reset_settings", "Reset to Defaults", class = "btn btn-warning"),
        modalButton("Close")
      ),
      
      # Apply theme styling to modal
      tags$style(HTML(sprintf("
        .modal-content {
          background-color: %s !important;
          color: %s !important;
          border-color: %s !important;
        }
        .modal-header {
          background-color: %s !important;
          border-bottom-color: %s !important;
        }
        .modal-footer {
          background-color: %s !important;
          border-top-color: %s !important;
        }
        .modal-body h5 {
          color: %s !important;
        }
        .modal-body label, .modal-body .control-label {
          color: %s !important;
        }
        .modal-body .form-control, .modal-body .selectize-input {
          background-color: %s !important;
          color: %s !important;
          border-color: %s !important;
        }
        .modal-body .alert-info {
          background-color: %s !important;
          color: %s !important;
          border-color: %s !important;
        }
        .modal-body hr {
          border-color: %s !important;
        }
      ", modal_bg, modal_text, modal_border,
         section_bg, modal_border,
         section_bg, modal_border,
         modal_text, modal_text,
         modal_input_bg, modal_text, modal_border,
         if(is_dark) "#1e3a5f" else "#cfe2ff", modal_text, modal_border,
         modal_border
      ))),
      
      # Settings Content
      div(
        style = "max-height: 60vh; overflow-y: auto;",
        
        # AI Assistant Toggle (prominent)
        div(
          class = "ai-toggle-section",
          style = sprintf("background: %s; padding: 15px; border-radius: 10px; margin-bottom: 20px; border: 1px solid %s;", 
                         if(is_dark) "linear-gradient(135deg, #1e3a5f 0%%, #0f172a 100%%)" else "linear-gradient(135deg, #e0f2fe 0%%, #f0f9ff 100%%)",
                         modal_border),
          fluidRow(
            column(8,
              h5(tagList(tags$i(class = "fas fa-robot me-2"), "AI Assistant"), style = "margin: 0;"),
              tags$small("Enable AI-powered environmental analysis", style = sprintf("color: %s;", if(is_dark) "#94a3b8" else "#64748b"))
            ),
            column(4, style = "text-align: right; padding-top: 5px;",
              switchInput(
                inputId = "cfg_ai_enabled",
                label = NULL,
                value = get_config_value(config, c("ai", "enabled"), FALSE),
                onStatus = "success",
                offStatus = "danger",
                size = "normal"
              )
            )
          )
        ),
        
        # Theme & Colors
        h5(tags$i(class = "fas fa-palette me-2"), "Theme & Colors"),
        fluidRow(
          column(6,
            selectInput("cfg_theme_mode", "Theme Mode",
                       choices = c("Light" = "light", "Dark" = "dark"),
                       selected = get_config_value(config, c("theme", "mode"), "light"))
          ),
          column(6,
            colourpicker::colourInput("cfg_accent_color", "Accent Color",
                                     value = get_config_value(config, c("theme", "accent_color"), "#1565C0"))
          )
        ),
        fluidRow(
          column(4,
            colourpicker::colourInput("cfg_success_color", "Success Color",
                                     value = get_config_value(config, c("theme", "success_color"), "#10b981"))
          ),
          column(4,
            colourpicker::colourInput("cfg_warning_color", "Warning Color",
                                     value = get_config_value(config, c("theme", "warning_color"), "#f59e0b"))
          ),
          column(4,
            colourpicker::colourInput("cfg_danger_color", "Danger Color",
                                     value = get_config_value(config, c("theme", "danger_color"), "#ef4444"))
          )
        ),
        div(
          style = "margin-top: 10px;",
          actionButton("preview_theme", "Preview Theme", class = "btn btn-sm btn-outline-primary"),
          actionButton("reset_theme", "Reset to Default", class = "btn btn-sm btn-outline-secondary")
        ),
        
        tags$hr(),
        
        # Display Settings
        h5(tags$i(class = "fas fa-desktop me-2"), "Display Settings"),
        fluidRow(
          column(6,
            numericInput("cfg_decimal_places", "Decimal Places", 
                        value = get_config_value(config, c("display", "decimal_places"), 2),
                        min = 0, max = 6)
          ),
          column(6,
            numericInput("cfg_table_page_length", "Table Rows per Page",
                        value = get_config_value(config, c("display", "table_page_length"), 10),
                        min = 5, max = 100)
          )
        ),
        checkboxInput("cfg_show_warnings", "Show Warning Messages",
                     value = get_config_value(config, c("display", "show_warnings"), TRUE)),
        
        tags$hr(),
        
        # QCVN Settings
        h5(tags$i(class = "fas fa-scroll me-2"), "QCVN Settings"),
        textInput("cfg_last_qcvn", "Last Selected QCVN",
                 value = get_config_value(config, c("qcvn", "last_selected"), "")),
        checkboxInput("cfg_auto_load_custom", "Auto-load Custom QCVN",
                     value = get_config_value(config, c("qcvn", "auto_load_custom"), TRUE)),
        checkboxInput("cfg_show_all_params", "Show All Parameters",
                     value = get_config_value(config, c("qcvn", "show_all_parameters"), FALSE)),
        
        tags$hr(),
        
        # Export Settings
        h5(tags$i(class = "fas fa-file-export me-2"), "Export Settings"),
        selectInput("cfg_export_format", "Default Export Format",
                   choices = c("Excel" = "xlsx", "CSV" = "csv", "JSON" = "json"),
                   selected = get_config_value(config, c("export", "default_format"), "xlsx")),
        checkboxInput("cfg_include_charts", "Include Charts in Export",
                     value = get_config_value(config, c("export", "include_charts"), TRUE)),
        checkboxInput("cfg_auto_open", "Auto-open After Export",
                     value = get_config_value(config, c("export", "auto_open_after_export"), TRUE)),
        
        tags$hr(),
        
        # AI Settings (if available)
        if (is_ai_available()) {
          tagList(
            h5(tags$i(class = "fas fa-robot me-2"), "AI Settings"),
            textInput("cfg_n8n_endpoint", "n8n Endpoint URL",
                     value = get_config_value(config, c("ai", "n8n_endpoint"), DEFAULT_N8N_ENDPOINT),
                     placeholder = "https://your-n8n-instance.com/webhook/..."),
            checkboxInput("cfg_ai_auto_analyze", "Auto-analyze After Assessment",
                         value = get_config_value(config, c("ai", "auto_analyze"), FALSE)),
            checkboxInput("cfg_ai_show_suggestions", "Show AI Suggestions",
                         value = get_config_value(config, c("ai", "show_suggestions"), TRUE)),
            tags$hr()
          )
        },
        
        # Config File Info
        div(
          class = "alert alert-info",
          style = "font-size: 12px;",
          tags$i(class = "fas fa-info-circle me-2"),
          strong("Config File: "), 
          tags$code(CONFIG_FILE),
          tags$br(),
          "Settings are automatically saved when you change QCVN selection or toggle AI."
        )
      )
    ))
  })
  
  # ---- AI Toggle in Settings Modal Handler ----
  observeEvent(input$cfg_ai_enabled, {
    if (input$cfg_ai_enabled) {
      # Check if AI service is configured
      if (!is_ai_available()) {
        showNotification(
          "⚠️ AI service chưa được cấu hình. Vui lòng liên hệ developer.",
          type = "warning",
          duration = 5
        )
        updateSwitchInput(session, "cfg_ai_enabled", value = FALSE)
        return()
      }
      
      # Check internet connection by trying to connect to n8n
      showNotification("🔌 Đang kết nối đến AI service...", type = "message", duration = 2)
      
      endpoint <- DEFAULT_N8N_ENDPOINT
      result <- tryCatch({
        test_n8n_connection(endpoint)
      }, error = function(e) {
        FALSE
      })
      
      if (result) {
        rv$ai_enabled <- TRUE
        rv$ai_ready <- TRUE
        
        # Save AI enabled state to config
        config <- user_config()
        config <- set_config_value(config, c("ai", "enabled"), TRUE)
        user_config(config)
        save_user_config(config)
        
        showNotification("✅ AI Assistant đã sẵn sàng!", type = "message", duration = 3)
        
        # Show AI section
        shinyjs::runjs("
          if (document.getElementById('ai_status_indicator')) {
            document.getElementById('ai_status_indicator').style.display = 'block';
            document.getElementById('ai_status_indicator').style.background = '#10b98120';
            document.getElementById('ai_status_indicator').style.borderLeft = '3px solid #10b981';
          }
          if (document.getElementById('ai-analysis-section')) {
            document.getElementById('ai-analysis-section').style.display = 'block';
          }
        ")
      } else {
        rv$ai_enabled <- FALSE
        rv$ai_ready <- FALSE
        
        showNotification(
          "❌ Không thể kết nối đến AI service. Vui lòng kiểm tra kết nối mạng.",
          type = "error",
          duration = 5
        )
        updateSwitchInput(session, "cfg_ai_enabled", value = FALSE)
        
        # Hide AI section
        shinyjs::runjs("
          if (document.getElementById('ai_status_indicator')) {
            document.getElementById('ai_status_indicator').style.display = 'block';
            document.getElementById('ai_status_indicator').style.background = '#ef444420';
            document.getElementById('ai_status_indicator').style.borderLeft = '3px solid #ef4444';
          }
        ")
      }
    } else {
      # AI disabled
      rv$ai_enabled <- FALSE
      rv$ai_ready <- FALSE
      
      # Save AI disabled state to config
      config <- user_config()
      config <- set_config_value(config, c("ai", "enabled"), FALSE)
      user_config(config)
      save_user_config(config)
      
      # Hide AI section
      shinyjs::runjs("
        if (document.getElementById('ai_status_indicator')) {
          document.getElementById('ai_status_indicator').style.display = 'none';
        }
        if (document.getElementById('ai-analysis-section')) {
          document.getElementById('ai-analysis-section').style.display = 'none';
        }
      ")
      showNotification("AI Assistant đã tắt", type = "message", duration = 2)
    }
  }, ignoreInit = TRUE)
  
  # Save Settings
  observeEvent(input$save_settings, {
    config <- user_config()
    
    # Update theme settings
    config <- set_config_value(config, c("theme", "mode"), input$cfg_theme_mode)
    config <- set_config_value(config, c("theme", "accent_color"), input$cfg_accent_color)
    config <- set_config_value(config, c("theme", "success_color"), input$cfg_success_color)
    config <- set_config_value(config, c("theme", "warning_color"), input$cfg_warning_color)
    config <- set_config_value(config, c("theme", "danger_color"), input$cfg_danger_color)
    
    # Update all other settings
    config <- set_config_value(config, c("display", "decimal_places"), input$cfg_decimal_places)
    config <- set_config_value(config, c("display", "table_page_length"), input$cfg_table_page_length)
    config <- set_config_value(config, c("display", "show_warnings"), input$cfg_show_warnings)
    
    config <- set_config_value(config, c("qcvn", "last_selected"), input$cfg_last_qcvn)
    config <- set_config_value(config, c("qcvn", "auto_load_custom"), input$cfg_auto_load_custom)
    config <- set_config_value(config, c("qcvn", "show_all_parameters"), input$cfg_show_all_params)
    
    config <- set_config_value(config, c("export", "default_format"), input$cfg_export_format)
    config <- set_config_value(config, c("export", "include_charts"), input$cfg_include_charts)
    config <- set_config_value(config, c("export", "auto_open_after_export"), input$cfg_auto_open)
    
    if (is_ai_available()) {
      config <- set_config_value(config, c("ai", "n8n_endpoint"), input$cfg_n8n_endpoint)
      config <- set_config_value(config, c("ai", "auto_analyze"), input$cfg_ai_auto_analyze)
      config <- set_config_value(config, c("ai", "show_suggestions"), input$cfg_ai_show_suggestions)
    }
    
    # Save to file
    if (save_user_config(config)) {
      user_config(config)
      
      # Apply theme immediately
      shinyjs::runjs(sprintf("
        document.documentElement.style.setProperty('--accent-color', '%s');
        document.documentElement.style.setProperty('--success', '%s');
        document.documentElement.style.setProperty('--warning', '%s');
        document.documentElement.style.setProperty('--danger', '%s');
        if ('%s' === 'dark') {
          document.body.classList.add('dark-mode');
        } else {
          document.body.classList.remove('dark-mode');
        }
      ", input$cfg_accent_color, input$cfg_success_color, 
         input$cfg_warning_color, input$cfg_danger_color, input$cfg_theme_mode))
      
      showNotification("✓ Settings saved successfully!", type = "message", duration = 3)
      removeModal()
    } else {
      showNotification("✗ Error saving settings", type = "error", duration = 3)
    }
  })
  
  # Preview Theme (without saving)
  observeEvent(input$preview_theme, {
    shinyjs::runjs(sprintf("
      document.documentElement.style.setProperty('--accent-color', '%s');
      document.documentElement.style.setProperty('--success', '%s');
      document.documentElement.style.setProperty('--warning', '%s');
      document.documentElement.style.setProperty('--danger', '%s');
      if ('%s' === 'dark') {
        document.body.classList.add('dark-mode');
      } else {
        document.body.classList.remove('dark-mode');
      }
    ", input$cfg_accent_color, input$cfg_success_color, 
       input$cfg_warning_color, input$cfg_danger_color, input$cfg_theme_mode))
    
    showNotification("👁️ Preview applied (not saved yet)", type = "message", duration = 2)
  })
  
  # Reset Theme to Defaults
  observeEvent(input$reset_theme, {
    updateSelectInput(session, "cfg_theme_mode", selected = "light")
    colourpicker::updateColourInput(session, "cfg_accent_color", value = "#1565C0")
    colourpicker::updateColourInput(session, "cfg_success_color", value = "#10b981")
    colourpicker::updateColourInput(session, "cfg_warning_color", value = "#f59e0b")
    colourpicker::updateColourInput(session, "cfg_danger_color", value = "#ef4444")
    
    showNotification("Theme reset to defaults", type = "message", duration = 2)
  })
  
  # Reset Settings
  observeEvent(input$reset_settings, {
    showModal(modalDialog(
      title = "Confirm Reset",
      "Are you sure you want to reset all settings to defaults?",
      footer = tagList(
        actionButton("confirm_reset", "Yes, Reset", class = "btn btn-danger"),
        modalButton("Cancel")
      )
    ))
  })
  
  observeEvent(input$confirm_reset, {
    config <- reset_user_config()
    if (save_user_config(config)) {
      user_config(config)
      showNotification("✓ Settings reset to defaults!", type = "message", duration = 3)
      removeModal()
      
      # Reopen settings modal with new values
      Sys.sleep(0.5)
      shinyjs::click("open_settings_modal")
    } else {
      showNotification("✗ Error resetting settings", type = "error")
    }
  })
}

# ---- RUN APP ----
shinyApp(ui = ui, server = server)
