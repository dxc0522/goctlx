package new

import (
	_ "embed"
	"errors"
	"html/template"
	"os"
	"path/filepath"
	"strings"

	"github.com/dxc0522/goctlx/api/gogen"
	conf "github.com/dxc0522/goctlx/config"
	"github.com/dxc0522/goctlx/util/pathx"
	"github.com/spf13/cobra"
)

//go:embed api.tpl
var apiTemplate string

var (
	// VarStringStyle describes the style of output files.
	VarStringStyle string
)

// CreateServiceCommand fast create service
func CreateServiceCommand(_ *cobra.Command, args []string) error {
	dirName := args[0]
	if len(VarStringStyle) == 0 {
		VarStringStyle = conf.DefaultFormat
	}
	if strings.Contains(dirName, "-") {
		return errors.New("api new command service name not support strikethrough, because this will used by function name")
	}

	abs, err := filepath.Abs(dirName)
	if err != nil {
		return err
	}

	err = pathx.MkdirIfNotExist(abs)
	if err != nil {
		return err
	}

	dirName = filepath.Base(filepath.Clean(abs))
	filename := dirName + ".api"
	apiFilePath := filepath.Join(abs, filename)
	fp, err := os.Create(apiFilePath)
	if err != nil {
		return err
	}

	defer fp.Close()

	text, err := pathx.LoadTemplate(category, apiTemplateFile, apiTemplate)
	if err != nil {
		return err
	}

	t := template.Must(template.New("template").Parse(text))
	if err := t.Execute(fp, map[string]string{
		"name":    dirName,
		"handler": strings.Title(dirName),
	}); err != nil {
		return err
	}

	err = gogen.DoGenProject(apiFilePath, abs, VarStringStyle)
	return err
}
