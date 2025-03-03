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

# Rename SSH key files
Write-Output "Renaming SSH keys..."
if (Test-Path "$SSH_DIR\lightning_rsa") {
    Rename-Item "$SSH_DIR\lightning_rsa" -NewName "aws_rsa"
}
if (Test-Path "$SSH_DIR\lightning_rsa.pub") {
    Rename-Item "$SSH_DIR\lightning_rsa.pub" -NewName "aws_rsa.pub"
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
