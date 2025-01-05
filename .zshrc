# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  starship
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-interactive-cd
  aliases
  autoenv
  docker
  docker-compose
  gh
  httpie
  kitty
  npm
  nvm 
  python
  rsync
  ssh
  sudo
  vi-mode
  yarn
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
export NVM_DIR="$HOME/.nvm"
export DHIS2_HOME="$HOME/.config/dhis2_home"
export OLLAMA_API_BASE="http://127.0.0.1:11434"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
  export VISUAL="vim"
else
  export EDITOR='nvim'
  export VISUAL="nvim"
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias v='nvim'
alias startopenvpn='sudo openvpn --config ~/.openvpn/privado.ovpn --daemon'
alias stopopenvpn='sudo killall openvpn'
alias dobbysync='ssh dobby "cd homeserver; ./sync_dobby.sh;"'
alias nuke-nodemodules="find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +"
alias docker-cleanup='docker stop $(docker ps -a -q) && docker system prune --all --volumes --force'
alias docker-up-dhis2="cd ~/Apps/dhis2-core && docker compose up -d"
alias docker-logs-dhis2="cd ~/Apps/dhis2-core && docker compose logs web --follow"
alias ctop="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest"
alias dive="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest"
alias convert_mkv_to_mov='for i in *.mkv; do ffmpeg -i "$i" -c:v prores_ks -profile:v 3 -c:a pcm_s24le "${i%.*}.mov"; done'
alias custom_build='sed -i '' "s/\"version\": \".*\"/\"version\": \"999.9.9-$(date '+%Y-%m-%dT%H-%M-%S')\"/" package.json && yarn build'
alias saw='yarn install --force && rm -rf node_modules/@dhis2/analytics/node_modules && npx chokidar-cli "../analytics/build/**/*" -c "rm -rf node_modules/@dhis2/analytics/build && cp -R ../analytics/build/ node_modules/@dhis2/analytics/build" --initial'
alias raw='rm -rf node_modules/@dhis2/analytics/build && cp -R ../analytics/build/ node_modules/@dhis2/analytics/build'
alias sawmap='yarn install --force && rm -rf node_modules/@dhis2/maps-gl/node_modules && npx chokidar-cli "../maps-gl/build/**/*" -c "rm -rf node_modules/@dhis2/maps-gl/build && cp -R ../maps-gl/build/ node_modules/@dhis2/maps-gl/build" --initial'
alias rawmap='rm -rf node_modules/@dhis2/maps-gl/build && cp -R ../maps-gl/build/ node_modules/@dhis2/maps-gl/build'

# nvm setup
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
# end nvm setup

# pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# end pyenv setup

eval "$(direnv hook zsh)"


source /opt/homebrew/opt/autoenv/activate.sh
