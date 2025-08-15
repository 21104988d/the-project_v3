# **Payou: A Whitepaper**

## **1. Introduction: The Next Evolution in Digital Payments**
The world of finance is in the midst of a profound transformation, with blockchain technology poised to deliver a future that is not only faster and cheaper but also more transparent and secure. The Ethereum network stands as the bedrock of this new financial landscape, offering unparalleled security and decentralization. However, for all its strengths, high gas fees on Ethereum's main layer have remained a critical barrier to its use for everyday payments.

This is where **Payou** comes in.

Payou is a mobile payment application for **iOS and Android**, built to bridge this gap. It operates on a state-of-the-art **Ethereum Layer 2 (Optimistic Rollup)**, which allows us to inherit the robust security of the main Ethereum network while processing transactions at a fraction of the cost and at significantly higher speeds.

Our long-term vision is to operate on Ethereum Layer 1 when it becomes viable for high-frequency, low-value transactions. For now, we are committed to leveraging the best of Layer 2 technology to deliver on the promise of the blockchain today. Our mission is to democratize digital payments, empowering both merchants and consumers to participate in the future of finance without the burdens of high fees or technical complexity.

## **2. The Problem: Barriers to Mainstream Crypto Adoption**
For businesses and consumers to embrace cryptocurrency for daily transactions, the experience must be seamless, affordable, and secure. Today, several key barriers stand in the way:

*   **Prohibitive Transaction Fees:** While Ethereum provides the most secure settlement layer, its gas fees can be prohibitively expensive for small, everyday purchases, making it impractical for retail use. On the other hand, traditional payment networks charge merchants a significant percentage of every transaction (typically 2-4%), with these costs ultimately passed on to consumers.
*   **Scalability and Transaction Speed:** The throughput of Ethereum Layer 1 can lead to network congestion and slow confirmation times, an experience that is not suitable for the fast-paced environment of point-of-sale transactions.
*   **Complexity and User Experience:** For those new to crypto, the concepts of gas fees, private keys, and network layers create a steep learning curve. The risk of error is high, and the user experience is often intimidating, preventing widespread adoption by the general public.

Payou is engineered to systematically dismantle these barriers by leveraging the scalability of Layer 2, today.

## **3. The User Experience: A Simple Payment Flow**
Payou is designed to be as simple and intuitive as the most popular traditional payment apps. The primary customer-to-business payment flow is designed for speed and clarity:
1.  **Merchant Generates QR Code:** The merchant opens the Payou app on their device, types in the transaction amount (e.g., $150.50), and their app instantly generates a unique QR code containing their wallet address and the specific payment amount.
2.  **Customer Scans:** The customer opens the Payou app on their phone, taps the "Scan" button, and points their camera at the merchant's QR code.
3.  **Customer Confirms:** The customer's screen immediately displays the payment details: the merchant's name and the exact amount. The customer simply presses a single "Confirm Payment" button to approve the transaction.

This entire process takes only a few seconds and requires no knowledge of blockchain addresses, gas fees, or other technical details.

## **4. The Payou Transaction Flow: A Gasless Experience**
Payou eliminates the barrier of network gas fees entirely. When you make a payment with Payou, you do not need to worry about holding ETH for gas. The only fee you see is the single, transparent "Payou Handling Fee," which is denominated in USDC. Our system, powered by the Payou Vault, handles the network fee settlement in the background.

## **5. Payou's Dynamic Handling Fee**
Payou charges a dynamic handling fee calculated with a transparent formula:
**Payou Handling Fee = `L2 Network Gas Fee * (log(Amount in USD) + 0.5)`**
This fee has two parts: a Vault Contribution that scales slowly with transaction size, and a fixed Platform Fee (`0.5`) for operations. This fee is collected in USDC.

## **6. The Payou Vault: A Decentralized Liquidity Engine**
The Payou Vault is the decentralized heart of our gasless system.
*   **Providing Liquidity:** Users can deposit **ETH** into the Vault to help fund the platform's gas fees.
*   **Rebalancing Mechanism:** The Vault pays gas fees in ETH and collects handling fees in USDC. When the collected USDC reaches a $1,000 threshold, a smart contract automatically swaps it for ETH via Uniswap to replenish the Vault.
*   **Earning Rewards:** In return for providing liquidity, depositors earn rewards in **ETH**, claimable after accumulating a $10 USD equivalent.
*   **Transparency:** A dedicated dashboard shows the Vault's TVL, 30-day volume, 30-day fees collected, and a projected APY.

## **7. User Onboarding and Wallet Management**
Access to Payou is secured through a dedicated login system, allowing users to register and sign in with an email address, phone number, or a unique username.

To comply with regulations and ensure a secure ecosystem, all users are required to complete a **Know Your Customer (KYC)** verification process before an account can be fully activated. After successful verification, users can manage their funds with the following tools:

*   **Create Wallet:** Generate a new, secure, non-custodial wallet directly within the app.
*   **Import Wallet:** Import an existing Ethereum-compatible wallet using a standard seed phrase.
*   **Fiat On-Ramp (Pending):** A fiat-to-crypto on-ramp is in development, pending regulatory approval in Hong Kong.

## **8. Currency: The Stablecoin Standard**
All transactions on the Payou platform are currently denominated in **USDC**. We plan to integrate a compliant Hong Kong Dollar (HKD) stablecoin in the future.

## **9. Technical Architecture**
Payou is built on Clean Architecture principles to ensure a modular, scalable, and testable codebase.

### Mobile Application Architecture
**Diagram: Mobile Application Clean Architecture**
```mermaid
graph TD
    subgraph Presentation Layer (Flutter)
        A[Screens & Widgets] -- talks to --> B[State Management (Bloc/Cubit)];
    end

    subgraph Domain Layer (Pure Dart)
        B -- uses --> C[Use Cases / Interactors];
        C -- operates on --> D[Entities / Core Data Models];
    end

    subgraph Data Layer (Dart + Native)
        C -- implemented by --> E[Repositories];
        E -- gets data from --> F[Data Sources];
        subgraph F
            G[**Remote Data Source**<br>Backend API Client (gRPC/HTTP)]
            H[**Local Data Source**<br>Secure Storage, Preferences]
            I[**Blockchain Data Source**<br>Ethereum L2 SDK (e.g., web3dart), RPC Client]
        end
    end
```

### Backend Server Architecture
The backend server, built with FastAPI, acts as the central hub for user management, regulatory compliance, and integration with external DeFi protocols. It provides a robust API for the mobile application.

**Key Responsibilities:**
*   **User Management:** Handles user registration, authentication (JWT), and profile management.
*   **KYC & Compliance:** Manages the Know Your Customer (KYC) process and maintains a secure internal transaction ledger for regulatory purposes.
*   **Hedging System:** Integrates with the Hyperliquid exchange to fetch market data (ETH price, funding rates) and manage dynamic short perpetual positions for risk mitigation.
*   **Data Provisioning:** Serves various data points to the mobile application, including user profiles, transaction history, and market data.

**Diagram: Overall System Architecture**
```mermaid
graph TD
    subgraph Mobile Application
        A[Payou App (Flutter)]
    end

    subgraph Backend Server
        B[FastAPI Server]
    end

    subgraph External Services
        C[Database (SQLite/PostgreSQL)]
        D[Hyperliquid Exchange (Testnet)]
        E[KYC Provider (Simulated)]
    end

    A -- API Calls (HTTP) --> B
    B -- ORM (SQLAlchemy) --> C
    B -- API Calls --> D
    B -- API Calls --> E
```

## **10. Technology Stack**
| Component | Technology |
| :--- | :--- |
| **UI Framework** | **Flutter (with Dart)** |
| **Blockchain Interaction** | **web3dart / walletconnect_flutter** |
| **State Management** | **flutter_bloc (Bloc/Cubit)** |
| **Secure Storage** | `flutter_secure_storage` |
| **API Communication** | **gRPC / Dio (HTTP Client)** |
| **Native Integration** | **Flutter Platform Channels** |
| **Backend Server** | **Python (FastAPI), SQLAlchemy, Redis, Hyperliquid Python SDK** |

## **11. Application Internals**
#### **Directory Structure**
The project follows a feature-first, layered directory structure:
```
payou_project/
├── app/
│   └── lib/
│       ├── core/                  # Shared code, utilities, core dependencies
│       └── features/              # Each feature as a self-contained module
│           ├── auth/
│           ├── wallet/
│           │   ├── data/
│           │   ├── domain/
│           │   └── presentation/
│           ├── vault/
│           └── payment/
└── server/
    └── ...                  # Server-side code (e.g., Node.js, Go, etc.)
```
#### **Data Models**
A clear separation is maintained between pure Domain entities and Data Transfer Objects (DTOs).
```dart
// Domain Layer Entity (Pure Dart)
class TransactionEntity {
  final String transactionHash;
  final DateTime timestamp;
  final String recipientAddress;
  final double amountUsdc;
}

// Data Layer Model (from API)
class TransactionModelDto extends TransactionEntity {
  final String senderAddress;
  final double fee;
  TransactionModelDto.fromJson(Map<String, dynamic> json) { ... }
}
```

## **12. Security, Testing, and Compliance**
#### **Advanced Security Protocols**
*   **On-Device Key Storage:** Private keys are encrypted with a user-defined PIN and stored in the device's secure enclave (Keychain/Keystore). They exist in memory only transiently during signing.
*   **App Integrity:** The app uses `flutter_jailbreak_detection` to check for compromised operating systems and will restrict functionality to prevent theft.
*   **Certificate Pinning:** We pin the backend server's public key hash in the app to prevent all Man-in-the-Middle (MITM) attacks.
*   **Screen Security:** On sensitive screens like seed phrase backups, we disable screenshots and screen recording at the OS level.

#### **Regulatory Compliance**
To prevent illicit activities and comply with Anti-Money Laundering (AML) regulations in Hong Kong, Payou maintains a secure, internal ledger of all transactions. This record includes the sender's and receiver's wallet addresses, transaction amounts, timestamps, and the on-chain transaction hash (hex).

#### **Comprehensive Testing Strategy**
*   **Unit Tests:** All business logic (Blocs, Use Cases) will have >90% test coverage.
*   **Widget Tests:** Every screen and complex widget is tested to ensure the UI correctly reflects the application state.
*   **Integration Tests:** Full feature flows are tested from the UI down to the data layer using mock data sources.
*   **End-to-End (E2E) Tests:** Automated scripts run on real devices to perform key user journeys against a testnet environment.

## **13. Development & CI/CD**
Our development process follows professional standards to ensure code quality and rapid iteration.
*   **Version Control:** Git (using a feature-branching workflow).
*   **CI/CD:** GitHub Actions are used to automate our workflow:
    *   **On every commit:** Run static analysis and all unit/widget tests.
    *   **On pull request:** Build the app for Android and iOS and run integration tests.
    *   **On merge to `main`:** Automatically deploy the new build to a closed testing track (TestFlight/Google Play Internal Testing).

---
