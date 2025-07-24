// Ultra-simple COBOL API mock for Railway
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', mode: 'mock' });
});

// Simple calculation endpoint
app.post('/calculate', (req, res) => {
    const { type, principal, rate, term } = req.body;
    
    if (type === 'LOAN-PAYMENT') {
        const monthlyRate = rate / 12 / 100;
        const payment = principal * monthlyRate * Math.pow(1 + monthlyRate, term) / 
                      (Math.pow(1 + monthlyRate, term) - 1);
        res.json({ payment: payment.toFixed(2) });
    } else {
        res.json({ result: 'calculated' });
    }
});

app.listen(PORT, () => {
    console.log(`API running on port ${PORT}`);
});