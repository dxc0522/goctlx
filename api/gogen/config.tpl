package config

import {{.authImport}}

type Config struct {
	rest.RestConf
	{{.auth}}
	{{.jwtTrans}}
	AppMode     string `json:",env=APP_MODE,default=LOCAL"`
}
