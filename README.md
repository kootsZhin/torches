<h1 align="center">
  <img src="./img/torches.png" width="250"/>
  <br>
  torches
</h1>

<h4 align="center">A dead man's switch for your ethers</h4>

## 1) What

A smart contract for managing your ethers & ERC20 assets (soon!). Light a [`torch`](./src/Torch.sol) with [`torches.sol`](./src/Torches.sol), continue to fuel the torch within every `fuelPeriod` or you will be assumed dead and your beneficiary will be allowed to withdraw your fund.

This projcet is inspired by [skmgoldin/dead-mans-switch](https://github.com/skmgoldin/dead-mans-switch).

By the way, [Torches by Aimer](https://open.spotify.com/album/3UgjhFUDODWWBi9ga7mjrC) is an amazing song.

### [`torches.sol`](./src/Torches.sol)
Factory for creating (`light`) a [`torch`](./src/Torch.sol).

```solidity
function light(
    address owner,
    address beneficiary,
    uint256 fuelPeriod
) external payable returns (address torch);
```

### [`torch.sol`](./src/Torch.sol)
Main logic of the smart contract, super simple and poorly optimized.

## Test

```bash
forge install
forge test
```