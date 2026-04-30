// Code scaffolded by goctl. Safe to edit.
// goctl {{.version}}

package config

import (
	"github.com/zeromicro/go-zero/rest"
	{{.authImport}}
)

type Config struct {
	rest.RestConf
	AppMode string `json:",env=APP_MODE,default=LOCAL"`
	{{.auth}}
	{{.jwtTrans}}
}
