package config

import {{.authImport}}

type Config struct {
	rest.RestConf
	AppMode     string `json:",env=APP_MODE,default=LOCAL"`
	{{.auth}}
	{{.jwtTrans}}
}
