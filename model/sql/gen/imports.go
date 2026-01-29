package gen

import (
	"fmt"
	"strings"

	"github.com/dxc0522/goctlx/model/sql/template"
	"github.com/dxc0522/goctlx/util"
	"github.com/dxc0522/goctlx/util/pathx"
)

func genImports(table Table, withCache, timeImport bool) (string, error) {
	var thirdImports []string
	var m = map[string]struct{}{}
	var hasSqlType = false // 新增：检测是否有 sql 类型字段

	for _, c := range table.Fields {
		if len(c.ThirdPkg) > 0 {
			if _, ok := m[c.ThirdPkg]; ok {
				continue
			}
			m[c.ThirdPkg] = struct{}{}
			thirdImports = append(thirdImports, fmt.Sprintf("%q", c.ThirdPkg))
		}
		// 新增：检测字段类型是否以 sql. 开头
		if strings.HasPrefix(c.DataType, "sql.") {
			hasSqlType = true
		}
	}

	if withCache {
		text, err := pathx.LoadTemplate(category, importsTemplateFile, template.Imports)
		if err != nil {
			return "", err
		}

		buffer, err := util.With("import").Parse(text).Execute(map[string]any{
			"time":       timeImport,
			"containsPQ": table.ContainsPQ,
			"data":       table,
			"third":      strings.Join(thirdImports, "\n"),
			"hasSqlType": hasSqlType, // 新增：传递 sql 类型检测结果
		})
		if err != nil {
			return "", err
		}

		return buffer.String(), nil
	}

	text, err := pathx.LoadTemplate(category, importsWithNoCacheTemplateFile, template.ImportsNoCache)
	if err != nil {
		return "", err
	}

	buffer, err := util.With("import").Parse(text).Execute(map[string]any{
		"time":       timeImport,
		"containsPQ": table.ContainsPQ,
		"data":       table,
		"third":      strings.Join(thirdImports, "\n"),
		"hasSqlType": hasSqlType, // 新增：传递 sql 类型检测结果
	})
	if err != nil {
		return "", err
	}

	return buffer.String(), nil
}
