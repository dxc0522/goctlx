package gen

import (
	"fmt"

	"github.com/dxc0522/goctlx/model/sql/template"
	"github.com/dxc0522/goctlx/util"
	"github.com/dxc0522/goctlx/util/pathx"
)

func genNew(table Table, withCache, postgreSql bool) (string, error) {
	text, err := pathx.LoadTemplate(category, modelNewTemplateFile, template.New)
	if err != nil {
		return "", err
	}

	t := fmt.Sprintf(`"%s"`, wrapWithRawString(table.Name.Source(), postgreSql))
	if postgreSql {
		t = "`" + fmt.Sprintf(`"%s"."%s"`, table.Db.Source(), table.Name.Source()) + "`"
	}

	output, err := util.With("new").
		Parse(text).
		Execute(map[string]any{
			"table":                 t,
			"withCache":             withCache,
			"upperStartCamelObject": table.Name.ToCamel(),
			"data":                  table,
		})
	if err != nil {
		return "", err
	}

	return output.String(), nil
}
