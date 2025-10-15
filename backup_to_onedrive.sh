#!/bin/bash
echo "=== BACKING UP TO ONEDRIVE ==="

# Define source and destination paths
SOURCE_DIR="/mnt/c/Users/TYD/Documents/tyd_chronos_wallet_new"
ONEDRIVE_DIR="/mnt/c/Users/TYD/OneDrive/Documents/tyd_chronos_wallet_backup"

# Create backup directory if it doesn't exist
mkdir -p "$ONEDRIVE_DIR"

# Copy the entire project to OneDrive
echo "📦 Copying project files to OneDrive..."
cp -r "$SOURCE_DIR"/* "$ONEDRIVE_DIR"/

# Create a timestamped backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$ONEDRIVE_DIR/backups/backup_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
cp -r "$SOURCE_DIR"/* "$BACKUP_DIR"/

echo "✅ Backup completed to: $ONEDRIVE_DIR"
echo "✅ Timestamped backup: $BACKUP_DIR"
echo "📊 Backup size: $(du -sh "$BACKUP_DIR" | cut -f1)"

# Create a readme file for the backup
cat > "$ONEDRIVE_DIR/README.md" << 'README_EOF'
# TydChronos Wallet - Project Backup

## Project Information
- **Project Name**: TydChronos Wallet
- **Version**: 1.0.0
- **Platform**: Flutter (Android/iOS/Web)
- **Last Updated**: $(date)

## Features
- 🎯 Balance Visibility Toggle
- 🔐 Ethereum Wallet Creation
- 💰 Multi-Currency Support
- �� CRYPTO: Wallet + AI Trading
- 💳 E-WALLET: Wallet + Banking
- ⚙️ SETTINGS: Security & Configuration
- 🎨 Black & Gold Theme
- ⏱️ 10-second Splash Screen

## Project Structure
echo "=== COMPLETING GIT & ONEDRIVE BACKUP PROCESS ==="

# Create the backup script for OneDrive
cat > backup_to_onedrive.sh << 'BACKUP_EOF'
#!/bin/bash
echo "=== BACKING UP TO ONEDRIVE ==="

# Define source and destination paths
SOURCE_DIR="/mnt/c/Users/TYD/Documents/tyd_chronos_wallet_new"
ONEDRIVE_DIR="/mnt/c/Users/TYD/OneDrive/Documents/tyd_chronos_wallet_backup"

# Create backup directory if it doesn't exist
mkdir -p "$ONEDRIVE_DIR"

# Copy the entire project to OneDrive
echo "📦 Copying project files to OneDrive..."
cp -r "$SOURCE_DIR"/* "$ONEDRIVE_DIR"/ 2>/dev/null || echo "Note: Some files may not copy due to permissions"

# Create a timestamped backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$ONEDRIVE_DIR/backups/backup_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
cp -r "$SOURCE_DIR"/* "$BACKUP_DIR"/ 2>/dev/null || echo "Note: Some files may not copy due to permissions"

echo "✅ Backup completed to: $ONEDRIVE_DIR"
echo "✅ Timestamped backup: $BACKUP_DIR"

# Create a readme file for the backup
cat > "$ONEDRIVE_DIR/README.md" << 'README_EOF'
# TydChronos Wallet - Project Backup

## Project Information
- **Project Name**: TydChronos Wallet
- **Version**: 1.0.0
- **Platform**: Flutter (Android/iOS/Web)
- **Last Updated**: $(date)

## Features
- 🎯 Balance Visibility Toggle
- 🔐 Ethereum Wallet Creation
- 💰 Multi-Currency Support
- 📱 CRYPTO: Wallet + AI Trading
- 💳 E-WALLET: Wallet + Banking
- ⚙️ SETTINGS: Security & Configuration
- 🎨 Black & Gold Theme
- ⏱️ 10-second Splash Screen

## Git Information
- **Repository**: Initialized and committed
- **Total Files**: 181 files committed
- **Commit Hash**: 13272c8

## Backup Location
This directory contains automatic backups of the TydChronos Wallet project.
README_EOF

echo "✅ Created README.md in backup directory"
