// Code scaffolded by goctl. Safe to edit.
// goctl {{.version}}

package {{.pkgName}}

import (
    "context"
    "net/http"
    "net/http/httptest"
    "testing"

    {{.imports}}
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func Test{{.logic}}_{{.function}}(t *testing.T) {
    c := config.Config{}
    mockSvcCtx, err := svc.NewServiceContext(c)
    require.NoError(t, err)
    // init mock service context here

    tests := []struct {
        name       string
        ctx        context.Context
        setupMocks func()
        {{if .hasRequest}}req        *{{.requestType}}{{end}}
        wantErr    bool
        checkResp  func{{if .hasResponse}}{{.responseType}}{{else}}(err error){{end}}
    }{
        {
            name: "response error",
            ctx:  context.Background(),
            setupMocks: func() {
                // mock data for this test case
            },
            {{if .hasRequest}}req:  &{{.requestType}}{
                // TODO: init your request here
            },{{end}}
            wantErr: true,
            checkResp: func{{if .hasResponse}}{{.responseType}}{{else}}(err error){{end}} {
                // TODO: Add your check logic here
            },
        },
        {
            name: "successful",
            ctx:  context.Background(),
            setupMocks: func() {
                // Mock data for this test case
            },
            {{if .hasRequest}}req:  &{{.requestType}}{
                // TODO: init your request here
            },{{end}}
            wantErr: false,
            checkResp: func{{if .hasResponse}}{{.responseType}}{{else}}(err error){{end}} {
                // TODO: Add your check logic here
            },
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            tt.setupMocks()
            req := httptest.NewRequest(http.MethodGet, "/", nil).WithContext(tt.ctx)
            var w http.ResponseWriter = httptest.NewRecorder()
            l := New{{.logic}}(tt.ctx, mockSvcCtx, req, &w)
            {{if .sseResponseType}}client := make(chan {{.sseResponseType}}, 16)
            {{end}}{{if .hasResponse}}resp, {{end}}err := l.{{.function}}({{if .hasRequest}}tt.req{{end}}{{if .sseResponseType}}{{if .hasRequest}}, {{end}}client{{end}})
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                require.NoError(t, err)
                {{if .hasResponse}}assert.NotNil(t, resp){{end}}
            }
            tt.checkResp({{if .hasResponse}}resp, {{end}}err)
        })
    }
}
