nextflow.enable.dsl=1

process O2ext {
    executor 'local'
    
    '''
    rm -rf $HOME/.mcmicro
    mkdir -p $HOME/.mcmicro
    ln -s /n/groups/lsp/mcmicro/singularity/* $HOME/.mcmicro
    '''
}
