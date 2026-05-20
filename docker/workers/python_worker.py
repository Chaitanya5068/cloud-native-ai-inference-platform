import asyncio
import httpx
import json
import logging
import os
from typing import Dict, Any

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class PythonWorker:
    """Python Worker - First step in the processing pipeline"""
    
    def __init__(self):
        self.name = "python-worker"
        self.service_port = int(os.getenv("PYTHON_WORKER_PORT", 8001))
        self.ts_worker_url = os.getenv("TS_WORKER_URL", "http://localhost:8002")
        self.max_workers = 4
        
    async def process(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process request and forward to TypeScript worker
        
        Args:
            data: Dictionary with prompt and model info
            
        Returns:
            Processed response from the pipeline
        """
        try:
            prompt = data.get("prompt", "")
            model = data.get("model", "default")
            
            logger.info(f"[{self.name}] Processing prompt: {prompt[:50]}...")
            
            # Validate input
            if not prompt or len(prompt) == 0:
                raise ValueError("Prompt cannot be empty")
            
            # Add processing metadata
            processed_data = {
                "prompt": prompt,
                "model": model,
                "step": "python",
                "timestamp": asyncio.get_event_loop().time()
            }
            
            # Log processing
            logger.info(f"[{self.name}] Adding processing metadata")
            
            # Forward to TypeScript worker
            logger.info(f"[{self.name}] Forwarding to TS worker: {self.ts_worker_url}")
            
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    f"{self.ts_worker_url}/process",
                    json=processed_data,
                    headers={"Content-Type": "application/json"}
                )
                
                if response.status_code != 200:
                    raise Exception(f"TS Worker error: {response.status_code}")
                
                return response.json()
                
        except Exception as e:
            logger.error(f"[{self.name}] Error: {str(e)}")
            raise

async def main():
    """Main entry point for Python Worker"""
    from fastapi import FastAPI, HTTPException
    import uvicorn
    
    app = FastAPI(title="Python Worker")
    worker = PythonWorker()
    
    @app.get("/health")
    async def health():
        return {"status": "healthy", "service": "python-worker"}
    
    @app.post("/process")
    async def process(request: dict):
        try:
            result = await worker.process(request)
            return result
        except Exception as e:
            logger.error(f"Error: {str(e)}")
            raise HTTPException(status_code=500, detail=str(e))
    
    logger.info(f"Starting Python Worker on port {worker.service_port}")
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=worker.service_port,
        log_level="info"
    )

if __name__ == "__main__":
    asyncio.run(main())
