so ${DOTFILES}/nvim/rc/options.vim
so ${DOTFILES}/nvim/rc/maps.vim
so ${DOTFILES}/nvim/rc/plugins.vim
so ${DOTFILES}/nvim/rc/providers.vim

" themes should be first than plugins
" plugins should be choose their colors if needed 
" and should not be overriden by the themes
so ${DOTFILES}/nvim/themes/onedark.vim
so ${DOTFILES}/nvim/themes/airline.vim

so ${DOTFILES}/nvim/plugins/coc.vim
so ${DOTFILES}/nvim/plugins/floaterm.vim
" so ${DOTFILES}/nvim/plugins/fugitive.vim
so ${DOTFILES}/nvim/plugins/fzf.vim
so ${DOTFILES}/nvim/plugins/nerdtree.vim
so ${DOTFILES}/nvim/plugins/replacer.vim

