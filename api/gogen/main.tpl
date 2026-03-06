package main

import (
	"flag"
	"fmt"
	"os"
	"vibrahealth/services/pkg/provide"

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
		fmt.Printf("NewServiceContext err: %v", err)
        os.Exit(0)
    }

    handler.RegisterHandlers(server, ctx)

	provide.ServerSetup(server, c.RestConf)
}
