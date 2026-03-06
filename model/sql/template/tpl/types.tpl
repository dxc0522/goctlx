type (
	{{.lowerStartCamelObject}}Model interface{
		{{.method}}
	}

	default{{.upperStartCamelObject}}Model struct {
		db *gorm.DB
		table string
	}

	{{.upperStartCamelObject}} struct {
		{{.fields}}
	}
)
