# Payou Mobile Payment Application

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Payou is a secure, high-performance mobile application for iOS and Android that enables instant, "gasless" crypto payments on an Ethereum Layer 2 network. It is designed to feel as fast and intuitive as leading traditional payment apps while providing the core benefits of blockchain technology.

## Key Innovations

*   **Gasless Experience:** Users transact in USDC without needing ETH for gas fees. Our community-funded Vault handles network fees in the background.
*   **Non-Custodial & Secure:** Users have full control over their funds. Private keys are stored securely in the device's hardware enclave.
*   **Dynamic & Transparent Fees:** A simple, predictable fee structure powers the platform sustainably.
*   **Community-Powered Vault:** Users can deposit ETH into our Vault to provide liquidity and earn rewards in ETH.

## The Project

This repository contains the source code for the Payou mobile application and its backend server.

For a complete and detailed explanation of the project's vision, architecture, and economic model, please see our full **[Whitepaper](whitepaper.md)**.

## Repository Structure

This repository is organized into two main directories:

*   `/app`: Contains the source code for the Flutter mobile application.
*   `/server`: Contains the source code for the backend server.

## Backend Server

The Payou backend server is a FastAPI application that provides essential services for the mobile application, including user management, regulatory compliance, and integration with external DeFi protocols.

### Key Features:

*   **User Authentication & Management:** Secure user registration, login (JWT-based), and profile updates.
*   **Internal Transaction Ledger:** Records all transactions for regulatory compliance.
*   **KYC Integration (Simulated):** A generic framework for Know Your Customer verification.
*   **Hyperliquid Integration:** Fetches real-time ETH prices, funding rates, and manages hedging positions on the Hyperliquid testnet.
*   **Structured Logging & Monitoring:** Implements structured logging and performance monitoring for better observability.
*   **Rate Limiting:** Protects public endpoints from abuse.

### Local Development Setup

To run the server locally:

1.  **Navigate to the server directory:**
    ```bash
    cd server
    ```
2.  **Install Python dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
3.  **Install and start Redis:**
    The server uses Redis for rate limiting. You need to have a Redis server running locally.
    *   **On macOS (using Homebrew):**
        ```bash
        brew install redis
        brew services start redis
        ```
    *   **On Debian/Ubuntu:**
        ```bash
        sudo apt update
        sudo apt install redis-server
        sudo systemctl enable redis-server
        sudo systemctl start redis-server
        ```
4.  **Set up Environment Variables:**
    The server requires sensitive information (e.g., `SECRET_KEY`, Hyperliquid API keys) to be set as environment variables. Create a `.env` file in the **project root** (i.e., `/the_project_v3/.env`) with the following structure:
    ```
    L2_RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
    COMPANY_PRIVATE_KEY=your_company_private_key
    COMPANY_WALLET_ADDRESS=your_company_wallet_address
    USDC_CONTRACT_ADDRESS=your_usdc_contract_address
    SECRET_KEY=a_very_long_random_secret_key_for_jwt_signing
    HYPERLIQUID_API_PRIVATE_KEY=your_hyperliquid_api_private_key
    HYPERLIQUID_API_WALLET_ADDRESS=your_hyperliquid_api_wallet_address
    ```
    *Replace placeholder values with your actual credentials.*

5.  **Run the server:**
    From the `server` directory, run:
    ```bash
    uvicorn main:app --reload
    ```
    The server will be accessible at `http://127.0.0.1:8000`.

### VM Deployment

To deploy the server to a Google Cloud VM (or any Linux-based VM):

1.  **Ensure your VM is set up:** Make sure you have a fresh Debian/Ubuntu VM instance in Google Cloud.
2.  **Transfer the deployment script:** Copy the `deploy_vm.sh` script (located in the project root) to your VM.
3.  **Update Repository URL:** Edit the `deploy_vm.sh` script on your VM and replace `YOUR_GITHUB_REPO_URL_HERE` with the actual HTTPS URL of your GitHub repository.
4.  **Transfer `.env` file:** Securely transfer your `.env` file (from your local project root) to the project root directory on your VM. This is critical for the server to function correctly.
5.  **Make the script executable and run it:**
    ```bash
    chmod +x deploy_vm.sh
    ./deploy_vm.sh
    ```
    The script will install necessary dependencies, clone the repository, set up Redis, and start the FastAPI server in the background.
6.  **Firewall Rules:** Ensure that port `8000` (or the port you configure) is open in your VM's firewall rules to allow incoming traffic.

---
