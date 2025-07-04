package apigen

import (
	_ "embed"
	"errors"
	"fmt"
	"html/template"
	"path/filepath"
	"strings"

	"github.com/gookit/color"
	"github.com/spf13/cobra"

	"github.com/dxc0522/goctlx/util"
	"github.com/dxc0522/goctlx/util/pathx"
)

//go:embed api.tpl
var apiTemplate string

var (
	// VarStringOutput describes the output.
	VarStringOutput string
	// VarStringHome describes the goctl home.
	VarStringHome string
	// VarStringRemote describes the remote git repository.
	VarStringRemote string
	// VarStringBranch describes the git branch.
	VarStringBranch string
)

// CreateApiTemplate create api template file
func CreateApiTemplate(_ *cobra.Command, _ []string) error {
	apiFile := VarStringOutput
	if len(apiFile) == 0 {
		return errors.New("missing -o")
	}

	baseName := pathx.FileNameWithoutExt(filepath.Base(apiFile))
	if strings.HasSuffix(strings.ToLower(baseName), "-api") {
		baseName = baseName[:len(baseName)-4]
	} else if strings.HasSuffix(strings.ToLower(baseName), "api") {
		baseName = baseName[:len(baseName)-3]
	}

	if err := pathx.MkdirIfNotExist(baseName); err != nil {
		return err
	}

	finalApiFile := filepath.Join(baseName, baseName+".api")
	fp, err := pathx.CreateIfNotExist(finalApiFile)
	if err != nil {
		return err
	}
	defer fp.Close()

	if len(VarStringRemote) > 0 {
		repo, _ := util.CloneIntoGitHome(VarStringRemote, VarStringBranch)
		if len(repo) > 0 {
			VarStringHome = repo
		}
	}

	if len(VarStringHome) > 0 {
		pathx.RegisterGoctlHome(VarStringHome)
	}

	text, err := pathx.LoadTemplate(category, apiTemplateFile, apiTemplate)
	if err != nil {
		return err
	}

	t := template.Must(template.New("etcTemplate").Parse(text))
	if err := t.Execute(fp, map[string]string{
		"gitUser":     getGitName(),
		"gitEmail":    getGitEmail(),
		"serviceName": baseName,
	}); err != nil {
		return err
	}

	fmt.Println(color.Green.Render("Done."))
	return nil
}
