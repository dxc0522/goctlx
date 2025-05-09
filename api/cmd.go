package api

import (
	"os"
	"path/filepath"

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
	"github.com/spf13/cobra"
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
	)
	apiCmdFlags.StringVar(&apigen.VarStringOutput, "o")

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
	goCmdFlags.StringVarWithDefaultValue(&gogen.VarStringStyle, "style", config.DefaultFormat)

	newCmdFlags.StringVarWithDefaultValue(&new.VarStringStyle, "style", config.DefaultFormat)

	pluginCmdFlags.StringVarP(&plugin.VarStringPlugin, "plugin", "p")
	pluginCmdFlags.StringVar(&plugin.VarStringDir, "dir")
	pluginCmdFlags.StringVar(&plugin.VarStringAPI, "api")
	pluginCmdFlags.StringVar(&plugin.VarStringStyle, "style")

	tsCmdFlags.StringVar(&tsgen.VarStringDir, "dir")
	tsCmdFlags.StringVar(&tsgen.VarStringAPI, "api")
	tsCmdFlags.StringVar(&tsgen.VarStringCaller, "caller")
	tsCmdFlags.BoolVar(&tsgen.VarBoolUnWrap, "unwrap")

	validateCmdFlags.StringVar(&validate.VarStringAPI, "api")
	// Add sub-commands
	Cmd.AddCommand(docCmd, formatCmd, goCmd, newCmd, pluginCmd, tsCmd, validateCmd)
}
