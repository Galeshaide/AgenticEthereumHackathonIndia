// reminder-server/index.js
require("dotenv").config();
const express = require("express");
const twilio = require("twilio");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const client = twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

app.post("/send-reminder", async (req, res) => {
  const { to, loanId, dueDate } = req.body;

  try {
    const message = await client.messages.create({
      body: `🕒 Reminder: Your GrameenChain loan (ID: ${loanId}) is due on ${dueDate}. Please repay on time to improve your credit profile.`,
      from: process.env.TWILIO_WHATSAPP_NUMBER,
      to: `whatsapp:${to}`,
    });

    console.log("✅ WhatsApp reminder sent:", message.sid);
    res.status(200).json({ success: true });
  } catch (err) {
    console.error("❌ Failed to send WhatsApp:", err);
    res.status(500).json({ success: false });
  }
});

const PORT = 3002;
app.listen(PORT, () => {
  console.log(`📣 Reminder server running on http://localhost:${PORT}`);
});
