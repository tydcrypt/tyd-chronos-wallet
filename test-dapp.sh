#!/bin/bash
echo "🚀 STARTING DAPP TEST SERVER"
echo "============================"

# Check if we have serve available locally
if [ -f "node_modules/.bin/serve" ]; then
    echo "✅ Using local serve installation"
    ./node_modules/.bin/serve -s build
else
    echo "🔄 No local serve found, using alternative methods..."
    
    # Method 1: Use Python HTTP server (usually available)
    if command -v python3 &> /dev/null; then
        echo "🐍 Using Python HTTP server..."
        cd build && python3 -m http.server 3000
    elif command -v python &> /dev/null; then
        echo "🐍 Using Python HTTP server..."
        cd build && python -m SimpleHTTPServer 3000
    else
        # Method 2: Use Node.js built-in server
        echo "📦 Creating quick Node.js server..."
        cat > server.js << 'NODE_EOF'
const http = require('http');
const fs = require('fs');
const path = require('path');
const port = 3000;

const mimeTypes = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml'
};

const server = http.createServer((req, res) => {
    let filePath = req.url === '/' ? '/index.html' : req.url;
    filePath = path.join(__dirname, 'build', filePath);
    
    const ext = path.extname(filePath);
    const contentType = mimeTypes[ext] || 'application/octet-stream';
    
    fs.readFile(filePath, (err, content) => {
        if (err) {
            if (err.code === 'ENOENT') {
                fs.readFile(path.join(__dirname, 'build', 'index.html'), (err, content) => {
                    res.writeHead(200, { 'Content-Type': 'text/html' });
                    res.end(content, 'utf-8');
                });
            } else {
                res.writeHead(500);
                res.end('Server Error: ' + err.code);
            }
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content, 'utf-8');
        }
    });
});

server.listen(port, () => {
    console.log(`🚀 DApp running at: http://localhost:${port}`);
    console.log("🛑 Press Ctrl+C to stop the server");
});
NODE_EOF
        node server.js
    fi
fi
