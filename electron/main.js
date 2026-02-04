// ============================================================================ //
//               ELECTRON MAIN PROCESS - ENVIROANALYZER PRO                     //
// ============================================================================ //

const { app, BrowserWindow, Menu, shell, dialog } = require('electron');
const { spawn, exec } = require('child_process');
const path = require('path');
const http = require('http');
const fs = require('fs');

// ---- CONFIGURATION ----
const CONFIG = {
  appName: 'EnviroAnalyzer Pro',
  shinyPort: 0,  // 0 = auto-find available port
  shinyHost: '127.0.0.1',
  windowWidth: 1400,
  windowHeight: 900,
  minWidth: 1000,
  minHeight: 700
};

let mainWindow = null;
let rProcess = null;
let isQuitting = false;
let actualPort = 3838;  // Store actual port used

// ---- FIND AVAILABLE PORT ----
function findAvailablePort(startPort = 3838) {
  return new Promise((resolve) => {
    const net = require('net');
    const server = net.createServer();
    
    server.listen(startPort, CONFIG.shinyHost, () => {
      const port = server.address().port;
      server.close(() => {
        resolve(port);
      });
    });
    
    server.on('error', () => {
      // Port in use, try next one
      resolve(findAvailablePort(startPort + 1));
    });
  });
}

// ---- FIND R EXECUTABLE ----
function findRPath() {
  const possiblePaths = [
    // Common R installation paths on Windows
    'C:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.4.2\\bin\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.4.1\\bin\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.4.0\\bin\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.3.3\\bin\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.3.2\\bin\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.3.1\\bin\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.3.0\\bin\\Rscript.exe',
    // x64 specific paths
    'C:\\Program Files\\R\\R-4.5.2\\bin\\x64\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.4.2\\bin\\x64\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.4.1\\bin\\x64\\Rscript.exe',
    'C:\\Program Files\\R\\R-4.4.0\\bin\\x64\\Rscript.exe',
    // Portable R in app directory
    path.join(__dirname, 'R-Portable', 'bin', 'Rscript.exe'),
    path.join(__dirname, '..', 'R-Portable', 'bin', 'Rscript.exe'),
  ];

  // Also check PATH
  for (const rPath of possiblePaths) {
    if (fs.existsSync(rPath)) {
      console.log(`Found R at: ${rPath}`);
      return rPath;
    }
  }

  // Try to find R from registry or PATH
  return 'Rscript'; // Fallback to PATH
}

// ---- GET APP DIRECTORY ----
function getAppDirectory() {
  // Check if running in development or production
  if (app.isPackaged) {
    // Production: app files are in resources/app
    return path.join(process.resourcesPath, 'app');
  } else {
    // Development: app files are in parent directory
    return path.dirname(__dirname);
  }
}

// ---- START SHINY SERVER ----
function startShinyServer() {
  return new Promise(async (resolve, reject) => {
    const rPath = findRPath();
    const appDir = getAppDirectory();
    
    // Find available port if needed
    if (CONFIG.shinyPort === 0) {
      actualPort = await findAvailablePort(3838);
      console.log(`Using dynamic port: ${actualPort}`);
    } else {
      actualPort = CONFIG.shinyPort;
    }
    
    console.log(`Starting Shiny server...`);
    console.log(`R Path: ${rPath}`);
    console.log(`App Directory: ${appDir}`);
    console.log(`Port: ${actualPort}`);

    // Use external R script file for better compatibility
    const launcherScript = path.join(__dirname, 'shiny_launcher.R');
    
    rProcess = spawn(rPath, ['--vanilla', launcherScript, appDir, actualPort.toString()], {
      cwd: appDir,
      env: { ...process.env },
      windowsHide: true,
      stdio: ['ignore', 'pipe', 'pipe']
    });

    rProcess.stdout.on('data', (data) => {
      console.log(`R stdout: ${data}`);
    });

    rProcess.stderr.on('data', (data) => {
      const msg = data.toString();
      console.log(`R stderr: ${msg}`);
      
      // Check if Shiny is ready
      if (msg.includes('Listening on') || msg.includes('127.0.0.1')) {
        resolve();
      }
    });

    rProcess.on('error', (err) => {
      console.error('Failed to start R process:', err);
      reject(err);
    });

    rProcess.on('close', (code) => {
      console.log(`R process exited with code ${code}`);
      if (!isQuitting) {
        // R crashed, show error
        dialog.showErrorBox(
          'Application Error',
          'The R process has stopped unexpectedly. Please restart the application.'
        );
        app.quit();
      }
    });

    // Wait for server to be ready (with timeout)
    let attempts = 0;
    const maxAttempts = 60; // 30 seconds timeout
    
    const checkServer = setInterval(() => {
      attempts++;
      
      http.get(`http://${CONFIG.shinyHost}:${actualPort}`, (res) => {
        clearInterval(checkServer);
        console.log('Shiny server is ready!');
        resolve();
      }).on('error', () => {
        if (attempts >= maxAttempts) {
          clearInterval(checkServer);
          reject(new Error('Timeout waiting for Shiny server'));
        }
      });
    }, 500);
  });
}

// ---- STOP SHINY SERVER ----
function stopShinyServer() {
  if (rProcess) {
    console.log('Stopping R process...');
    isQuitting = true;
    
    // On Windows, we need to kill the process tree
    if (process.platform === 'win32') {
      exec(`taskkill /pid ${rProcess.pid} /T /F`, (err) => {
        if (err) console.log('Error killing R process:', err);
      });
    } else {
      rProcess.kill('SIGTERM');
    }
    
    rProcess = null;
  }
}

// ---- CREATE MAIN WINDOW ----
function createWindow() {
  mainWindow = new BrowserWindow({
    width: CONFIG.windowWidth,
    height: CONFIG.windowHeight,
    minWidth: CONFIG.minWidth,
    minHeight: CONFIG.minHeight,
    title: CONFIG.appName,
    icon: path.join(__dirname, '..', 'assets', 'icon.ico'),
    backgroundColor: '#1a1a2e',
    show: false, // Don't show until ready
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: true,
      cache: false  // Disable cache to avoid cache errors
    }
  });

  // Create application menu
  const menuTemplate = [
    {
      label: 'File',
      submenu: [
        {
          label: 'Refresh',
          accelerator: 'F5',
          click: () => mainWindow.reload()
        },
        { type: 'separator' },
        {
          label: 'Exit',
          accelerator: 'Alt+F4',
          click: () => app.quit()
        }
      ]
    },
    {
      label: 'View',
      submenu: [
        {
          label: 'Toggle Full Screen',
          accelerator: 'F11',
          click: () => mainWindow.setFullScreen(!mainWindow.isFullScreen())
        },
        { type: 'separator' },
        {
          label: 'Zoom In',
          accelerator: 'CmdOrCtrl+Plus',
          click: () => {
            const zoom = mainWindow.webContents.getZoomFactor();
            mainWindow.webContents.setZoomFactor(zoom + 0.1);
          }
        },
        {
          label: 'Zoom Out',
          accelerator: 'CmdOrCtrl+-',
          click: () => {
            const zoom = mainWindow.webContents.getZoomFactor();
            mainWindow.webContents.setZoomFactor(Math.max(0.5, zoom - 0.1));
          }
        },
        {
          label: 'Reset Zoom',
          accelerator: 'CmdOrCtrl+0',
          click: () => mainWindow.webContents.setZoomFactor(1)
        },
        { type: 'separator' },
        {
          label: 'Developer Tools',
          accelerator: 'F12',
          click: () => mainWindow.webContents.toggleDevTools()
        }
      ]
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'About EnviroAnalyzer Pro',
          click: () => {
            dialog.showMessageBox(mainWindow, {
              type: 'info',
              title: 'About EnviroAnalyzer Pro',
              message: 'EnviroAnalyzer Pro v3.0.0',
              detail: 'Environmental Quality Assessment Application\nUsing Vietnamese QCVN Standards\n\n© 2024-2026 Environmental Engineering Team'
            });
          }
        }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(menuTemplate);
  Menu.setApplicationMenu(menu);

  // Handle external links
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  // Show window when ready
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
    mainWindow.focus();
  });

  // Handle window close
  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// ---- CREATE LOADING WINDOW ----
function createLoadingWindow() {
  const loadingWin = new BrowserWindow({
    width: 400,
    height: 300,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    resizable: false,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  const loadingHTML = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body {
          margin: 0;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
          border-radius: 15px;
          font-family: 'Segoe UI', Arial, sans-serif;
          color: white;
        }
        .container {
          text-align: center;
        }
        .logo {
          font-size: 48px;
          margin-bottom: 10px;
        }
        h1 {
          font-size: 24px;
          margin: 10px 0;
          font-weight: 600;
        }
        .subtitle {
          font-size: 12px;
          color: #94a3b8;
          margin-bottom: 30px;
        }
        .spinner {
          width: 50px;
          height: 50px;
          border: 4px solid rgba(255,255,255,0.1);
          border-top: 4px solid #3b82f6;
          border-radius: 50%;
          animation: spin 1s linear infinite;
          margin: 0 auto 20px;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        .status {
          font-size: 14px;
          color: #64748b;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="logo">🌿</div>
        <h1>EnviroAnalyzer Pro</h1>
        <div class="subtitle">Environmental Quality Assessment</div>
        <div class="spinner"></div>
        <div class="status">Starting application...</div>
      </div>
    </body>
    </html>
  `;

  loadingWin.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(loadingHTML)}`);
  
  return loadingWin;
}

// ---- APP LIFECYCLE ----
app.whenReady().then(async () => {
  console.log('Electron app starting...');
  
  // Show loading window
  const loadingWindow = createLoadingWindow();
  
  try {
    // Start Shiny server
    await startShinyServer();
    
    // Create main window
    createWindow();
    
    // Load Shiny app with actual port
    mainWindow.loadURL(`http://${CONFIG.shinyHost}:${actualPort}`);
    
    // Close loading window after main window is ready
    mainWindow.once('ready-to-show', () => {
      setTimeout(() => {
        if (loadingWindow && !loadingWindow.isDestroyed()) {
          loadingWindow.close();
        }
      }, 500);
    });
    
  } catch (error) {
    console.error('Failed to start application:', error);
    
    if (loadingWindow && !loadingWindow.isDestroyed()) {
      loadingWindow.close();
    }
    
    dialog.showErrorBox(
      'Startup Error',
      `Failed to start EnviroAnalyzer Pro.\n\nError: ${error.message}\n\nPlease make sure R is installed and try again.`
    );
    
    app.quit();
  }
});

app.on('window-all-closed', () => {
  stopShinyServer();
  app.quit();
});

app.on('before-quit', () => {
  stopShinyServer();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught exception:', error);
  stopShinyServer();
});
