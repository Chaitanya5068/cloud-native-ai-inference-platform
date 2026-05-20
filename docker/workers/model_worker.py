import asyncio
import logging
import os
from datetime import datetime

from fastapi import FastAPI, HTTPException
import uvicorn

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Model Worker")


class ModelWorker:
    """Model Worker - Final step in the processing pipeline"""

    def __init__(self):
        self.name = "model-worker"
        self.service_port = int(os.getenv("MODEL_WORKER_PORT", 8003))
        self.model_name = "mock-ai-model-v1"

    async def process(self, data: dict) -> dict:
        try:
            prompt = data.get("prompt", "")
            model = data.get("model", "default")

            logger.info(
                f"[{self.name}] Processing final step for: {prompt[:50]}..."
            )

            # Simulate model processing
            await asyncio.sleep(0.5)

            response = self._generate_mock_response(prompt)

            return {
                "response": response,
                "model": model,
                "final_model": self.model_name,
                "timestamp": datetime.now().isoformat(),
                "status": "success",
                "pipeline": [
                    "python",
                    "typescript",
                    "model"
                ]
            }

        except Exception as e:
            logger.error(f"[{self.name}] Error: {str(e)}")
            raise

    def _generate_mock_response(self, prompt: str) -> str:
        prompt_lower = prompt.lower()

        if "hello" in prompt_lower or "hi" in prompt_lower:
            return "Hello! I'm an AI inference service."

        elif "devops" in prompt_lower:
            return (
                "DevOps combines development and operations "
                "through automation and collaboration."
            )

        elif "ai" in prompt_lower:
            return (
                "AI refers to systems capable of performing "
                "tasks that normally require human intelligence."
            )

        elif "distributed" in prompt_lower:
            return (
                "Distributed systems run workloads across "
                "multiple interconnected machines."
            )

        else:
            return (
                f"Mock AI response for prompt: '{prompt}'. "
                "Generated from distributed inference pipeline."
            )


worker = ModelWorker()


@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "service": "model-worker"
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
    logger.info("Starting Model Worker on port 8003")

    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8003
    )