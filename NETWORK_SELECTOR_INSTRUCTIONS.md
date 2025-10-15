# Network Selector Implementation Guide

## Overview
The network selector in the top-right corner of the CRYPTO interface dynamically displays available blockchain networks and connects to Web3 sites accordingly.

## Key Features Implemented

### 1. Dynamic Network Selection
- **Header Network Selector**: Dropdown in app bar showing current network
- **Multi-Chain Support**: Ethereum, Polygon, Arbitrum, Optimism, Avalanche, zkSync Era
- **Testnet Access**: Goerli, Sepolia, Polygon Mumbai

### 2. Universal Wallet Address
- **Single Address**: One Ethereum address works across all EVM-compatible networks
- **Automatic Generation**: Wallet created on first app launch with 12-word mnemonic
- **Secure Storage**: Private keys and mnemonics stored in encrypted storage

### 3. Network-Aware Wallet Interface
- **Contextual Display**: Shows network-specific information and balances
- **Dynamic RPC Switching**: Automatically connects to appropriate RPC endpoints
- **Testnet Indicators**: Visual cues for testnet vs mainnet environments

## Network Configuration

### RPC Endpoints
Each network uses configured RPC URLs:
- Mainnets: Infura endpoints (requires PROJECT_ID)
- Testnets: Public/test RPC endpoints
- Custom: Can add custom networks via configuration

### Adding New Networks
1. Update `_networkRpcs` map in `wallet_manager.dart`
2. Add to `_networks` list in dashboard
3. Update available networks in wallet screen

## User Flow

1. **First Launch**: Automatic wallet generation with 12-word phrase
2. **Network Selection**: User chooses network from header dropdown
3. **Balance Fetching**: Automatically retrieves balance for selected network
4. **Wallet Operations**: All functions (send, receive, swap) use selected network

## Security Features

- **Encrypted Storage**: Mnemonic and private keys stored securely
- **Network Isolation**: Transactions only on selected network
- **Address Verification**: Same address across all networks for consistency

## Next Steps for Testing

1. **Configure Infura**: Replace `YOUR_PROJECT_ID` with actual Infura project ID
2. **Test Wallet Generation**: Verify mnemonic creation and address derivation
3. **Network Switching**: Test balance fetching across different networks
4. **Transaction Testing**: Implement and test send/receive functionality

## Integration with Web3 Sites

The network selector will automatically:
- Detect connected Web3 site's network
- Suggest switching to compatible network
- Maintain wallet state across network changes
- Provide seamless multi-chain experience
