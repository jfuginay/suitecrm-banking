#!/bin/bash
# Start both the REST API server and WebSocket server

cd /app

# First, compile all COBOL programs
echo "=== Compiling COBOL Programs ==="
/app/compile-cobol.sh

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "ERROR: COBOL compilation failed!"
    echo "Please check the compilation logs above."
    exit 1
fi

echo ""
echo "=== Starting Node.js Servers ==="

# Start REST API server
echo "Starting REST API server on port 3000..."
node server.js &
API_PID=$!

# Give API server time to start
sleep 2

# Start WebSocket server
echo "Starting WebSocket server on port 8080..."
node websocket-server.js &
WS_PID=$!

# Wait for both processes
echo ""
echo "=== All Services Running ==="
echo "REST API Server: PID=$API_PID (http://localhost:3000)"
echo "WebSocket Server: PID=$WS_PID (ws://localhost:8080)"
echo "Press Ctrl+C to stop all services"
echo ""

wait $API_PID $WS_PID