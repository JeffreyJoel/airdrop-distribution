import { ethers } from "hardhat";

async function main() {

  const linkToken = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB";
  const id = 9789;

  const token = await ethers.deployContract("TokenA");
  
  await token.waitForDeployment();

  const airdrop = await ethers.deployContract("AirdropDistribution", [id, linkToken, token.target]);

  console.log(
    `Airdrop  deployed to ${airdrop.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
