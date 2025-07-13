// loan-monitor-server/index.js
const { ethers } = require("ethers");
const dotenv = require("dotenv");
const EscrowABI = require("../shared/abis/EscrowLoan.json");
const SBTABI = require("../shared/abis/SoulboundToken.json");

dotenv.config();

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const signer = provider.getSigner(0); // Default Hardhat signer

const escrow = new ethers.Contract(
  process.env.ESCROW_ADDRESS,
  EscrowABI.abi,
  signer
);
const sbt = new ethers.Contract(process.env.SBT_ADDRESS, SBTABI.abi, signer);

async function checkDefaults() {
  try {
    const loanCounter = await escrow.loanCounter();

    for (let i = 0; i < loanCounter; i++) {
      const loan = await escrow.loans(i);

      if (loan.status === 1) {
        // Active
        const now = Math.floor(Date.now() / 1000);
        if (now > loan.dueDate) {
          console.log(`⏰ Checking loan ${i} for default...`);

          const tx = await escrow.checkDefault(i);
          await tx.wait();

          const updatedLoan = await escrow.loans(i);
          if (updatedLoan.status === 3) {
            await sbt.recordDefault(i);
            console.log(`❌ Loan ${i} defaulted. SBT updated.`);
          }
        }
      }
    }
  } catch (err) {
    console.error("Error checking loans:", err.message);
  }
}

// Run every 60 seconds
setInterval(checkDefaults, 60000);

console.log("🔄 Loan monitor running every 60s...");
