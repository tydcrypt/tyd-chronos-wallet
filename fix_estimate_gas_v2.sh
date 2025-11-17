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

# Create a Python script for the replacement
cat > replace_estimate_gas.py << 'PYEOF'
import re
import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: python replace_estimate_gas.py <file_path>")
        return
    
    file_path = sys.argv[1]
    
    # Read the original file
    with open(file_path, 'r') as f:
        content = f.read()
    
    # The fixed estimateGas method
    fixed_method = '''  /// Estimate gas for a transaction
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
  }'''

    # Pattern to find the existing estimateGas method
    # This is more flexible to match different formatting
    pattern = r'''(?s)  /// Estimate gas for a transaction.*?Future<BigInt> estimateGas\(.*?\) async \s*\{.*?\n  \}'''

    # Check if we found the method
    matches = re.findall(pattern, content)
    if matches:
        print(f"Found existing estimateGas method, replacing it...")
        new_content = re.sub(pattern, fixed_method, content)
        
        # Write the updated content
        with open(file_path, 'w') as f:
            f.write(new_content)
        print("Successfully updated estimateGas method!")
        return True
    else:
        print("Warning: Could not find existing estimateGas method with pattern 1")
        
        # Try alternative pattern
        pattern2 = r'''(?s)Future<BigInt> estimateGas\(.*?\) async \s*\{.*?\n  \}'''
        matches2 = re.findall(pattern2, content)
        if matches2:
            print(f"Found estimateGas method with alternative pattern, replacing it...")
            new_content = re.sub(pattern2, fixed_method, content)
            
            # Write the updated content
            with open(file_path, 'w') as f:
                f.write(new_content)
            print("Successfully updated estimateGas method with alternative pattern!")
            return True
        else:
            print("Error: Could not find estimateGas method in the file.")
            print("Please check the file structure manually.")
            return False

if __name__ == "__main__":
    main()
PYEOF

echo "Applying the fix..."
python3 replace_estimate_gas.py "$DAPP_BRIDGE_FILE"

# Clean up
rm -f replace_estimate_gas.py

echo ""
echo "=== VERIFYING THE FIX ==="
echo "Checking if the new method is in place..."

if grep -q "sender: from" "$DAPP_BRIDGE_FILE"; then
    echo "✓ Fix applied successfully - 'sender' parameter is now used"
else
    echo "✗ Fix might not have been applied correctly"
    echo "Let me check the current content of the method..."
    
    # Show the current estimateGas method
    echo ""
    echo "=== CURRENT ESTIMATEGAS METHOD ==="
    grep -A 35 "Future<BigInt> estimateGas" "$DAPP_BRIDGE_FILE" | head -40
fi

if grep -q "amountOfGas: gas" "$DAPP_BRIDGE_FILE"; then
    echo "✓ Fix applied successfully - 'amountOfGas' parameter is now used"
else
    echo "✗ 'amountOfGas' parameter mapping missing"
fi

echo ""
echo "=== BACKUP INFORMATION ==="
echo "Original file backed up at: ${DAPP_BRIDGE_FILE}.backup"
echo "If anything went wrong, restore with: cp '${DAPP_BRIDGE_FILE}.backup' '$DAPP_BRIDGE_FILE'"
