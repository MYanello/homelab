for file in *.yaml; do
  echo "Checking $file"
  python3 -c "
import sys
try:
    with open('$file', 'r', encoding='utf-8') as f:
        f.read()
    print('✓ Valid UTF-8')
except UnicodeDecodeError as e:
    print('✗ Invalid UTF-8:', e)
  "
done