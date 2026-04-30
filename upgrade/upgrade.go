package upgrade

import (
	"fmt"
	"runtime"

	"github.com/spf13/cobra"
	"github.com/dxc0522/goctlx/rpc/execx"
)

func upgrade(_ *cobra.Command, _ []string) error {
	cmd := `go install github.com/dxc0522/goctlx@latest`
	if runtime.GOOS == "windows" {
		cmd = `go install github.com/dxc0522/goctlx@latest`
	}
	info, err := execx.Run(cmd, "")
	if err != nil {
		return err
	}

	fmt.Print(info)
	return nil
}
