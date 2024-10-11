Do {
    # Perform the AD account locked-out search
    Search-ADAccount -LockedOut

    # Pause for user to see the results
    pause

    # Ask user if they want to restart or close the script
    $response = Read-Host "Would you like to [R]estart or [C]lose the script?"

    # Continue the loop if the user chooses 'R', exit if 'C'
} While ($response -eq 'R' -or $response -eq 'r')

Write-Host "Closing the script..."
