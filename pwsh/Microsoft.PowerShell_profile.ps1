oh-my-posh init pwsh --config "$HOME/themes/spaceship.omp.json" | Invoke-Expression

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete