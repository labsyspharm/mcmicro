process O2ext {
    executor 'local'
    
    when: params.O2ext
    '''
    rm -rf $HOME/.mcmicro
    '''
}

workflow cleanup {
    O2ext()
}
