package bug

import (
	"github.com/spf13/cobra"
	"github.com/dxc0522/goctlx/internal/cobrax"
)

// Cmd describes a bug command.
var Cmd = cobrax.NewCommand("bug", cobrax.WithRunE(runE), cobrax.WithArgs(cobra.NoArgs))
