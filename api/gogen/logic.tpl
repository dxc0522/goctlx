package {{.pkgName}}

import (
	"net/http"
	{{.imports}}
)

type {{.logic}} struct {
	logx.Logger
	*svc.ServiceContext
	ctx        context.Context
	reqCtx     *http.Request
	respWriter *http.ResponseWriter
}

func New{{.logic}}(ctx context.Context, svcCtx *svc.ServiceContext, reqCtx *http.Request, respWriter *http.ResponseWriter) *{{.logic}} {
	return &{{.logic}}{
		Logger: logx.WithContext(ctx),
		ServiceContext: svcCtx,
		ctx:        ctx,
		reqCtx:     reqCtx,
		respWriter: respWriter,
	}
}

{{if .hasDoc}}{{.doc}}{{end}}
func (l *{{.logic}}) {{.function}}({{.request}}) {{.responseType}} {
	// todo: add your logic here and delete this line

	{{.returnString}}
}
