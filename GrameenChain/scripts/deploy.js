const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with:", deployer.address);

  // Deploy AgentRegistry
  const AgentRegistry = await ethers.getContractFactory("AgentRegistry");
  const agentRegistry = await AgentRegistry.deploy();
  await agentRegistry.waitForDeployment();
  console.log("AgentRegistry deployed to:", await agentRegistry.getAddress());

  // Deploy SavingsPool
  const SavingsPool = await ethers.getContractFactory("SavingsPool");
  const savingsPool = await SavingsPool.deploy();
  await savingsPool.waitForDeployment();
  console.log("SavingsPool deployed to:", await savingsPool.getAddress());

  // Deploy MicroLoan
  const MicroLoan = await ethers.getContractFactory("MicroLoan");
  const microLoan = await MicroLoan.deploy();
  await microLoan.waitForDeployment();
  console.log("MicroLoan deployed to:", await microLoan.getAddress());

  // Deploy CreditScore
  const CreditScore = await ethers.getContractFactory("CreditScore");
  const creditScore = await CreditScore.deploy();
  await creditScore.waitForDeployment();
  console.log("CreditScore deployed to:", await creditScore.getAddress());

  // ✅ Deploy SoulboundToken first
  const SoulboundToken = await ethers.getContractFactory("SoulboundToken");
  const sbt = await SoulboundToken.deploy(deployer.address);
  await sbt.waitForDeployment();
  const sbtAddress = await sbt.getAddress();
  console.log("SoulboundToken deployed to:", sbtAddress);

  // ✅ Now deploy EscrowLoan with SoulboundToken address
  const EscrowLoan = await ethers.getContractFactory("EscrowLoan");
  const escrowLoan = await EscrowLoan.deploy(sbtAddress);
  await escrowLoan.waitForDeployment();
  console.log("EscrowLoan deployed to:", await escrowLoan.getAddress());
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exitCode = 1;
});
