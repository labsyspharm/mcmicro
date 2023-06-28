process O2ext {
    executor 'local'
    
    '''
    rm -rfv $HOME/.mcmicro
    mkdir -pv $HOME/.mcmicro
    ln -sv /n/groups/lsp/mcmicro/singularity/* $HOME/.mcmicro
    '''
}

workflow {
    O2ext()
}
