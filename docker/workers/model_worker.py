import asyncio
import json
import logging
import os
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ModelWorker:
    """Model Worker - Final step in the processing pipeline"""
    
    def __init__(self):
        self.name = "model-worker"
        self.service_port = int(os.getenv("MODEL_WORKER_PORT", 8003))
        self.model_name = "mock-ai-model-v1"
        
    async def process(self, data: dict) -> dict:
        """
        Final processing step - simulate AI model inference
        
        Args:
            data: Dictionary with prompt and metadata
            
        Returns:
            Final response with mock AI-generated response
        """
        try:
            prompt = data.get("prompt", "")
            model = data.get("model", "default")
            
            logger.info(f"[{self.name}] Processing final step for: {prompt[:50]}...")
            
            # Simulate model inference
            await asyncio.sleep(0.5)  # Simulate processing time
            
            # Generate mock response based on prompt
            response = self._generate_mock_response(prompt)
            
            # Return final result
            return {
                "response": response,
                "model": model,
                "final_model": self.model_name,
                "timestamp": datetime.now().isoformat(),
                "status": "success",
                "pipeline": ["python", "typescript", "model"]
            }
            
        except Exception as e:
            logger.error(f"[{self.name}] Error: {str(e)}")
            raise
    
    def _generate_mock_response(self, prompt: str) -> str:
        """
        Generate mock AI response based on prompt
        
        Args:
            prompt: User's prompt
            
        Returns:
            Mock AI-generated response
        """
        # Simple mock responses based on keywords
        prompt_lower = prompt.lower()
        
        if "hello" in prompt_lower or "hi" in prompt_lower:
            return "Hello! I'm an AI inference service. How can I help you today?"
        
        elif "how" in prompt_lower and "work" in prompt_lower:
            return "I work through a distributed pipeline: Python Worker → TypeScript Worker → Model Worker. Each step adds processing and validation."
        
        elif "time" in prompt_lower or "date" in prompt_lower:
            return f"The current date and time is {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        
        elif "devops" in prompt_lower:
            return "DevOps is a practice that combines software development and IT operations. It emphasizes collaboration, automation, and continuous improvement throughout the software lifecycle."
        
        elif "ai" in prompt_lower or "artificial" in prompt_lower:
            return "AI (Artificial Intelligence) refers to the simulation of human intelligence in machines. This includes learning from experience, recognizing patterns, and understanding language."
        
        elif "distributed" in prompt_lower:
            return "Distributed systems are computing systems where components run on multiple machines. This provides scalability, fault tolerance, and better resource utilization."
        
        elif "infrastructure" in prompt_lower:
            return "Infrastructure refers to the foundational systems and resources that support applications. This includes servers, networking, storage, and security."
        
        else:
            # Default response
            return f"Thank you for the prompt: '{prompt}'. This is a mock AI response from the distributed inference platform. In production, this would use a real ML model."

async def main():
    """Main entry point for Model Worker"""
    from fastapi import FastAPI, HTTPException
    import uvicorn
    
    app = FastAPI(title="Model Worker")
    worker = ModelWorker()
    
    @app.get("/health")
    async def health():
        return {"status": "healthy", "service": "model-worker"}
    
    @app.post("/process")
    async def process(request: dict):
        try:
            result = await worker.process(request)
            return result
        except Exception as e:
            logger.error(f"Error: {str(e)}")
            raise HTTPException(status_code=500, detail=str(e))
    
    logger.info(f"Starting Model Worker on port {worker.service_port}")
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=worker.service_port,
        log_level="info"
    )

if __name__ == "__main__":
    asyncio.run(main())
