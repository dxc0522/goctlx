Name: {{.serviceName}}
Host: {{.host}}
Port: {{.port}}
Log:
  Mode: console
  Encoding: json
  Level: info
  Path: logs
  KeepDays: 30
  Rotation: daily
  TimeFormat: "2006-01-02 15:04:05"
