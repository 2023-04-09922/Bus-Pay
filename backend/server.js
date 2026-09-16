const fs = require('fs');
const path = require('path');
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');

const app = express();
app.use(cors());
app.use(express.json());

const dataFile = path.join(__dirname, 'data.json');

function defaultDb() {
  return {
    conductors: [],
    agents: [
      {
        email: 'wakala@buspay.co.tz',
        passwordHash: bcrypt.hashSync('Wakala@123', 10),
        firstName: 'Asha',
        lastName: 'Juma',
        phone: '+255755123456',
        tillNumber: '1234-5678',
        role: 'agent',
      },
    ],
    resetCodes: {},
  };
}

function loadDb() {
  try {
    if (fs.existsSync(dataFile)) {
      const parsed = JSON.parse(fs.readFileSync(dataFile, 'utf8'));
      return {
        conductors: Array.isArray(parsed.conductors) ? parsed.conductors : [],
        agents: Array.isArray(parsed.agents) && parsed.agents.length
          ? parsed.agents
          : defaultDb().agents,
        resetCodes: parsed.resetCodes && typeof parsed.resetCodes === 'object'
          ? parsed.resetCodes
          : {},
      };
    }
  } catch (err) {
    console.error('Failed to read data.json, starting fresh', err.message);
  }
  return defaultDb();
}

function saveDb() {
  fs.writeFileSync(
    dataFile,
    JSON.stringify(
      { conductors: db.conductors, agents: db.agents, resetCodes: db.resetCodes },
      null,
      2,
    ),
  );
}

const db = loadDb();
saveDb();

function normalizePhone(raw) {
  let digits = String(raw || '').replace(/\D/g, '');
  while (digits.startsWith('255')) digits = digits.slice(3);
  if (digits.startsWith('0')) digits = digits.slice(1);
  digits = digits.slice(0, 9);
  return digits.length === 9 ? `+255${digits}` : '';
}

function normalizeNida(raw) {
  return String(raw || '').replace(/\D/g, '').slice(0, 20);
}

function makeUsername() {
  let username;
  do {
    const code = String(Math.floor(100000 + Math.random() * 900000));
    username = `Bp-c${code}bus`;
  } while (db.conductors.some((c) => c.username.toLowerCase() === username.toLowerCase()));
  return username;
}

function bearerUser(req) {
  const header = String(req.headers.authorization || '');
  const token = header.replace(/^Bearer\s+/i, '').trim();
  if (!token) return null;
  if (token.startsWith('conductor-')) {
    const username = token.slice('conductor-'.length);
    return db.conductors.find(
      (c) => c.username.toLowerCase() === username.toLowerCase(),
    ) || null;
  }
  if (token.startsWith('agent-')) {
    const email = token.slice('agent-'.length);
    return db.agents.find((a) => a.email.toLowerCase() === email.toLowerCase()) || null;
  }
  return null;
}

function publicConductor(user) {
  return {
    username: user.username,
    role: 'conductor',
    firstName: user.firstName,
    lastName: user.lastName,
    phone: user.phone,
    nida: user.nida,
  };
}

app.get('/health', (_req, res) => res.json({ ok: true }));

app.post('/auth/register/conductor', (req, res) => {
  const { firstName, lastName, phone, nida, pin, confirmPin, password, confirmPassword } =
    req.body || {};
  const usePin = String(pin ?? password ?? '');
  const useConfirm = String(confirmPin ?? confirmPassword ?? '');
  const phoneNorm = normalizePhone(phone);
  const nidaNorm = normalizeNida(nida);

  if (!String(firstName || '').trim() || !String(lastName || '').trim() || !phoneNorm || !nidaNorm || !usePin) {
    return res.status(400).json({ message: 'Fill all fields' });
  }
  if (!/^\d{4}$/.test(usePin)) {
    return res.status(400).json({ message: 'PIN must be 4 digits' });
  }
  if (usePin !== useConfirm) {
    return res.status(400).json({ message: 'PIN does not match' });
  }
  if (nidaNorm.length !== 20) {
    return res.status(400).json({ message: 'NIDA must be 20 digits' });
  }
  if (db.conductors.some((c) => c.phone === phoneNorm)) {
    return res.status(409).json({ message: 'Phone already registered' });
  }
  if (db.conductors.some((c) => c.nida === nidaNorm)) {
    return res.status(409).json({ message: 'NIDA already registered' });
  }

  const username = makeUsername();
  const user = {
    username,
    pinHash: bcrypt.hashSync(usePin, 10),
    firstName: String(firstName).trim(),
    lastName: String(lastName).trim(),
    phone: phoneNorm,
    nida: nidaNorm,
    role: 'conductor',
  };
  db.conductors.push(user);
  saveDb();

  return res.json({
    success: true,
    username,
    user: publicConductor(user),
  });
});

app.post('/auth/login', (req, res) => {
  const { username, pin, password } = req.body || {};
  const usePin = String(pin ?? password ?? '');
  const user = db.conductors.find(
    (c) => c.username.toLowerCase() === String(username || '').toLowerCase(),
  );
  if (!user) {
    return res.status(404).json({ success: false, message: 'Account not found' });
  }
  if (!/^\d{4}$/.test(usePin)) {
    return res.status(401).json({ success: false, message: 'Wrong PIN' });
  }
  const ok = bcrypt.compareSync(usePin, user.pinHash);
  if (!ok) {
    return res.status(401).json({ success: false, message: 'Wrong PIN' });
  }
  return res.json({
    success: true,
    token: `conductor-${user.username}`,
    user: publicConductor(user),
  });
});

app.post('/auth/agent/login', (req, res) => {
  const { email, password } = req.body || {};
  const agent = db.agents.find(
    (a) => a.email.toLowerCase() === String(email || '').toLowerCase(),
  );
  if (!agent) {
    return res.status(401).json({ success: false, message: 'Login failed' });
  }
  const ok = bcrypt.compareSync(String(password || ''), agent.passwordHash);
  if (!ok) {
    return res.status(401).json({ success: false, message: 'Login failed' });
  }
  return res.json({
    success: true,
    token: `agent-${agent.email}`,
    user: {
      username: agent.email,
      email: agent.email,
      role: 'agent',
      firstName: agent.firstName,
      lastName: agent.lastName,
      phone: agent.phone,
      tillNumber: agent.tillNumber,
    },
  });
});

app.post('/auth/agent/forgot-password', (req, res) => {
  const email = String(req.body?.email || '').toLowerCase().trim();
  const agent = db.agents.find((a) => a.email.toLowerCase() === email);
  if (!agent) {
    return res.status(404).json({ message: 'Account not found' });
  }
  const code = String(Math.floor(100000 + Math.random() * 900000));
  db.resetCodes[email] = code;
  saveDb();
  return res.json({ success: true, code });
});

app.post('/auth/agent/reset-password', (req, res) => {
  const email = String(req.body?.email || '').toLowerCase().trim();
  const code = String(req.body?.code || '');
  const password = String(req.body?.password || '');
  const confirmPassword = String(req.body?.confirmPassword || '');
  const agent = db.agents.find((a) => a.email.toLowerCase() === email);
  if (!agent) {
    return res.status(404).json({ message: 'Account not found' });
  }
  if (!db.resetCodes[email] || db.resetCodes[email] !== code) {
    return res.status(400).json({ message: 'Invalid reset code' });
  }
  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'Passwords do not match' });
  }
  if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/.test(password)) {
    return res.status(400).json({ message: 'Password is not strong enough' });
  }
  agent.passwordHash = bcrypt.hashSync(password, 10);
  delete db.resetCodes[email];
  saveDb();
  return res.json({ success: true });
});

app.post('/auth/change-pin', (req, res) => {
  const user = bearerUser(req);
  if (!user || user.role !== 'conductor') {
    return res.status(401).json({ message: 'Wrong PIN' });
  }
  const currentPin = String(req.body?.currentPin || '');
  const newPin = String(req.body?.newPin || '');
  const confirmPin = String(req.body?.confirmPin || '');
  if (!bcrypt.compareSync(currentPin, user.pinHash)) {
    return res.status(401).json({ message: 'Wrong PIN' });
  }
  if (!/^\d{4}$/.test(newPin)) {
    return res.status(400).json({ message: 'PIN must be 4 digits' });
  }
  if (newPin !== confirmPin) {
    return res.status(400).json({ message: 'PIN does not match' });
  }
  user.pinHash = bcrypt.hashSync(newPin, 10);
  saveDb();
  return res.json({ success: true });
});

app.post('/auth/agent/change-password', (req, res) => {
  const user = bearerUser(req);
  if (!user || user.role !== 'agent') {
    return res.status(401).json({ message: 'Login failed' });
  }
  const currentPassword = String(req.body?.currentPassword || '');
  const password = String(req.body?.password || '');
  const confirmPassword = String(req.body?.confirmPassword || '');
  if (!bcrypt.compareSync(currentPassword, user.passwordHash)) {
    return res.status(401).json({ message: 'Login failed' });
  }
  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'Passwords do not match' });
  }
  if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/.test(password)) {
    return res.status(400).json({ message: 'Password is not strong enough' });
  }
  user.passwordHash = bcrypt.hashSync(password, 10);
  saveDb();
  return res.json({ success: true });
});

app.post('/auth/forgot-pin', (req, res) => {
  const phone = normalizePhone(req.body?.phone);
  const nida = normalizeNida(req.body?.nida);
  const user = db.conductors.find((c) => c.phone === phone && c.nida === nida);
  if (!user) {
    return res.status(404).json({ message: 'Account not found' });
  }
  const code = String(Math.floor(100000 + Math.random() * 900000));
  db.resetCodes[`pin:${user.username}`] = code;
  saveDb();
  return res.json({ success: true, code, username: user.username });
});

app.post('/auth/reset-pin', (req, res) => {
  const phone = normalizePhone(req.body?.phone);
  const nida = normalizeNida(req.body?.nida);
  const code = String(req.body?.code || '');
  const pin = String(req.body?.pin || '');
  const confirmPin = String(req.body?.confirmPin || '');
  const user = db.conductors.find((c) => c.phone === phone && c.nida === nida);
  if (!user) {
    return res.status(404).json({ message: 'Account not found' });
  }
  const key = `pin:${user.username}`;
  if (!db.resetCodes[key] || db.resetCodes[key] !== code) {
    return res.status(400).json({ message: 'Invalid reset code' });
  }
  if (!/^\d{4}$/.test(pin) || pin !== confirmPin) {
    return res.status(400).json({ message: 'PIN does not match' });
  }
  user.pinHash = bcrypt.hashSync(pin, 10);
  delete db.resetCodes[key];
  saveDb();
  return res.json({ success: true, username: user.username });
});

const port = process.env.PORT || 3000;
app.listen(port, '0.0.0.0', () => {
  console.log(`BUS PAY backend on http://0.0.0.0:${port}`);
});
