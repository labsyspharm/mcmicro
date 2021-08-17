process O2ext {
    executor 'local'
    
    '''
    mkdir -p $HOME/.mcmicro
    ln -s /n/groups/lsp/mcmicro/singularity/* $HOME/.mcmicro
    '''
}
