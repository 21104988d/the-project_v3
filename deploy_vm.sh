#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Replace with your GitHub repository URL
REPO_URL="YOUR_GITHUB_REPO_URL_HERE"
PROJECT_DIR="the_project_v3" # Name of the cloned directory
SERVER_DIR="$PROJECT_DIR/server"

# --- System Setup ---
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

echo "Installing Python3, pip, and git..."
sudo apt install -y python3 python3-pip git

echo "Installing and starting Redis server..."
sudo apt install -y redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server

# --- Application Deployment ---
echo "Cloning the repository..."
# Check if the directory already exists to avoid errors on re-run
if [ -d "$PROJECT_DIR" ]; then
    echo "Repository directory already exists. Pulling latest changes..."
    cd "$PROJECT_DIR"
    git pull
else
    git clone "$REPO_URL"
    cd "$PROJECT_DIR"
fi

echo "Navigating to server directory and installing Python dependencies..."
cd "$SERVER_DIR"
pip install -r requirements.txt

# --- Environment Variables ---
echo "IMPORTANT: Ensure your .env file is in the project root ($PROJECT_DIR/)."
echo "If it's not there, the server will not start correctly."
echo "You need to manually create/transfer it securely."

# --- Run the Server ---
echo "Starting the FastAPI server using nohup..."
# Use nohup to run in background and redirect output to a log file
# You might want to use a process manager like systemd for production
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &

echo "Server deployment script finished."
echo "You can check the server logs at $SERVER_DIR/server.log"
echo "Ensure port 8000 is open in your VM's firewall rules."
echo "Access your server via your VM's external IP address on port 8000."
