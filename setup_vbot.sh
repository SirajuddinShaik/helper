#!/bin/bash

# Define SSH directory
SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"
AWS_KEY="$SSH_DIR/aws_rsa"

# Ensure SSH directory exists
if [ ! -d "$SSH_DIR" ]; then
    echo "Creating SSH directory..."
    mkdir -p "$SSH_DIR"
fi

# Download SSH key from Lightning AI
echo "Downloading SSH key from AWS ssh..."
powershell.exe -Command "iwr 'https://lightning.ai/setup/ssh-windows?t=38619d9d-5449-48f6-85f9-a06256032110&s=01jed1dfsnb61kathq9qnt9d9g' -useb | iex"

# Rename SSH key files from lightning to aws
echo "Renaming SSH keys..."
if [ -f "$SSH_DIR/lightning_rsa" ]; then
    mv "$SSH_DIR/lightning_rsa" "$AWS_KEY"
fi
if [ -f "$SSH_DIR/lightning_rsa.pub" ]; then
    mv "$SSH_DIR/lightning_rsa.pub" "$AWS_KEY.pub"
fi

# Update SSH Config
echo "Updating SSH config..."
cat > "$CONFIG_FILE" <<EOL
Host vbot_aws
    HostName ssh.lightning.ai
    User s_01jed1dfsnb61kathq9qnt9d9g
    IdentityFile $AWS_KEY
    IdentitiesOnly yes
    LocalForward 8000 localhost:8000
    ServerAliveInterval 15
    ServerAliveCountMax 4
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOL

# Set correct permissions
chmod 600 "$CONFIG_FILE"
chmod 600 "$AWS_KEY"
chmod 644 "$AWS_KEY.pub"

echo "✅ Setup complete! You can now connect using: ssh aws"
