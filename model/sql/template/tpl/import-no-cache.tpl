import (
	"context"
	{{if .containsSqlNull}}"database/sql"
	{{end}}"errors"
	{{if .time}}"time"
	{{end}}{{if .containsPQ}}"github.com/lib/pq"
	{{end}}"gorm.io/gorm"
	{{if .third}}{{.third}}
	{{end}})
