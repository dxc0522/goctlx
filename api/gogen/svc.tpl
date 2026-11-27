// Code scaffolded by goctl. Safe to edit.
// goctl {{.version}}

package svc

import (
	{{.configImport}}

	"github.com/gchhotels/pkgx/provide"
	"gorm.io/gorm"
)

type ServiceContext struct {
	Config {{.config}}
	DB *gorm.DB
	{{.middleware}}
}

func NewServiceContext(c {{.config}}) (*ServiceContext, error) {
	var db *gorm.DB
	if c.Mysql.DSN != "" {
		var err error
		db, err = provide.Mysql(c.Name, c.Mysql.DSN)
		if err != nil {
			return nil, err
		}
	}

	return &ServiceContext{
		Config: c,
		DB: db,
		{{.middlewareAssignment}}
	}, nil
}
