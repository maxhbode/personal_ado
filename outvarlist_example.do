
*Display codebook of whole dataset
    sysuse auto
    notes turn: this is a note
    outvarlist *

*Display codebook and stats of whole dataset
    sysuse auto
    outvarlist *, su(N mean) in(N_0) report(name varlabel type)

*Display selected variables
    sysuse auto
    outvarlist make price rep78, su(N mean) in(N_0) report(name)

*Outsheet
    sysuse auto
    findname *, loc(varlist)
    outvarlist `varlist', file(C:/Users/mbode/Desktop/codebook) time dontlist
