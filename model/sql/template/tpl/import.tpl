import (
	"context"
	"database/sql"
    {{if .time}}"time"{{end}}

    "github.com/redis/go-redis/v9"
    {{if .hasSqlType}}"database/sql"{{end}}
	"gorm.io/gorm"
)
