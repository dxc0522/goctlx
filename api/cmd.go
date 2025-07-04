package api

import (
	"os"
	"path/filepath"

	"github.com/spf13/cobra"

	"github.com/dxc0522/goctlx/api/swagger"

	"github.com/dxc0522/goctlx/api/apigen"
	"github.com/dxc0522/goctlx/api/docgen"
	"github.com/dxc0522/goctlx/api/format"
	"github.com/dxc0522/goctlx/api/gogen"
	"github.com/dxc0522/goctlx/api/new"
	"github.com/dxc0522/goctlx/api/tsgen"
	"github.com/dxc0522/goctlx/api/validate"
	"github.com/dxc0522/goctlx/config"
	"github.com/dxc0522/goctlx/internal/cobrax"
	"github.com/dxc0522/goctlx/plugin"
)

var (
	// Cmd describes an api command.
	Cmd       = cobrax.NewCommand("api", cobrax.WithRunE(apigen.CreateApiTemplate))
	docCmd    = cobrax.NewCommand("doc", cobrax.WithRunE(docgen.DocCommand))
	formatCmd = cobrax.NewCommand("format", cobrax.WithRunE(format.GoFormatApi))
	goCmd     = cobrax.NewCommand("go", cobrax.WithRunE(gogen.GoCommand))
	newCmd    = cobrax.NewCommand("new", cobrax.WithRunE(new.CreateServiceCommand),
		cobrax.WithArgs(cobra.MatchAll(cobra.ExactArgs(1), cobra.OnlyValidArgs)))
	validateCmd = cobrax.NewCommand("validate", cobrax.WithRunE(validate.GoValidateApi))
	pluginCmd   = cobrax.NewCommand("plugin", cobrax.WithRunE(plugin.PluginCommand))
	tsCmd       = cobrax.NewCommand("ts", cobrax.WithRunE(tsgen.TsCommand))
	swaggerCmd  = cobrax.NewCommand("swagger", cobrax.WithRunE(swagger.Command))
)

func init() {
	var (
		apiCmdFlags      = Cmd.Flags()
		docCmdFlags      = docCmd.Flags()
		formatCmdFlags   = formatCmd.Flags()
		goCmdFlags       = goCmd.Flags()
		newCmdFlags      = newCmd.Flags()
		pluginCmdFlags   = pluginCmd.Flags()
		tsCmdFlags       = tsCmd.Flags()
		validateCmdFlags = validateCmd.Flags()
		swaggerCmdFlags  = swaggerCmd.Flags()
	)

	apiCmdFlags.StringVar(&apigen.VarStringOutput, "o")
	apiCmdFlags.StringVar(&apigen.VarStringHome, "home")
	apiCmdFlags.StringVar(&apigen.VarStringRemote, "remote")
	apiCmdFlags.StringVar(&apigen.VarStringBranch, "branch")

	docCmdFlags.StringVar(&docgen.VarStringDir, "dir")
	docCmdFlags.StringVar(&docgen.VarStringOutput, "o")

	formatCmdFlags.StringVar(&format.VarStringDir, "dir")
	formatCmdFlags.BoolVar(&format.VarBoolIgnore, "iu")
	formatCmdFlags.BoolVar(&format.VarBoolUseStdin, "stdin")
	formatCmdFlags.BoolVar(&format.VarBoolSkipCheckDeclare, "declare")

	currentDir, _ := os.Getwd()
	defaultApiFile := filepath.Join(currentDir, filepath.Base(currentDir)+".api")
	goCmdFlags.StringVarWithDefaultValue(&gogen.VarStringDir, "dir", ".")
	goCmdFlags.StringVarWithDefaultValue(&gogen.VarStringAPI, "api", defaultApiFile)
	goCmdFlags.StringVar(&gogen.VarStringHome, "home")
	goCmdFlags.StringVar(&gogen.VarStringRemote, "remote")
	goCmdFlags.StringVar(&gogen.VarStringBranch, "branch")
	goCmdFlags.BoolVar(&gogen.VarBoolWithTest, "test")
	goCmdFlags.BoolVar(&gogen.VarBoolTypeGroup, "type-group")
	goCmdFlags.StringVarWithDefaultValue(&gogen.VarStringStyle, "style", config.DefaultFormat)

	newCmdFlags.StringVar(&new.VarStringHome, "home")
	newCmdFlags.StringVar(&new.VarStringRemote, "remote")
	newCmdFlags.StringVar(&new.VarStringBranch, "branch")
	newCmdFlags.StringVarWithDefaultValue(&new.VarStringStyle, "style", config.DefaultFormat)

	pluginCmdFlags.StringVarP(&plugin.VarStringPlugin, "plugin", "p")
	pluginCmdFlags.StringVar(&plugin.VarStringDir, "dir")
	pluginCmdFlags.StringVar(&plugin.VarStringAPI, "api")
	pluginCmdFlags.StringVar(&plugin.VarStringStyle, "style")

	tsCmdFlags.StringVar(&tsgen.VarStringDir, "dir")
	tsCmdFlags.StringVar(&tsgen.VarStringAPI, "api")
	tsCmdFlags.StringVar(&tsgen.VarStringCaller, "caller")
	tsCmdFlags.BoolVar(&tsgen.VarBoolUnWrap, "unwrap")

	swaggerCmdFlags.StringVar(&swagger.VarStringAPI, "api")
	swaggerCmdFlags.StringVar(&swagger.VarStringDir, "dir")
	swaggerCmdFlags.StringVar(&swagger.VarStringFilename, "filename")
	swaggerCmdFlags.BoolVar(&swagger.VarBoolYaml, "yaml")

	validateCmdFlags.StringVar(&validate.VarStringAPI, "api")

	// Add sub-commands
	Cmd.AddCommand(docCmd, formatCmd, goCmd, newCmd, pluginCmd, tsCmd, validateCmd, swaggerCmd)
}
