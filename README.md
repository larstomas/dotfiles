# dotfiles
My dotfiles

## TODO
1. [LunarVim  Quick start](https://www.lunarvim.org/docs/quick-start)
2. Add .ssh
3. Add ~/.config/bat/themes
4. Use Brewfile and upgrade with homebrew
5. Run application installations with chezmoi
6. Gå igenom https://github.com/eieioxyz/dotfiles_macos
7. Vad ska vara var
   - $ZDOTDIR/.zshenv
   - $ZDOTDIR/.zshrc
   - $ZDOTDIR/.zlogin
   - $ZDOTDIR/.zlogout
8. Add iTerm2
9. Add gitignore
10. Add zdharma/history-search-multi-word, similar to mcfly
11. Install spaceship
   ```zsh
   # Customize Prompt(s)
   source "$DOTFILES/spaceship_shlvl.zsh"

   SPACESHIP_CHAR_SYMBOL="❯ "
   SPACESHIP_TIME_SHOW=true
   SPACESHIP_EXEC_TIME_ELAPSED=0
   SPACESHIP_BATTERY_SHOW=always
   SPACESHIP_EXIT_CODE_SHOW=true

   SPACESHIP_PROMPT_ORDER=(
   user          # Username section
   dir           # Current directory section
   host          # Hostname section
   git           # Git section (git_branch + git_status)
   package       # Package version
   # node          # Node.js section
   exec_time     # Execution time
   line_sep      # Line break
   shlvl         # Custom section from spaceship_shlvl.zsh
   # vi_mode       # Vi-mode indicator
   # jobs          # Background jobs indicator
   char          # Prompt character
   )

   SPACESHIP_RPROMPT_ORDER=(
   exit_code
   battery
   time
   )
   ```


## Managed with chezmoi
1. [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)


## Inspiration
1. [How To Setup Your Mac Terminal](https://www.josean.com/posts/terminal-setup)
