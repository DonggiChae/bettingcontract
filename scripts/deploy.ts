import { ethers, artifacts } from "hardhat";
const path = require("path");

async function main() {
  const Bet = await ethers.getContractFactory("Betting");
  const bet = await Bet.deploy();

  await bet.deployed();

  console.log(`Address: ${bet.address}`);
  saveFrontendFiles(bet);
}

function saveFrontendFiles(lock: any) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "contract-address.json"),
    JSON.stringify({ lock: lock.address }, undefined, 2)
  );

  const LockArtifact = artifacts.readArtifactSync("Betting");

  fs.writeFileSync(
    path.join(contractsDir, "Betting.json"),
    JSON.stringify(LockArtifact, null, 2)
  );
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
