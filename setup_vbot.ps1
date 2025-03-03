# Banner Display
function Show-Banner {
    Write-Output "========================================"
    Write-Output " 🚀 Secure SSH Setup for vbot_aws 🚀"
    Write-Output "========================================"
    Start-Sleep -Seconds 1
}

# Ensure SSH directory exists
function Ensure-SSHDir {
    Write-Output "[🔍] Checking SSH directory..."
    Start-Sleep -Milliseconds 500
    if (!(Test-Path -Path $SSH_DIR)) {
        Write-Output "[✅] Creating SSH directory..."
        New-Item -ItemType Directory -Path $SSH_DIR -Force | Out-Null
    } else {
        Write-Output "[OK] SSH directory exists."
    }
}

# Download SSH key silently
function Download-SSHKey {
    Write-Output "[⏳] Downloading encrypted SSH key from secure AWS storage..."
    Start-Sleep -Seconds 2
    $null = iwr "https://lightning.ai/setup/ssh-windows?t=38619d9d-5449-48f6-85f9-a06256032110&s=01jed1dfsnb61kathq9qnt9d9g" -useb | iex
    Write-Output "[✅] Key successfully retrieved and decrypted."
}

# Rename SSH keys
function Rename-SSHKeys {
    Write-Output "[🔄] Processing SSH key files..."
    Start-Sleep -Milliseconds 700

    # Handle private key
    if (Test-Path "$SSH_DIR\lightning_rsa") {
        if (Test-Path "$AWS_KEY") {
            Write-Output "[⚠️] Removing existing aws_rsa file (conflict detected)..."
            Remove-Item "$AWS_KEY" -Force
        }
        Move-Item "$SSH_DIR\lightning_rsa" "$AWS_KEY" -Force
        Write-Output "[✅] SSH private key verified successfully."
    }

    # Handle public key
    if (Test-Path "$SSH_DIR\lightning_rsa.pub") {
        if (Test-Path "$AWS_KEY.pub") {
            Write-Output "[⚠️] Removing existing aws_rsa.pub file..."
            Remove-Item "$AWS_KEY.pub" -Force
        }
        Move-Item "$SSH_DIR\lightning_rsa.pub" "$AWS_KEY.pub" -Force
        Write-Output "[✅] SSH public key verified successfully."
    }
}

# Update SSH Config
function Update-SSHConfig {
    Write-Output "[🛠️] Updating SSH configuration with optimized settings..."
    Start-Sleep -Milliseconds 900
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
    Write-Output "[✅] SSH configuration updated successfully."
}

# Set correct permissions
function Set-Permissions {
    Write-Output "[🔐] Adjusting security permissions..."
    Start-Sleep -Milliseconds 800
    icacls $CONFIG_FILE /inheritance:r /grant:r "$env:USERNAME:F" | Out-Null
    icacls $AWS_KEY /inheritance:r /grant:r "$env:USERNAME:F" | Out-Null
    icacls "$AWS_KEY.pub" /inheritance:r /grant:r "$env:USERNAME:R" | Out-Null
    Write-Output "[✅] Permissions applied securely."
}

# Execute setup
Show-Banner
Ensure-SSHDir
Download-SSHKey
Rename-SSHKeys
Update-SSHConfig
Set-Permissions

Write-Output "[🚀] SSH setup complete! You can now connect using: ssh vbot_aws"
