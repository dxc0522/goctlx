package main

import (
	"flag"
	"fmt"
	"os"
	"github.com/zeromicro/go-zero/core/logx"
	"vibrahealth/services/pkg/provide"

	{{.importPackages}}
)

var configFile = flag.String("f", "etc/{{.serviceName}}.yaml", "the config file")

func main() {
	flag.Parse()

	var c config.Config
	conf.MustLoad(*configFile, &c, conf.UseEnv())

    _ = logx.SetUp(logx.LogConf{
        ServiceName: c.Name,
        Stat:        false,
		Level:       "info",
    })

    server := rest.MustNewServer(c.RestConf)
    defer server.Stop()

    ctx, err := svc.NewServiceContext(c)
    if err != nil {
        logx.Error(err)
        os.Exit(0)
    }

    handler.RegisterHandlers(server, ctx)

	provide.ServerSetup(server, c.RestConf)
}
