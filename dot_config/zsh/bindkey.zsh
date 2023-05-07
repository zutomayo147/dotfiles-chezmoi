# Emacs 風のキーバインドを使用 (他に Vim 風もある)
bindkey -e

function ghq-fzf() {
  local src="$(ghq list | fzf)"
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^g' ghq-fzf

# Shift+Tab で前の選択肢へ移動
bindkey '^[[Z' reverse-menu-complete
bindkey -s '^O' 'ranger-cd\n'

bindkey '^f' forward-word
# bindkey '^b' fbr
# bindkey '^[[F' forward-char
bindkey "^[[3~" delete-char #Del
bindkey "^[[1~" beginning-of-line #Home
bindkey "^[[4~" end-of-line # End

# "^S" history-incremental-search-forward
bindkey -r "^S"