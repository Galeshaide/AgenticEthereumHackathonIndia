const express = require("express");
const dotenv = require("dotenv");
const twilio = require("twilio");

dotenv.config();
const app = express();
app.use(express.json());

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

const PORT = process.env.PORT || 3003;

// ▶️ POST /call — Manually trigger a voice call
app.post("/call", async (req, res) => {
  const { to, message } = req.body;

  try {
    await client.calls.create({
      twiml: `<Response><Say voice="alice" language="en-IN">${message}</Say></Response>`,
      to,
      from: process.env.TWILIO_PHONE_NUM,
    });

    console.log(`📞 Call placed to ${to}`);
    res.status(200).send("Voice call triggered");
  } catch (err) {
    console.error("❌ Failed to call:", err.message);
    res.status(500).send("Call failed");
  }
});

// 🔁 GET /check-overdues — Simulate overdue check and trigger call
app.get("/check-overdues", async (req, res) => {
  // Simulated overdue data (In real app, fetch from smart contract or DB)
  const overdueUsers = [
    {
      name: "Ravi Kumar",
      phone: "+91XXXXXXXXXX", // replace with real test number
      loanId: 1,
      dueDate: "12 July 2025",
    },
  ];

  try {
    for (const user of overdueUsers) {
      const message = `Hello ${user.name}, your GrameenChain loan ID ${user.loanId} is overdue since ${user.dueDate}. 
      Please repay soon to maintain your reputation.`;

      await client.calls.create({
        twiml: `<Response><Say voice="alice" language="en-IN">${message}</Say></Response>`,
        to: user.phone,
        from: process.env.TWILIO_PHONE_NUM,
      });

      console.log(`📞 Overdue call triggered to ${user.name} (${user.phone})`);
    }

    res.status(200).send("Overdue check completed and calls made.");
  } catch (error) {
    console.error("❌ Error in /check-overdues:", error.message);
    res.status(500).send("Overdue call failed.");
  }
});

app.listen(PORT, () => {
  console.log(`📞 Voice agent server running on http://localhost:${PORT}`);
});
