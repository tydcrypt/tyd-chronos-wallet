#!/usr/bin/env python3
print("🏗️  TydChronos Wallet Builder")
import subprocess
commands = [
    "flutter clean",
    "flutter pub get", 
    "flutter build web --release"
]
for cmd in commands:
    print(f"Running: {cmd}")
    subprocess.run(cmd, shell=True)
print("✅ Build complete!")
