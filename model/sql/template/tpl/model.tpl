package {{.pkg}}
{{if .withCache}}
import (
    "github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)
{{else}}
import (
	"gorm.io/gorm"
)
{{end}}

type (
	// {{.upperStartCamelObject}}Model is an interface to be customized, add more methods here,
	// and implement the added methods in custom{{.upperStartCamelObject}}Model.
	{{.upperStartCamelObject}}Model interface {
		{{.lowerStartCamelObject}}Model
		{{if not .withCache}}withSession(session sqlx.Session) {{.upperStartCamelObject}}Model{{end}}
	}
)
