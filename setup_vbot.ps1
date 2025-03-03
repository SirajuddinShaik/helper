# Define SSH directory
$SSH_DIR = "$env:USERPROFILE\.ssh"
$CONFIG_FILE = "$SSH_DIR\config"
$AWS_KEY = "$SSH_DIR\aws_rsa"

# Ensure SSH directory exists
if (!(Test-Path -Path $SSH_DIR)) {
    Write-Output "Creating SSH directory..."
    New-Item -ItemType Directory -Path $SSH_DIR -Force | Out-Null
}

# Download SSH key from Lightning AI
Write-Output "Downloading SSH key from AWS ssh..."
Invoke-WebRequest -Uri "https://lightning.ai/setup/ssh-windows?t=38619d9d-5449-48f6-85f9-a06256032110&s=01jed1dfsnb61kathq9qnt9d9g" -UseBasicParsing | Invoke-Expression

# Rename SSH keys from 'lightning_rsa' to 'aws_rsa'
Write-Output "Renaming SSH keys..."
if (Test-Path "$SSH_DIR\lightning_rsa") {
    Rename-Item -Path "$SSH_DIR\lightning_rsa" -NewName "aws_rsa" -Force
}
if (Test-Path "$SSH_DIR\lightning_rsa.pub") {
    Rename-Item -Path "$SSH_DIR\lightning_rsa.pub" -NewName "aws_rsa.pub" -Force
}

# Update SSH config
Write-Output "Updating SSH config..."
$configContent = @"
Host vbot_aws
    HostName ssh.lightning.ai
    User s_01jed1dfsnb61kathq9qnt9d9g
    IdentityFile $AWS_KEY
    IdentitiesOnly yes
    LocalForward 8000 localhost:8000
    ServerAliveInterval 15
    ServerAliveCountMax 4
    StrictHostKeyChecking no
    UserKnownHostsFile NUL
"@
$configContent | Set-Content -Path $CONFIG_FILE -Encoding UTF8

# Set correct permissions
Write-Output "Setting permissions..."
icacls $CONFIG_FILE /inheritance:r /grant:r "$env:USERNAME:(R,W)"
icacls $AWS_KEY /inheritance:r /grant:r "$env:USERNAME:(R,W)"
icacls "$AWS_KEY.pub" /inheritance:r /grant:r "$env:USERNAME:(R)"

Write-Output "✅ Setup complete! You can now connect using: ssh vbot_aws"
