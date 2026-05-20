from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx
import logging
from typing import Optional
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="AI Inference API Gateway",
    description="API Gateway for distributed AI inference",
    version="1.0.0"
)

# Request and Response models
class InferenceRequest(BaseModel):
    """Request model for inference endpoint"""
    prompt: str
    model: Optional[str] = "default"

class InferenceResponse(BaseModel):
    """Response model for inference endpoint"""
    response: str
    status: str = "success"
    model: Optional[str] = None

# Health check
@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "api-gateway",
        "version": "1.0.0"
    }

# Main inference endpoint
@app.post("/infer", response_model=InferenceResponse, tags=["Inference"])
async def infer(request: InferenceRequest):
    """
    Forward inference request to internal worker service
    
    Args:
        request: InferenceRequest containing the prompt
        
    Returns:
        InferenceResponse with the generated response
        
    Raises:
        HTTPException: If worker service is unavailable
    """
    try:
        # Get worker service URL from environment variable
        worker_url = os.getenv("WORKER_SERVICE_URL", "http://localhost:8001")
        
        logger.info(f"Forwarding request to worker: {worker_url}")
        logger.info(f"Prompt: {request.prompt}")
        
        # Forward request to worker service
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                f"{worker_url}/process",
                json={"prompt": request.prompt, "model": request.model},
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code != 200:
                logger.error(f"Worker service error: {response.status_code}")
                raise HTTPException(
                    status_code=502,
                    detail=f"Worker service error: {response.status_code}"
                )
            
            worker_response = response.json()
            
            return InferenceResponse(
                response=worker_response.get("response", "No response from worker"),
                status="success",
                model=request.model
            )
            
    except httpx.TimeoutException:
        logger.error("Worker service timeout")
        raise HTTPException(
            status_code=504,
            detail="Worker service timeout"
        )
    except httpx.ConnectError:
        logger.error("Cannot connect to worker service")
        raise HTTPException(
            status_code=502,
            detail="Cannot connect to worker service"
        )
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Internal server error: {str(e)}"
        )

# Root endpoint
@app.get("/", tags=["Root"])
async def root():
    """Root endpoint with API information"""
    return {
        "service": "Distributed AI Inference API Gateway",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "inference": "/infer",
            "docs": "/docs",
            "redoc": "/redoc"
        }
    }

if __name__ == "__main__":
    import uvicorn
    
    # Server configuration
    host = os.getenv("API_HOST", "0.0.0.0")
    port = int(os.getenv("API_PORT", 8000))
    
    logger.info(f"Starting API Gateway on {host}:{port}")
    
    uvicorn.run(
        app,
        host=host,
        port=port,
        log_level="info"
    )
