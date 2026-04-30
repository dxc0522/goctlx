// Code scaffolded by goctl. Safe to edit.
// goctl {{.version}}

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

{{if .hasDoc}}{{.doc}}{{end}}
func New{{.logic}}(ctx context.Context, svcCtx *svc.ServiceContext, r *http.Request, w *http.ResponseWriter) *{{.logic}} {
	return &{{.logic}}{
		Logger:     logx.WithContext(ctx),
		ServiceContext: svcCtx,
		ctx:        ctx,
		reqCtx:     r,
		respWriter: w,
	}
}

func (l *{{.logic}}) {{.function}}({{.request}}) {{.responseType}} {
	// todo: add your logic here and delete this line

	{{.returnString}}
}
