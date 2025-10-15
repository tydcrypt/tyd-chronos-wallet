#!/usr/bin/env python3
import http.server
import socketserver
import os
import webbrowser

# Set the port and directory
PORT = 8000
WEB_DIR = 'deploy/web'

# Change to the web directory
os.chdir(WEB_DIR)

# Create the server
Handler = http.server.SimpleHTTPRequestHandler
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    url = f"http://localhost:{PORT}"
    print(f"🚀 Serving TydChronos Wallet at: {url}")
    print("📱 Open this URL in your browser to test the wallet")
    print("⏹️  Press Ctrl+C to stop the server")
    
    # Try to open browser automatically
    try:
        webbrowser.open(url)
    except:
        print(f"⚠️  Could not open browser automatically. Please visit: {url}")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Server stopped")
