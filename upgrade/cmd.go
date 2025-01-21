package upgrade

import "github.com/dxc0522/goctlx/internal/cobrax"

// Cmd describes an upgrade command.
var Cmd = cobrax.NewCommand("upgrade", cobrax.WithRunE(upgrade))
