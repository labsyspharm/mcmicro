process O2ext {
    when: params.O2ext
    '''
    rm -rf $HOME/.mcmicro
    '''
}

workflow cleanup {
    O2ext()
}
