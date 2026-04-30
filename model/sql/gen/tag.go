package gen

import (
	"strings"

	"github.com/dxc0522/goctlx/model/sql/template"
	"github.com/dxc0522/goctlx/util"
	"github.com/dxc0522/goctlx/util/pathx"
	"github.com/dxc0522/goctlx/util/stringx"
)

func genTag(table Table, in string) (string, error) {
	if in == "" {
		return in, nil
	}

	text, err := pathx.LoadTemplate(category, tagTemplateFile, template.Tag)
	if err != nil {
		return "", err
	}

	output, err := util.With("tag").Parse(text).Execute(map[string]any{
		"field": in,
		"data":  table,
	})
	if err != nil {
		return "", err
	}

	dbTag := output.String()
	jsonTag := "json:\"" + stringx.From(in).ToCamel() + ",omitempty\""
	tagContent := strings.Trim(dbTag, "`") + " " + jsonTag
	return "`" + tagContent + "`", nil
}
