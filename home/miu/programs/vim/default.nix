{pkgs, ...}:

{
  programs.vim = {
    enable = true;
    defaultEditor = false;
    extraConfig = ''
      set encoding=utf-8
      scriptencoding utf-8
      set noswapfile
      set nobackup
      "set backup
      "set backupdir=~/.vimbk/
      "set backupext=.bk
      
      set number
      set showmatch
      set hlsearch
      
      nnoremap j gj
      nnoremap k gk
      
      inoremap ＊ *
      inoremap ＝ =
      inoremap （ (
      inoremap ） )
      
      syntax enable
      
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set autoindent
    '';
  };
}
