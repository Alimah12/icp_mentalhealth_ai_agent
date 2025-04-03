# Mental Health Medical Chatbot (Web3, ICP)

## Overview
This project is a decentralized mental health chatbot built using Web3 technologies on the Internet Computer Protocol (ICP). The chatbot provides users with mental health support, tracks interactions, and rewards users with tokens for engagement. It leverages ICP's canister-based architecture and tokenization system to provide secure, transparent, and decentralized mental health support.

## Contributors

Vincent Muriithi Karimi - vincentmuriithi06@gamil.com
Ali Malala - alimalala100@gmail.com
Denis Benard Wambua - denisbenard118@gmail.com
Sharille Roberts Wamalwa - sharillerobert@gmail.com

## Features.
- **AI-powered chatbot** that provides mental health support.
- **Decentralized architecture** running on ICP.
- **Tokenization system** to reward user engagement.
- **User authentication** through ICP wallets.
- **Secure data handling** using smart contracts.
- **Scalable and censorship-resistant** deployment on ICP.

## Technology Stack
- **Backend:** Motoko (ICP Canister Development)
- **Frontend:** React.js (Web3 Integrated UI)
- **Web3 Integration:** ICP SDK, ICP Ninja
- **Storage:** Canister-based decentralized storage
- **Deployment:** DFINITY SDK, ICP Mainnet

## Getting Started
### Prerequisites
Before you begin, ensure you have the following installed:
- [DFINITY SDK](https://sdk.dfinity.org/) (for ICP development)
- [Node.js](https://nodejs.org/) (for frontend development)
- ICP Ninja (optional, for easier deployment)

### Setup Instructions
1. **Clone the Repository**
   ```bash
   git clone https://github.com/Alimah12/icp_mental-health-ai_agent.git
   cd mental-health-chatbot
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```


3. **Set up canisters**
   ```bash
   dfx start
   dfx build
   ```

4. **Deploy the Canister Locally**
   ```bash
   dfx deploy
   ```


## Project Structure
```
mental-health-chatbot/
│── src/
  ├── mental-health-chatbot_backend/
      ├── main.mo  
  ├── mental-health-chatbot_backend/
│     ├── main.mo       # Chatbot logic (Motoko)
│
│   ├── frontend/
│       ├── src/
│       │   ├── App.js   # Main React frontend
│       │   ├── main.js  # Web3 integration
│── dfx.json              # ICP canister configuration
│── package.json          # Node dependencies
│── README.md             # Project documentation
```

## Usage
1. Interact with the chatbot by sending messages.
2. Earn tokens based on engagement.
3. Check your token balance through the UI.
4. Redeem tokens for rewards (future implementation).

## Deployment on ICP Mainnet
Once tested locally, deploy to ICP’s mainnet:
```bash
dfx deploy --network ic
```

## Future Enhancements.
- Advanced AI chatbot responses.
- Expanded token-based reward system.
- Integration with mental health resources.
- Decentralized identity verification.

## Contributing
Contributions are welcome! Feel free to submit issues or pull requests.

## License
This project is open-source and available under the MIT License.

