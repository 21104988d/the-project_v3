# Payou Server Development Roadmap

This document outlines the development milestones for the Payou backend server. The server is responsible for user management, transaction processing, and the core logic for the Payou Vault.

---

## Milestone 1: Core API & User Foundation (Current)

This milestone focuses on establishing the basic server infrastructure and implementing the essential user account features required for the app to function.

### Key Features:

*   **Initial Setup:**
    *   [x] Set up FastAPI project structure.
    *   [x] Implement a basic "Hello World" endpoint.
    *   [x] Create `Dockerfile` for containerization.
*   **User Authentication:**
    *   [ ] Design database schema for Users.
    *   [ ] Implement user registration endpoint (Email/Password, Username).
    *   [ ] Implement user login endpoint (issuing JWT tokens).
*   **User Profile Management:**
    *   [ ] Endpoint to link a wallet address to a user account.
    *   [ ] Endpoint to retrieve user profile information.

---

## Milestone 2: KYC & Transaction Ledger

This milestone focuses on regulatory compliance and building the internal ledger system required by the whitepaper.

### Key Features:

*   **KYC Integration:**
    *   [ ] Integrate with a third-party KYC provider.
    *   [ ] Endpoints to initiate and check the status of a user's KYC verification.
    *   [ ] Webhook to receive updates from the KYC provider.
*   **Internal Ledger:**
    *   [ ] Design database schema for the transaction ledger.
    *   [ ] Create a private API endpoint for the app to submit transaction details for recording.
    *   [ ] API endpoint to provide transaction history to the user.

---

## Milestone 3: Dynamic Short Position Perpetual System (Hedging)

This milestone focuses on implementing the backend logic for hedging the risk of holding ETH, likely through integration with a perpetual swap exchange or protocol.

### Key Features:

*   **Market Data Integration:**
    *   [ ] Connect to a perpetual swap exchange/protocol API to fetch real-time ETH price data.
    *   [ ] Monitor funding rates and other relevant market metrics.
*   **Position Management:**
    *   [ ] Implement logic to open and close short perpetual positions.
    *   [ ] Manage collateral and margin requirements.
    *   [ ] Track PnL of hedging positions.
*   **Risk Management:**
    *   [ ] Define and implement hedging strategies (e.g., dynamic hedging based on ETH holdings).
    *   [ ] Implement alerts for liquidation risks or significant price movements.

---

## Milestone 4: Deployment & Hardening

This milestone focuses on preparing the server for a production environment on Google Cloud.

### Key Features:

*   **CI/CD Pipeline:**
    *   [ ] Set up GitHub Actions to test and build the server on every push.
    *   [ ] Automate deployment to Google Cloud Run.
*   **Security & Monitoring:**
    *   [ ] Implement robust input validation and error handling.
    *   [ ] Set up structured logging and performance monitoring.
    *   [ ] Implement rate limiting on public endpoints.

---

## Milestone 5: Payou Vault Backend (On Hold)

This milestone covers the core business logic for the gasless system and the DeFi vault. This milestone is currently **ON HOLD** until further notice or explicit permission is given to proceed.

### Key Features:

*   **Fee Calculation:**
    *   [ ] Implement a service to monitor current Ethereum L2 gas fees.
    *   [ ] Create an endpoint to provide the calculated "Payou Handling Fee" to the app.
*   **Vault Automation:**
    *   [ ] Implement a scheduled job or trigger to monitor the Vault's USDC balance.
    *   [ ] Automate the call to the rebalancing smart contract.
*   **Liquidity Provider Rewards:**
    *   [ ] Logic to calculate and track ETH rewards for Vault depositors.
    *   [ ] Endpoint for users to check their claimable rewards.
*   **Transparency Dashboard:**
    *   [ ] API endpoints to serve data for the Vault dashboard (TVL, Volume, Fees, APY).

This milestone focuses on preparing the server for a production environment on Google Cloud.

### Key Features:

*   **CI/CD Pipeline:**
    *   [ ] Set up GitHub Actions to test and build the server on every push.
    *   [ ] Automate deployment to Google Cloud Run.
*   **Security & Monitoring:**
    *   [ ] Implement robust input validation and error handling.
    *   [ ] Set up structured logging and performance monitoring.
    *   [ ] Implement rate limiting on public endpoints.
