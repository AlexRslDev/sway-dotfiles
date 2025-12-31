export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

plugins=(
    git 
    zsh-autosuggestions 
    zsh-syntax-highlighting
)

export PATH="$HOME/.local/bin:$PATH"
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh-themes/just_coffy.omp.json)"
