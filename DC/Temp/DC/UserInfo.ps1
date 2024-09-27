# Prompt the user to enter the username
$username = Read-Host "Enter username"

# Run the net user command with the inputted username
net user $username /domain

pause
