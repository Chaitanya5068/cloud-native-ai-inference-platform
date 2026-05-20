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

# Request model
class InferenceRequest(BaseModel):
    prompt: str
    model: Optional[str] = "default"

# Response model
class InferenceResponse(BaseModel):
    response: str
    status: str = "success"
    model: Optional[str] = None


@app.get("/health")
async def health_check():

    return {
        "status": "healthy",
        "service": "api-gateway",
        "version": "1.0.0"
    }


@app.post("/infer", response_model=InferenceResponse)
async def infer(request: InferenceRequest):

    try:
        # Worker EC2 private IP
        worker_url = os.getenv(
            "WORKER_SERVICE_URL",
            "http://10.0.2.23:8001"
        )

        logger.info(f"Forwarding request to worker: {worker_url}")

        async with httpx.AsyncClient(timeout=30.0) as client:

            response = await client.post(
                f"{worker_url}/process",
                json={
                    "prompt": request.prompt,
                    "model": request.model
                }
            )

            response.raise_for_status()

            worker_response = response.json()

            return InferenceResponse(
                response=worker_response.get(
                    "response",
                    "No response from worker"
                ),
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

        logger.error(str(e))

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


@app.get("/")
async def root():

    return {
        "service": "Distributed AI Inference API Gateway",
        "version": "1.0.0",
        "docs": "/docs"
    }


if __name__ == "__main__":

    import uvicorn

    logger.info("Starting API Gateway on port 8000")

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000
    )