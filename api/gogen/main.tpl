// Code scaffolded by goctl. Safe to edit.
// goctl {{.version}}

package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/gchhotels/pkgx/provide"
	{{.importPackages}}
)

var configFile = flag.String("f", "etc/{{.serviceName}}.yaml", "the config file")

func main() {
	flag.Parse()

	var c config.Config
	conf.MustLoad(*configFile, &c, conf.UseEnv())

	server := rest.MustNewServer(c.RestConf)
	defer server.Stop()

	ctx, err := svc.NewServiceContext(c)
	if err != nil {
		fmt.Printf("NewServiceContext error: %v\n", err)
		os.Exit(1)
	}

	handler.RegisterHandlers(server, ctx)
	provide.ServerSetup(server, c.RestConf)
}
