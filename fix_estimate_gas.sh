#!/bin/bash

echo "=== FIXING ESTIMATEGAS METHOD IN DAPP_BRIDGE_SERVICE ==="

# First, let's find the dapp_bridge_service.dart file
DAPP_BRIDGE_FILE=$(find . -name "dapp_bridge_service.dart" -type f | head -1)

if [ -z "$DAPP_BRIDGE_FILE" ]; then
    echo "Error: dapp_bridge_service.dart not found!"
    exit 1
fi

echo "Found DAppBridgeService at: $DAPP_BRIDGE_FILE"

# Create a backup
cp "$DAPP_BRIDGE_FILE" "${DAPP_BRIDGE_FILE}.backup"
echo "Backup created: ${DAPP_BRIDGE_FILE}.backup"

# Create the fixed version
cat > temp_fix.dart << 'FIX'
  /// Estimate gas for a transaction
  Future<BigInt> estimateGas({
    required EthereumAddress from,
    required EthereumAddress to,
    required BigInt value,
    required Uint8List data,
    BigInt? gas,
    BigInt? gasPrice,
    BigInt? maxPriorityFeePerGas,
    BigInt? maxFeePerGas,
  }) async {
    try {
      final EtherAmount? etherValue = value > BigInt.zero 
          ? EtherAmount.fromBigInt(EtherUnit.wei, value)
          : null;
          
      final EtherAmount? gasPriceValue = gasPrice != null
          ? EtherAmount.fromBigInt(EtherUnit.wei, gasPrice)
          : null;
          
      final EtherAmount? maxPriorityFee = maxPriorityFeePerGas != null
          ? EtherAmount.fromBigInt(EtherUnit.wei, maxPriorityFeePerGas)
          : null;
          
      final EtherAmount? maxFee = maxFeePerGas != null
          ? EtherAmount.fromBigInt(EtherUnit.wei, maxFeePerGas)
          : null;

      return await _web3client.estimateGas(
        sender: from,
        to: to,
        value: etherValue,
        data: data,
        amountOfGas: gas,
        gasPrice: gasPriceValue,
        maxPriorityFeePerGas: maxPriorityFee,
        maxFeePerGas: maxFee,
      );
    } catch (e) {
      _logger.e('Error estimating gas: \$e');
      rethrow;
    }
  }
FIX

echo "Fix template created. Applying the fix..."

# Now let's find and replace the estimateGas method in the actual file
# We'll use a more precise approach to only replace the estimateGas method
python3 << 'PYTHON_EOF'
import re
import os

# Read the original file
with open('$DAPP_BRIDGE_FILE', 'r') as f:
    content = f.read()

# Read the fix
with open('temp_fix.dart', 'r') as f:
    fixed_method = f.read()

# Pattern to find the existing estimateGas method
# This pattern looks for the method from its signature to the next method or class
pattern = r'''(?s)  /// Estimate gas for a transaction.*?Future<BigInt> estimateGas\(.*?\) async \{[^}]+\}[^}]+}'''

# Check if we found the method
matches = re.findall(pattern, content)
if matches:
    print(f"Found existing estimateGas method, replacing it...")
    new_content = re.sub(pattern, fixed_method, content)
    
    # Write the updated content
    with open('$DAPP_BRIDGE_FILE', 'w') as f:
        f.write(new_content)
    print("Successfully updated estimateGas method!")
else:
    print("Warning: Could not find existing estimateGas method pattern")
    print("The method might have a different format. Please check manually.")
    
PYTHON_EOF

# Clean up
rm -f temp_fix.dart

echo "=== VERIFYING THE FIX ==="
echo "Checking if the new method is in place..."

if grep -q "sender: from" "$DAPP_BRIDGE_FILE"; then
    echo "✓ Fix applied successfully - 'sender' parameter is now used"
else
    echo "✗ Fix might not have been applied correctly"
    echo "Please check the file manually"
fi

if grep -q "amountOfGas: gas" "$DAPP_BRIDGE_FILE"; then
    echo "✓ Fix applied successfully - 'amountOfGas' parameter is now used"
else
    echo "✗ Fix might not have been applied correctly"
    echo "Please check the file manually"
fi

echo ""
echo "=== BACKUP INFORMATION ==="
echo "Original file backed up at: ${DAPP_BRIDGE_FILE}.backup"
echo "If anything went wrong, restore with: cp ${DAPP_BRIDGE_FILE}.backup $DAPP_BRIDGE_FILE"
