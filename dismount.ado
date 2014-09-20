*! dismount, MaxBode

* Puropose dismounts all truecrypt volumes in memory

cap: program drop dismount


program dismount

foreach X in `0' {
	cap: etruecrypt, dismount drive(`X')
}

end 
