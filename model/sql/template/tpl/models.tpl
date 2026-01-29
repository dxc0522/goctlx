package {{.pkg}}

import (
	{{if .withCache}}"github.com/redis/go-redis/v9"
	{{end}}"gorm.io/gorm"
)

// Models 包含所有模型的结构体
type Models struct {
	DbEngin *gorm.DB{{if .withCache}}
	CacheEngin *redis.Client{{end}}
{{range .tables}}	{{.upperStartCamelObject}} *{{.upperStartCamelObject}}Model{{end}}
}

// NewModels 创建所有模型实例
func NewModels(db *gorm.DB{{if .withCache}}, rd *redis.Client{{end}}) *Models {
	return &Models{
        DbEngin: db,{{if .withCache}}
        CacheEngin: rd,{{end}}
{{range .tables}}		{{.upperStartCamelObject}}: &{{.upperStartCamelObject}}Model{
			DbEngin: db,{{if .withCache}}
            CacheEngin: rd,{{end}}
		},{{end}}
	}
}
