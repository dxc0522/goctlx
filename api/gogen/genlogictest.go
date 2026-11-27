package gogen

import (
	_ "embed"
	"fmt"
	"strings"

	"github.com/dxc0522/goctlx/api/spec"
	"github.com/dxc0522/goctlx/config"
	"github.com/dxc0522/goctlx/internal/version"
	"github.com/dxc0522/goctlx/util/format"
	"github.com/dxc0522/goctlx/util/pathx"
)

//go:embed logic_test.tpl
var logicTestTemplate string

func genLogicTest(dir, rootPkg, projectPkg string, cfg *config.Config, api *spec.ApiSpec) error {
	for _, g := range api.Service.Groups {
		for _, r := range g.Routes {
			err := genLogicTestByRoute(dir, rootPkg, projectPkg, cfg, g, r)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func genLogicTestByRoute(dir, rootPkg, projectPkg string, cfg *config.Config, group spec.Group, route spec.Route) error {
	logic := getLogicName(route)
	goFile, err := format.FileNamingFormat(cfg.NamingFormat, logic)
	if err != nil {
		return err
	}

	imports := genLogicTestImports(route, rootPkg)
	isSSE := group.GetAnnotation("sse") == "true"
	hasResponse := len(route.ResponseTypeName()) > 0 && !isSSE
	var responseString string
	var requestType string
	if hasResponse {
		resp := responseGoTypeName(route, typesPacket)
		responseString = "(resp " + resp + ", err error)"
	}
	if len(route.RequestTypeName()) > 0 {
		requestType = requestGoTypeName(route, typesPacket)
	}
	var sseResponseType string
	if isSSE {
		sseResponseType = responseGoTypeName(route, typesPacket)
	}

	subDir := getLogicFolderPath(group, route)
	return genFile(fileGenConfig{
		dir:             dir,
		subdir:          subDir,
		filename:        goFile + "_test.go",
		templateName:    "logicTestTemplate",
		category:        category,
		templateFile:    logicTestTemplateFile,
		builtinTemplate: logicTestTemplate,
		data: map[string]any{
			"pkgName":         subDir[strings.LastIndex(subDir, "/")+1:],
			"imports":         imports,
			"logic":           strings.Title(logic),
			"function":        strings.Title(strings.TrimSuffix(logic, "Logic")),
			"responseType":    responseString,
			"hasRequest":      len(requestType) > 0,
			"hasResponse":     hasResponse,
			"sseResponseType": sseResponseType,
			"requestType":     requestType,
			"hasDoc":          len(route.JoinedDoc()) > 0,
			"doc":             getDoc(route.JoinedDoc()),
			"projectPkg":      projectPkg,
			"version":         version.BuildVersion,
		},
	})
}

func genLogicTestImports(route spec.Route, parentPkg string) string {
	var imports []string
	//imports = append(imports, `"context"`+"\n")
	imports = append(imports, fmt.Sprintf("\"%s\"", pathx.JoinPackages(parentPkg, contextDir)))
	imports = append(imports, fmt.Sprintf("\"%s\"", pathx.JoinPackages(parentPkg, configDir)))
	if shallImportTypesPackage(route) {
		imports = append(imports, fmt.Sprintf("\"%s\"\n", pathx.JoinPackages(parentPkg, typesDir)))
	}
	//imports = append(imports, fmt.Sprintf("\"%s/core/logx\"", vars.ProjectOpenSourceURL))
	return strings.Join(imports, "\n\t")
}
