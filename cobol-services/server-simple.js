const express = require('express');
const cors = require('cors');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Check if COBOL is available
const COBOL_AVAILABLE = fs.existsSync('./compiled/financial-calc');

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        cobol: COBOL_AVAILABLE ? 'available' : 'mock mode',
        timestamp: new Date().toISOString()
    });
});

// Mock COBOL calculations for demo
function mockCalculation(type, data) {
    switch(type) {
        case 'LOAN-PAYMENT':
            const { principal, rate, term } = data;
            const monthlyRate = rate / 12 / 100;
            const payment = principal * monthlyRate * Math.pow(1 + monthlyRate, term) / 
                          (Math.pow(1 + monthlyRate, term) - 1);
            return {
                payment: payment.toFixed(2),
                totalPayment: (payment * term).toFixed(2),
                totalInterest: ((payment * term) - principal).toFixed(2)
            };
        
        case 'CARD-VALIDATE':
            return { valid: true, type: 'VISA' };
            
        case 'ACCOUNT-BALANCE':
            return { balance: '10000.00', available: '9500.00' };
            
        default:
            return { error: 'Unknown calculation type' };
    }
}

// Calculate endpoint
app.post('/calculate', async (req, res) => {
    try {
        const { type, ...data } = req.body;
        
        if (COBOL_AVAILABLE) {
            // Try to use actual COBOL program
            const inputFile = `/tmp/cobol-${Date.now()}.json`;
            fs.writeFileSync(inputFile, JSON.stringify(data));
            
            exec(`./compiled/financial-calc ${inputFile}`, (error, stdout, stderr) => {
                fs.unlinkSync(inputFile);
                
                if (error) {
                    console.error('COBOL error, falling back to mock:', error);
                    res.json(mockCalculation(type, data));
                } else {
                    res.json(JSON.parse(stdout));
                }
            });
        } else {
            // Use mock calculations
            res.json(mockCalculation(type, data));
        }
    } catch (error) {
        console.error('Calculation error:', error);
        res.status(500).json({ error: 'Calculation failed' });
    }
});

// Authentication endpoint (mock)
app.post('/auth/login', (req, res) => {
    const { username, password } = req.body;
    
    // Mock authentication
    if (username && password) {
        res.json({
            success: true,
            token: 'mock-jwt-token-' + Date.now(),
            user: { username, role: 'bank_user' }
        });
    } else {
        res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
});

// Account sync endpoint (mock)
app.get('/mainframe/account/:id', (req, res) => {
    const { id } = req.params;
    
    // Mock mainframe data
    res.json({
        accountId: id,
        accountNumber: 'ACC' + id.padStart(10, '0'),
        balance: (Math.random() * 100000).toFixed(2),
        type: 'CHECKING',
        status: 'ACTIVE',
        lastSync: new Date().toISOString()
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`COBOL API Service running on port ${PORT}`);
    console.log(`Mode: ${COBOL_AVAILABLE ? 'COBOL' : 'Mock'}`);
});