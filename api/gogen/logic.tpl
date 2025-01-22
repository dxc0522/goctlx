package {{.pkgName}}

import (
	"net/http"
	{{.imports}}
)

type {{.logic}} struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
	reqCtx *http.Request
	respWriter *http.ResponseWriter
}

{{if .hasDoc}}{{.doc}}{{end}}
func New{{.logic}}(ctx context.Context, svcCtx *svc.ServiceContext, reqCtx *http.Request, respWriter *http.ResponseWriter) *{{.logic}} {
	return &{{.logic}}{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
		reqCtx: reqCtx,
		respWriter: respWriter,
	}
}

func (l *{{.logic}}) {{.function}}({{.request}}) {{.responseType}} {
	// todo: add your logic here and delete this line

	{{.returnString}}
}
