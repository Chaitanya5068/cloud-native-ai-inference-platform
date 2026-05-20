import httpx
import logging
import os
from typing import Dict, Any

from fastapi import FastAPI, HTTPException
import uvicorn

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Python Worker")


class PythonWorker:
    """Python Worker - First step in the processing pipeline"""

    def __init__(self):
        self.name = "python-worker"
        self.service_port = int(os.getenv("PYTHON_WORKER_PORT", 8001))
        self.ts_worker_url = os.getenv(
            "TS_WORKER_URL",
            "http://ts-worker:8002"
        )

    async def process(self, data: Dict[str, Any]) -> Dict[str, Any]:
        try:
            prompt = data.get("prompt", "")
            model = data.get("model", "default")

            logger.info(f"[{self.name}] Processing prompt: {prompt[:50]}...")

            if not prompt:
                raise ValueError("Prompt cannot be empty")

            processed_data = {
                "prompt": prompt,
                "model": model,
                "step": "python"
            }

            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.post(
                    f"{self.ts_worker_url}/process",
                    json=processed_data
                )

                response.raise_for_status()

                return response.json()

        except Exception as e:
            logger.error(f"[{self.name}] Error: {str(e)}")
            raise


worker = PythonWorker()


@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "service": "python-worker"
    }


@app.post("/process")
async def process(request: dict):
    try:
        result = await worker.process(request)
        return result

    except Exception as e:
        logger.error(str(e))
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    logger.info("Starting Python Worker on port 8001")

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8001
    )