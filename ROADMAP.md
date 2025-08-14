# Payou Development Roadmap

This document outlines the development milestones for the Payou mobile application.

## Milestone 1: Core Wallet Functionality (In Progress)

This milestone focuses on implementing the essential features required for basic, secure, and functional crypto transactions. The goal is to create a "proof-of-concept" that demonstrates the core value proposition of the Payou app.

### Key Features:

*   **Wallet Management:**
    *   [x] Create a new non-custodial wallet.
    *   [x] Import an existing wallet using a seed phrase.
    *   [x] Securely store the private key on the device.
*   **QR Code Payments:**
    *   [x] Generate a QR code for a specific payment amount.
    *   [x] Scan a QR code to initiate a payment.
*   **Transaction Processing:**
    *   [x] Connect to an Ethereum Layer 2 testnet.
    *   [x] Send a USDC transaction to the recipient's address.
    *   [x] Calculate and collect the Payou handling fee.
*   **Basic UI:**
    *   [x] Wallet balance screen.
    *   [x] Transaction history screen.
    *   [ ] Payment confirmation screen.

---

## Milestone 2: Company Wallet Integration (In Progress)

This milestone will focus on integrating a company wallet to handle gas fees and receive handling fees.

*   **Key Features:**
    *   [x] Use the company wallet to pay for gas fees.
    *   [x] Send the handling fee to the company wallet.
    *   [x] Get the company wallet private key from a secure location.
    *   [x] Use the official USDC contract on the Sepolia testnet.

---

## Milestone 3: User Onboarding & Security (Completed)

This milestone will focus on improving the user experience and security of the application.

*   **Key Features:**
    *   [x] Implement user registration and login.
    *   [x] Implement KYC verification.
    *   [x] Implement advanced security features (e.g., app integrity checks, certificate pinning).

---

## Milestone 4: UI/UX Polish (Completed)

This milestone will focus on improving the user interface and user experience of the application.

*   **Key Features:**
    *   [x] Design and implement a consistent and visually appealing UI.
    *   [x] Improve the user flow for all features.
    *   [x] Add animations and transitions to make the app feel more responsive.

---

## Milestone 5: Fiat On-Ramp & HKD Stablecoin (On Hold)

This milestone will focus on integrating a fiat on-ramp and a HKD stablecoin. This milestone is on hold until further notice.

*   **Key Features:**
    *   [ ] Integrate a fiat-to-crypto on-ramp.
    *   [ ] Integrate a compliant HKD stablecoin.

---

## Milestone 6: Payou Vault & Gasless Transactions (On Hold)

This milestone will focus on implementing the Payou Vault, which is the core component of the gasless transaction system. This milestone is on hold until further notice.

*   **Key Features:**
    *   [ ] Implement the Payou Vault smart contract.
    *   [ ] Allow users to deposit ETH into the Vault.
    *   [ ] Implement the rebalancing mechanism.
    *   [ ] Allow users to claim their rewards.
