import yaml
import re

# Read the current file
with open('pubspec.yaml', 'r') as f:
    content = f.read()

# Pattern to move web section from under flutter to root level
pattern = r'flutter:(.*?)\n  web:(.*?)\n(?!\s)'
replacement = r'flutter:\1\n\nweb:\2\n'

# Apply the fix
fixed_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

# Also fix the duplicate web in flutter_launcher_icons by moving it to proper section
fixed_content = fixed_content.replace('  web:\n    generate: true\n    image_path: "assets/icon/icon.png"\n    background_color: "#000000"\n    theme_color: "#D4AF37"', '')

# Write the fixed content
with open('pubspec.yaml', 'w') as f:
    f.write(fixed_content)

print("Fixed pubspec.yaml structure")
