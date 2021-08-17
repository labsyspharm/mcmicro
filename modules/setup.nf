process O2ext {
    executor 'local'
    
    when: params.O2ext
    '''
    mkdir -p $HOME/.mcmicro
    ln -s /n/groups/lsp/mcmicro/singularity/* $HOME/.mcmicro
    '''
}

workflow setup {
    O2ext()
}
