var (
	{{if .withCache}}{{.cacheKeys}}{{end}}
	TableName{{.upperStartCamelObject}} = "{{.table}}"
)
