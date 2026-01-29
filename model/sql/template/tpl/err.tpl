package {{.pkg}}

import (
	{{if .withCache}}"github.com/redis/go-redis/v9"{{end}}
	"gorm.io/gorm"
)

type (
	DefaultModel struct {
		DbEngin    *gorm.DB{{if .withCache}}
		CacheEngin *redis.Client{{end}}
	}
)

func NewDefaultModel(db *gorm.DB,{{if .withCache}} rd *redis.Client,{{end}}) *DefaultModel {
	return &DefaultModel{
		DbEngin:    db,{{if .withCache}}
		CacheEngin: rd,{{end}}
	}
}
