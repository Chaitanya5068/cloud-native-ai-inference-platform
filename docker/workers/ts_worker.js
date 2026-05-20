/*
 * TypeScript Worker - Second step in the processing pipeline
 * Receives data from Python worker and forwards to Model worker
 */

const express = require('express');
const axios = require('axios');

const app = express();
const PORT = process.env.TS_WORKER_PORT || 8002;
const MODEL_WORKER_URL = process.env.MODEL_WORKER_URL || 'http://localhost:8003';

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'ts-worker'
    });
});

// Process endpoint
app.post('/process', async (req, res) => {
    try {
        const data = req.body;
        const prompt = data.prompt;
        const model = data.model || 'default';
        
        console.log(`[ts-worker] Processing prompt: ${prompt.substring(0, 50)}...`);
        
        if (!prompt) {
            return res.status(400).json({
                error: 'Prompt cannot be empty'
            });
        }
        
        // Add TypeScript processing metadata
        const processedData = {
            prompt: prompt,
            model: model,
            step: 'typescript',
            timestamp: new Date().getTime()
        };
        
        console.log(`[ts-worker] Adding processing metadata`);
        
        // Forward to Model Worker
        console.log(`[ts-worker] Forwarding to model worker: ${MODEL_WORKER_URL}`);
        
        const response = await axios.post(
            `${MODEL_WORKER_URL}/process`,
            processedData,
            { timeout: 30000 }
        );
        
        res.json(response.data);
        
    } catch (error) {
        console.error(`[ts-worker] Error: ${error.message}`);
        res.status(500).json({
            error: error.message
        });
    }
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        service: 'TypeScript Worker',
        version: '1.0.0',
        port: PORT
    });
});

app.listen(PORT, () => {
    console.log(`[ts-worker] TypeScript Worker listening on port ${PORT}`);
});
