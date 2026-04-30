func new{{.upperStartCamelObject}}Model(conn sqlx.SqlConn, gormDB *gorm.DB{{if .withCache}}, c cache.CacheConf, opts ...cache.Option{{end}}) *default{{.upperStartCamelObject}}Model {
	return &default{{.upperStartCamelObject}}Model{
		{{if .withCache}}CachedConn: sqlc.NewConn(conn, c, opts...){{else}}conn:conn{{end}},
		gormDB:    gormDB,
		table:      {{.table}},
	}
}

