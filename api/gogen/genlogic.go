package gogen

import (
	_ "embed"
	"fmt"
	"strconv"
	"strings"

	"github.com/dxc0522/goctlx/api/parser/g4/gen/api"
	"github.com/dxc0522/goctlx/api/spec"
	"github.com/dxc0522/goctlx/config"
	"github.com/dxc0522/goctlx/util/format"
	"github.com/dxc0522/goctlx/util/pathx"
)

//go:embed logic.tpl
var logicTemplate string

//go:embed default-logic.tpl
var defaultLogicTemplate string

func genLogic(dir, rootPkg string, cfg *config.Config, api *spec.ApiSpec) error {
	//generate default logic file
	imports := fmt.Sprintf("\"%s\"", pathx.JoinPackages(rootPkg, contextDir))
	logicName := strings.Title(api.Service.Name + "Logic")
	err := genFile(fileGenConfig{
		dir:             dir,
		subdir:          logicDir,
		filename:        logicDir + ".go",
		templateName:    "logicDefaultTemplate",
		category:        category,
		templateFile:    defaultLogicTemplateFile,
		builtinTemplate: defaultLogicTemplate,
		data: map[string]any{
			"logic":   logicName,
			"imports": imports,
		},
	})
	if err != nil {
		return err
	}
	for _, g := range api.Service.Groups {
		for _, r := range g.Routes {
			err := genLogicByRoute(dir, rootPkg, cfg, logicName, r)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func genLogicByRoute(dir, rootPkg string, cfg *config.Config, logicName string, route spec.Route) error {
	logic := getLogicName(route)
	goFile, err := format.FileNamingFormat(cfg.NamingFormat, logic)
	if err != nil {
		return err
	}

	imports := genLogicImports(route, rootPkg)
	var responseString string
	var returnString string
	var requestString string
	if len(route.ResponseTypeName()) > 0 {
		resp := responseGoTypeName(route, typesPacket)
		responseString = "(resp " + resp + ", err error)"
		returnString = "return"
	} else {
		responseString = "error"
		returnString = "return nil"
	}
	if len(route.RequestTypeName()) > 0 {
		requestString = "req *" + requestGoTypeName(route, typesPacket)
	}

	return genFile(fileGenConfig{
		dir:             dir,
		subdir:          logicDir,
		filename:        goFile + ".go",
		templateName:    "logicTemplate",
		category:        category,
		templateFile:    logicTemplateFile,
		builtinTemplate: logicTemplate,
		data: map[string]any{
			"pkgName":      logicDir,
			"imports":      imports,
			"logic":        logicName,
			"function":     strings.Title(strings.TrimSuffix(logic, "Logic")),
			"responseType": responseString,
			"returnString": returnString,
			"request":      requestString,
			"hasDoc":       len(route.JoinedDoc()) > 0,
			"doc":          getDoc(route.JoinedDoc()),
		},
	})
}

func genLogicImports(route spec.Route, parentPkg string) string {
	var imports []string
	if shallImportTypesPackage(route) {
		imports = append(imports, fmt.Sprintf("\"%s\"\n", pathx.JoinPackages(parentPkg, typesDir)))
	}
	return strings.Join(imports, "\n\t")
}

func onlyPrimitiveTypes(val string) bool {
	fields := strings.FieldsFunc(val, func(r rune) bool {
		return r == '[' || r == ']' || r == ' '
	})

	for _, field := range fields {
		if field == "map" {
			continue
		}
		// ignore array dimension number, like [5]int
		if _, err := strconv.Atoi(field); err == nil {
			continue
		}
		if !api.IsBasicType(field) {
			return false
		}
	}

	return true
}

func shallImportTypesPackage(route spec.Route) bool {
	if len(route.RequestTypeName()) > 0 {
		return true
	}

	respTypeName := route.ResponseTypeName()
	if len(respTypeName) == 0 {
		return false
	}

	if onlyPrimitiveTypes(respTypeName) {
		return false
	}

	return true
}
