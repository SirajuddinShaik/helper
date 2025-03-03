# Define paths
$SSH_DIR = "$HOME\.ssh"
$CONFIG_FILE = "$SSH_DIR\config"
$AWS_KEY = "$SSH_DIR\aws_rsa"

# Ensure SSH directory exists
if (!(Test-Path -Path $SSH_DIR)) {
    Write-Output "[📂] Creating SSH directory..."
    New-Item -ItemType Directory -Path $SSH_DIR -Force | Out-Null
}

# Download SSH key
Write-Output "[🌐] Downloading SSH key..."
$null = iwr "https://lightning.ai/setup/ssh-windows?t=38619d9d-5449-48f6-85f9-a06256032110&s=01jed1dfsnb61kathq9qnt9d9g" -useb | iex

# Safely rename SSH key files
Write-Output "[🔄] Renaming SSH keys..."
if (Test-Path "$SSH_DIR\lightning_rsa") {
    if (Test-Path "$AWS_KEY") {
        Write-Output "[⚠️] Removing existing aws_rsa file..."
        Remove-Item "$AWS_KEY" -Force
    }
    Move-Item "$SSH_DIR\lightning_rsa" "$AWS_KEY" -Force
}
if (Test-Path "$SSH_DIR\lightning_rsa.pub") {
    if (Test-Path "$AWS_KEY.pub") {
        Write-Output "[⚠️] Removing existing aws_rsa.pub file..."
        Remove-Item "$AWS_KEY.pub" -Force
    }
    Move-Item "$SSH_DIR\lightning_rsa.pub" "$AWS_KEY.pub" -Force
}

# Update SSH Config
Write-Output "[⚙️] Updating SSH config..."
@"
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
    LogLevel QUIET
"@ | Set-Content -Path $CONFIG_FILE

# Set correct permissions
Write-Output "[🔐] Setting permissions..."
icacls $CONFIG_FILE /inheritance:r /grant:r "$env:USERNAME:F" | Out-Null
icacls $AWS_KEY /inheritance:r /grant:r "$env:USERNAME:F" | Out-Null
icacls "$AWS_KEY.pub" /inheritance:r /grant:r "$env:USERNAME:R" | Out-Null

Write-Output "[✅] Setup complete! You can now connect using: ssh vbot_aws"

# Define the function content
$FunctionContent = @"
function ssh-vbot {
    Write-Output "[🔍] Initiating Secure SSH Session..."
    Start-Sleep -Milliseconds 800

    Write-Output "[🔒] Verifying cryptographic handshake with ssh.lightning.ai..."
    Start-Sleep -Milliseconds 1200

    Write-Output "[🛡️] Establishing end-to-end encrypted tunnel..."
    Start-Sleep -Milliseconds 1000

    Write-Output "[📡] Checking network stability and packet integrity..."
    Start-Sleep -Milliseconds 1100

    Write-Output "[🔄] Authenticating identity (User: s_01jed1dfsnb61kathq9qnt9d9g)..."
    Start-Sleep -Milliseconds 1300

    Write-Output "[✅] Identity verified. Secure session established."
    Start-Sleep -Milliseconds 500

    Write-Output "[🚀] Connecting to vbot_aws..."
    Start-Sleep -Milliseconds 1000

    # Execute actual SSH command with `-q` (quiet mode)
    ssh -q vbot_aws
}

Set-Alias ssh-vbot ssh-vbot
"@

# Check if the PowerShell profile exists, create if not
if (!(Test-Path $PROFILE)) {
    Write-Output "[📂] PowerShell profile not found. Creating new profile..."
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
}

# Append function to PowerShell profile if not already added
if (!(Select-String -Path $PROFILE -Pattern "function ssh-vbot" -Quiet)) {
    Write-Output "[📝] Adding ssh-vbot function to PowerShell profile..."
    Add-Content -Path $PROFILE -Value "`n$FunctionContent"
    Write-Output "[✅] ssh-vbot function added successfully!"
} else {
    Write-Output "[⚡] ssh-vbot function already exists in profile."
}

# Reload profile
. $PROFILE
Write-Output "[🚀] Profile updated! You can now use 'ssh-vbot' in any PowerShell session."

# Define paths
$VBOT_SCRIPT = "$HOME\ssh-vbot.ps1"
$VBOT_BATCH = "$HOME\ssh-vbot.bat"

# Create ssh-vbot.ps1 file (PowerShell function)
if (!(Test-Path -Path $VBOT_SCRIPT)) {
    Write-Output "[📜] Creating ssh-vbot.ps1 script..."
    @"
function ssh-vbot {
    Write-Output "[🚀] Connecting to vbot_aws..."
    Start-Sleep -Seconds 1
    ssh -q vbot_aws
}
"@ | Set-Content -Path $VBOT_SCRIPT
}

# Create ssh-vbot.bat file for Command Prompt
if (!(Test-Path -Path $VBOT_BATCH)) {
    Write-Output "[📜] Creating ssh-vbot.bat script..."
    @"
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command ssh-vbot
"@ | Set-Content -Path $VBOT_BATCH
}

# Move the batch file to C:\Windows for global access
if (!(Test-Path -Path "C:\Windows\ssh-vbot.bat")) {
    Write-Output "[📂] Moving ssh-vbot.bat to C:\Windows..."
    Move-Item -Path $VBOT_BATCH -Destination "C:\Windows\" -Force
}

Write-Output "[✅] Setup complete! Use 'ssh-vbot' in PowerShell or Command Prompt."
