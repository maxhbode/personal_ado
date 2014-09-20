*! version 0.1.0 Matthew White 21dec2012
*! version 0.1.1 Max Bode 24dec2012

pr dropbox
	vers 9

	if c(os) != "Windows" {
		di as err "Stata for Windows required"
		ex 198
	}

	syntax, [Start Close PRogdir(str)]

	* Check strings.
	loc temp : subinstr loc progdir `"""' "", count(loc dq)
	if `dq' {
		di as err "option progdir() invalid"
		ex 198
	}

	* -start-, -close-
	if "`start'`close'" == "" ///
		loc start start
	else if "`start'" != "" & "`close'" != "" {
		di as err "options start and close are mutually exclusive"
		ex 198
	}

	* -progdir()-
	if "`progdir'" == "" {
		loc appdata : environment APPDATA
		if "`appdata'" == "" {
			di as err "environment variable APPDATA not set"
			ex 198
		}

		loc progdir `appdata'\Dropbox\bin
		conf f "`progdir'\Dropbox.exe"
	}
	else {
		conf f "`progdir'/Dropbox.exe"
		* Make sure the shell can understand `progdir': Stata is more permissive
		* about directory separators.
		nobreak {
			loc curdir = c(pwd)
			qui cd "`progdir'"
			loc progdir = c(pwd)
			qui cd "`curdir'"
		}
	}

	if "`start'" != "" ///
		winexec "`progdir'\Dropbox.exe"
	else ///
		sh taskkill /f /im Dropbox.exe
end
