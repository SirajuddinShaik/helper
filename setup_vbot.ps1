# Define paths
$SSH_DIR = "$HOME\.ssh"
$CONFIG_FILE = "$SSH_DIR\config"
$AWS_KEY = "$SSH_DIR\aws_rsa"

# Ensure SSH directory exists
if (!(Test-Path -Path $SSH_DIR)) {
    Write-Output "Creating SSH directory..."
    New-Item -ItemType Directory -Path $SSH_DIR -Force | Out-Null
}

# Download SSH key
Write-Output "Downloading SSH key..."
iwr "https://lightning.ai/setup/ssh-windows?t=38619d9d-5449-48f6-85f9-a06256032110&s=01jed1dfsnb61kathq9qnt9d9g" -useb | iex

# Safely rename SSH key files
Write-Output "Renaming SSH keys..."

# Handle private key
if (Test-Path "$SSH_DIR\lightning_rsa") {
    if (Test-Path "$AWS_KEY") {
        Write-Output "Removing existing aws_rsa file..."
        Remove-Item "$AWS_KEY" -Force
    }
    Move-Item "$SSH_DIR\lightning_rsa" "$AWS_KEY" -Force
}

# Handle public key
if (Test-Path "$SSH_DIR\lightning_rsa.pub") {
    if (Test-Path "$AWS_KEY.pub") {
        Write-Output "Removing existing aws_rsa.pub file..."
        Remove-Item "$AWS_KEY.pub" -Force
    }
    Move-Item "$SSH_DIR\lightning_rsa.pub" "$AWS_KEY.pub" -Force
}

# Update SSH Config
Write-Output "Updating SSH config..."
@"
Host vbot_aws
    HostName aws-server.com
    User my_aws_user
    IdentityFile $AWS_KEY
    IdentitiesOnly yes
    LocalForward 8000 localhost:8000
    ServerAliveInterval 15
    ServerAliveCountMax 4
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
"@ | Set-Content -Path $CONFIG_FILE

# Set correct permissions
Write-Output "Setting permissions..."
icacls $CONFIG_FILE /inheritance:r /grant:r "$env:USERNAME:F" | Out-Null
icacls $AWS_KEY /inheritance:r /grant:r "$env:USERNAME:F" | Out-Null
icacls "$AWS_KEY.pub" /inheritance:r /grant:r "$env:USERNAME:R" | Out-Null

Write-Output "✅ Setup complete! You can now connect using: ssh vbot_aws"
