package main

import (
	"flag"
	"fmt"
	"github.com/zeromicro/go-zero/core/logx"

	{{.importPackages}}
)

var configFile = flag.String("f", "etc/{{.serviceName}}.yaml", "the config file")

func main() {
	flag.Parse()

	var c config.Config
	conf.MustLoad(*configFile, &c, conf.UseEnv())

    logx.SetUp(logx.LogConf{
        ServiceName: c.Name,
        Stat:        false,
    })

    server := rest.MustNewServer(c.RestConf)
    defer server.Stop()

    ctx, err := svc.NewServiceContext(c)
    if err != nil {
        logx.Error(err)
        os.Exit(0)
    }

    handler.RegisterHandlers(server, ctx)

	fmt.Printf("Starting server at %s:%d...\n", c.Host, c.Port)
	server.Start()
}
