func new{{.upperStartCamelObject}}Model(db *gorm.DB{{if .withCache}}, c cache.CacheConf, opts ...cache.Option{{end}}) *default{{.upperStartCamelObject}}Model {
	return &default{{.upperStartCamelObject}}Model{
		db:    db,
		table: {{.table}},
	}
}

