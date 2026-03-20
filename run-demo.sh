#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

export ENV_FILE="$(pwd)/.env"

# Start API server in background
cd src
uvicorn main:app --host 0.0.0.0 --port 7100 &
API_PID=$!

# Wait for API to be ready
echo "Waiting for API server on port 7100..."
for i in $(seq 1 30); do
    if curl -s http://localhost:7100/docs > /dev/null 2>&1; then
        echo "API server ready."
        break
    fi
    sleep 1
done

# Start Gradio demo
cd ../demo
API_URL=http://localhost:7100/search python app.py &
DEMO_PID=$!

trap "kill $API_PID $DEMO_PID 2>/dev/null" EXIT

echo "API:   http://localhost:7100"
echo "Demo:  http://localhost:7860"

wait
