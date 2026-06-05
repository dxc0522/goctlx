func new{{.upperStartCamelObject}}Model(gormDB *gorm.DB{{if .withCache}}, c cache.CacheConf, opts ...cache.Option{{end}}) *default{{.upperStartCamelObject}}Model {
	{{if .withCache}}var cacheClient cache.Cache
	if len(c) > 0 {
		cacheClient = cache.New(c, syncx.NewSingleFlight(), cache.NewStat("sqlc"), sql.ErrNoRows, opts...)
	}
	{{end}}return &default{{.upperStartCamelObject}}Model{
		gormDB:    gormDB,
		{{if .withCache}}cacheClient: cacheClient,{{end}}
		table:      {{.table}},
	}
}
