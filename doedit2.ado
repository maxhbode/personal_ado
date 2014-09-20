*! version 1.6.0 Matthew White 25nov2012
pr doedit2
	vers 9

	syntax [anything(name=file id=filename equalok everything)], [Help]
	if inlist(substr(`"`file'"', 1, 1), `"""', "`") loc file `file'

	if `"`file'"' == "" ///
		doedit
	else {
		* "ext" for "extension"
		mata: st_local("ext", pathsuffix(`"`file'"'))

		if "`help'" == "" {
			if `"`ext'"' == "" {
				loc file "`file'.ado"
				loc ext .ado
			}
		}
		else if !inlist(`"`ext'"', ".sthlp", ".hlp", ".ihlp") {
			loc found 0

			foreach suffix in .sthlp .hlp .ihlp {
				loc newfile "`file'`suffix'"

				cap conf f `"`newfile'"'
				if !_rc ///
					loc found 1
				else {
					cap findfile `"`newfile'"'
					if !_rc ///
						loc found 1
				}

				if `found' {
					loc file "`newfile'"
					loc ext `suffix'
					continue, break
				}
			}

			if !`found' {
				loc file "`file'.sthlp"
				loc ext .sthlp
			}
		}

		cap conf f `"`file'"'
		if !_rc ///
			doedit `"`file'"'
		else {
			cap findfile `"`file'"'
			if !_rc ///
				doedit `"`=r(fn)'"'
			else {
				loc error 1

				if inlist(`"`ext'"', ".ado", ".sthlp", ".hlp", ".ihlp") {
					mata: st_local("basename", pathrmsuffix(pathbasename(`"`file'"')))
					cap unabcmd `basename'
					loc unab `r(cmd)'
					if !inlist("`unab'", "", `"`basename'"') {
						mata: st_local("newfile", strreverse(subinstr(strreverse(`"`file'"'), ///
							strreverse("`basename'`ext'"), strreverse("`unab'`ext'"), 1)))
						doedit2 `newfile'
						loc error 0
					}
					else if `"`ext'"' == ".ado" {
						cap which `basename'
						if !_rc which `basename'
					}
				}

				if `error' findfile `"`file'"'
			}
		}
	}
end
