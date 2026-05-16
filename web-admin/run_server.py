#!/usr/bin/env python3
"""
Kandonga POS - Web Admin Portal Server
Run this script to start the banking portal on http://localhost:8080
"""

import http.server
import socketserver
import webbrowser
import os

PORT = 8080

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        self.send_header('Expires', '0')
        super().end_headers()

def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"\n{'='*50}")
        print(f"  Kandonga POS - Portal Bancário")
        print(f"{'='*50}")
        print(f"\n  Web Portal: http://localhost:{PORT}")
        print(f"\n  Modo Demo: Enabled (sem Firebase)")
        print(f"  Firebase: Cole config na interface para conectar")
        print(f"\n  Pressione Ctrl+C para encerrar")
        print(f"{'='*50}\n")
        
        webbrowser.open(f"http://localhost:{PORT}")
        httpd.serve_forever()

if __name__ == "__main__":
    main()