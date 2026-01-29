type (
	{{.upperStartCamelObject}}Model struct {
		DbEngin *gorm.DB{{if .withCache}}
		CacheEngin *redis.Client{{end}}
	}
	{{.upperStartCamelObject}} struct {
		{{.fields}}
	}
)
