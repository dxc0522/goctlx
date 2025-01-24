package logic

import (
	"context"
    "net/http"
	"encoding/json"
	"fmt"
    "github.com/zeromicro/go-zero/core/logx"
	{{.imports}}
)

type {{.logic}} struct {
	logx.Logger
    *svc.ServiceContext
    ctx        context.Context
    reqCtx     *http.Request
    respWriter *http.ResponseWriter
    NewErrorResponse func(code int, resp any) *ResponseDataError
}

func New{{.logic}}(ctx context.Context, svcCtx *svc.ServiceContext, reqCtx *http.Request, respWriter *http.ResponseWriter) *{{.logic}} {
	return &{{.logic}}{
		Logger:         logx.WithContext(ctx),
		ServiceContext: svcCtx,
		ctx:            ctx,
		reqCtx:         reqCtx,
		respWriter:     respWriter,
		NewErrorResponse: NewErrorResponse,
	}
}

type ResponseDataError struct {
	Data any `json:"data"`
	Code int `json:"code"`
}

func (e *ResponseDataError) Error() string {
	jsonStr, err := json.Marshal(e.Data)
	if err != nil {
		return fmt.Sprint(e.Data)
	}
	return string(jsonStr)
}

func NewErrorResponse(code int, resp any) *ResponseDataError {
	return &ResponseDataError{
		Data: resp,
		Code: code,
	}
}