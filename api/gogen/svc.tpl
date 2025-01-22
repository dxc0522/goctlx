package svc

import (
	{{.configImport}}
)

type ServiceContext struct {
	Config {{.config}}
	{{.middleware}}
}

func NewServiceContext(c {{.config}}) (*ServiceContext, error) {
	return &ServiceContext{
		Config: c,
		{{.middlewareAssignment}}
	}, nil
}
