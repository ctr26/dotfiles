# dotfiles

Install chezmoi 

    sh -c "$(curl -fsLS get.chezmoi.io)"


Edit the [chezmoi config toml](https://www.chezmoi.io/reference/configuration-file/) and add name and email

    chezmoi edit-config
    
    
Install dotfiles

    chezmoi init --apply ctr26/dotfiles
