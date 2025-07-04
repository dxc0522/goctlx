package gogen

import (
	_ "embed"
	"fmt"
	"path"
	"strings"

	"github.com/dxc0522/goctlx/api/spec"
	"github.com/dxc0522/goctlx/config"
	"github.com/dxc0522/goctlx/util"
	"github.com/dxc0522/goctlx/util/format"
	"github.com/dxc0522/goctlx/util/pathx"
)

const defaultLogicPackage = "logic"

//go:embed handler.tpl
var handlerTemplate string

func genHandler(dir, rootPkg string, cfg *config.Config, api *spec.ApiSpec, group spec.Group, route spec.Route) error {
	handler := getHandlerName(route)
	filename, err := format.FileNamingFormat(cfg.NamingFormat, handler)
	if err != nil {
		return err
	}

	return genFile(fileGenConfig{
		dir:             dir,
		subdir:          handlerDir,
		filename:        filename + "_gen.go",
		templateName:    "handlerTemplate",
		category:        category,
		templateFile:    handlerTemplateFile,
		builtinTemplate: handlerTemplate,
		data: map[string]any{
			"PkgName":        handlerDir,
			"ImportPackages": genHandlerImports(route, rootPkg),
			"HandlerName":    strings.Title(handler),
			"RequestType":    util.Title(route.RequestTypeName()),
			"LogicName":      logicDir,
			"LogicType":      strings.Title(api.Service.Name + "Logic"),
			"Call":           strings.Title(strings.TrimSuffix(handler, "Handler")),
			"HasResp":        len(route.ResponseTypeName()) > 0,
			"HasRequest":     len(route.RequestTypeName()) > 0,
			"HasDoc":         len(route.JoinedDoc()) > 0,
			"Doc":            getDoc(route.JoinedDoc()),
		},
	})
}

func genHandlers(dir, rootPkg string, cfg *config.Config, api *spec.ApiSpec) error {
	for _, group := range api.Service.Groups {
		for _, route := range group.Routes {
			if err := genHandler(dir, rootPkg, cfg, api, group, route); err != nil {
				return err
			}
		}
	}

	return nil
}

func genHandlerImports(route spec.Route, parentPkg string) string {
	imports := []string{
		fmt.Sprintf("\"%s\"", pathx.JoinPackages(parentPkg, logicDir)),
		fmt.Sprintf("\"%s\"", pathx.JoinPackages(parentPkg, contextDir)),
	}
	if len(route.RequestTypeName()) > 0 {
		imports = append(imports, fmt.Sprintf("\"%s\"\n", pathx.JoinPackages(parentPkg, typesDir)))
	}

	return strings.Join(imports, "\n\t")
}

func getHandlerBaseName(route spec.Route) (string, error) {
	handler := route.Handler
	handler = strings.TrimSpace(handler)
	handler = strings.TrimSuffix(handler, "handler")
	handler = strings.TrimSuffix(handler, "Handler")

	return handler, nil
}

func getHandlerName(route spec.Route) string {
	handler, err := getHandlerBaseName(route)
	if err != nil {
		panic(err)
	}

	return handler + "Handler"
}

func getHandlerFolderPath(group spec.Group, route spec.Route) string {
	folder := route.GetAnnotation(groupProperty)
	if len(folder) == 0 {
		folder = group.GetAnnotation(groupProperty)
		if len(folder) == 0 {
			return handlerDir
		}
	}

	folder = strings.TrimPrefix(folder, "/")
	folder = strings.TrimSuffix(folder, "/")

	return path.Join(handlerDir, folder)
}

func getLogicName(route spec.Route) string {
	handler, err := getHandlerBaseName(route)
	if err != nil {
		panic(err)
	}

	return handler + "Logic"
}
