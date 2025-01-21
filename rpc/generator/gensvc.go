package generator

import (
	_ "embed"
	"fmt"
	"path/filepath"

	conf "github.com/dxc0522/goctlx/config"
	"github.com/dxc0522/goctlx/rpc/parser"
	"github.com/dxc0522/goctlx/util"
	"github.com/dxc0522/goctlx/util/format"
	"github.com/dxc0522/goctlx/util/pathx"
)

//go:embed svc.tpl
var svcTemplate string

// GenSvc generates the servicecontext.go file, which is the resource dependency of a service,
// such as rpc dependency, model dependency, etc.
func (g *Generator) GenSvc(ctx DirContext, _ parser.Proto, cfg *conf.Config) error {
	dir := ctx.GetSvc()
	svcFilename, err := format.FileNamingFormat(cfg.NamingFormat, "service_context")
	if err != nil {
		return err
	}

	fileName := filepath.Join(dir.Filename, svcFilename+".go")
	text, err := pathx.LoadTemplate(category, svcTemplateFile, svcTemplate)
	if err != nil {
		return err
	}

	return util.With("svc").GoFmt(true).Parse(text).SaveTo(map[string]any{
		"imports": fmt.Sprintf(`"%v"`, ctx.GetConfig().Package),
	}, fileName, false)
}
