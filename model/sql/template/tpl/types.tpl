type (
	{{.lowerStartCamelObject}}Model interface{
		{{.method}}
	}

	default{{.upperStartCamelObject}}Model struct {
		gormDB *gorm.DB
		{{if .withCache}}cacheClient cache.Cache{{end}}
		table string
	}

	{{.upperStartCamelObject}} struct {
{{.fields}}
	}
)
