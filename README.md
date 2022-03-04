# YoLottery
![GitHub](https://img.shields.io/github/license/mtwichan/YoLottery)

<p align="center">
  <img src="https://user-images.githubusercontent.com/33464965/156829072-366a9cbe-dc02-4fe8-a38f-01cdac97a104.png" width="200" height="200" />
</p>

YoLottery is a decentralized application built on the Ethereum network. The premise of the application is for players to put cryptocurrency (Ethereum/ERC20 tokens) into a time expiring pool, where the pool of cryptocurrency is randomly distributed to all players at expiration. 

## Project Status
The project is currently a work in progress. The first version has yet to be released.

## Installation
This project uses the Node package manager. 

Please install [Node.js](https://nodejs.org/en/) and ensure you are using version `16.xx.xx`.

### Frontend
1. Navigate to the `frontend` folder from the root directory: `cd frontend`
2. Install the frontend dependencies: `npm install`
3. Run the React application: `npm run start`

### Backend (Smart Contract)
1. Navigate to the root directory.
2. Install the backend dependencies: `npm install`
3. Compile the smart contract: `npx hardhat compile`
4. Deploy the smart contract on the Hardhat network: `npx hardhat run scripts/deploy.ts --network hardhat`
5. Ensure the smart contract work by running: `npx hardhat tests`. All tests should pass successfully.

## Usage
Work in progress ...

## Contributing
The project is currently a work in progress and is open to contributors.

For any changes to the code please open an issue first to discuss the changes you'd like to make. If you have any thoughts or ideas that you'd like to discuss you can open an issue or contact me personally at `mtwichan@gmail.com`.

## License
[MIT License](https://opensource.org/licenses/MIT) 

Please refer to `LICENSE.md` for more information.
