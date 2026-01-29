import (
	"context"
	{{if .time}}"time"{{end}}
    {{if .hasSqlType}}"database/sql"{{end}}
	"gorm.io/gorm"
)
