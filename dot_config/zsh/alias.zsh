alias mkdir="mkdir -p"
alias quit='exit'
# alias rezsh='exec zsh'

if builtin command -v exa > /dev/null 2>&1; then
  alias e='exa --icons'
  alias ea='exa -a --icons'
  alias el='exa -l --icons'
  alias ela='exa -aal --icons'
  alias et='exa -T -L 3 --icons -I "node_modules|.git|.cache|.venv|__pycache__"'
  alias eta='exa -a -T -L 3 --icons -I "node_modules|.git|.cache|.venv|__pycache__"'
fi

# alias rm='rm -iv'
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -v'

# ls
alias l='ls -F --color=auto -1'
alias ls='ls -F --color=auto'
alias ll='ls -lh'
alias la='ls -a'
alias lla='ll -a'
alias ltr='ll -tr'
alias l.='ls -d .[a-zA-Z]*'
# colorize
# alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# My
alias r='ranger-cd'
alias lg='lazygit'
alias ld='lazydocker'
alias S='shutdown -h now'
alias R='systemctl reboot -i'
alias T='sudo timeshift-launcher'
alias makepkg='makepkg -cis'
alias mkd='mkdir'
alias n='nvim'
# alias n='~/nvim.appimage'
alias p='python'
alias make='colormake'
alias un='unar'
##tmux
alias t='tmux'
alias ta='tmux a'
alias tk='tmux kill-server'
alias tl='tmux list-sessions'
alias tks='tmux kill-session'
alias tmux-copy='tmux save-buffer - | pbcopy'
alias unzipS='unzip -Ocp932'  ###shift>utf-8
# alias pa="pipenv shell"
alias pa="poetry shell"
alias bash="bash --norc"
alias yayyyyyyyyyyyyy="yes | yay -Syu --overwrite \"/usr/lib/node_modules/npm/node_modules/*\" ; paccache -r; paccache -ruk0"
# alias yayy="yes | yay -Syu ; paccache -r; paccache -ruk0"
alias ls="exa"
alias tree="exa"
alias cat="bat"
alias wc="tokei"

alias up-d="docker-compose up -d"
alias down="docker-compose down"
# alias diff="colordiff"


alias visudo='env EDITOR=nvim sudo -E visudo'
##git
alias G='git add . && git commit -a --allow-empty-message -m "" && git push'
alias gs='git switch'


# alias diff='diff --color=always -bwB'
# alias less='less -RS --use-color'
alias grep='grep --color=always'
alias fa='sudo pacman-mirrors --fasttrack && sudo pacman -Syy'
alias rm='rmtrash'
# alias rmdir='rmdirtrash'

# chmod
alias 644='chmod 644'
alias 755='chmod 755'
alias 777='chmod 777'

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Translate-shell
alias ja='trans :ja'
alias en='trans :en'

# Change directory to Parent Dir
alias ..='cd ..'
alias ...='cd ../..'

# Clipboard
alias pbcopy='xsel --input --clipboard'
alias pbpaste='xsel --output --clipboard'

# move prompt to bottom of terminal
alias move-buttom='tput cup $(($(stty size|cut -d " " -f 1))) 0 && tput ed'

(command -v batcat > /dev/null 2>&1) && alias bat='batcat'

alias open='xdg-open'

# g++
alias g+='g++ -std=c++17 -g2 -Og -DLOCAL_DEBUG -Wall -Wextra -Wshadow -Wconversion -fsanitize=address,undefined -ftrapv'

alias vim='vim -X'

# nim
alias nimr='nim cpp --hints:off --run'
alias nimfr='nim cpp -d:release --opt:speed --multimethods:on --warning[SmallLshouldNotBeUsed]:off --hints:off --run'