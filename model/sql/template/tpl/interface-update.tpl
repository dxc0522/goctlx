	Update(ctx context.Context, {{if .containsIndexCache}}newData{{else}}data{{end}} *{{.upperStartCamelObject}}) error
	UpdateGorm(ctx context.Context, data *{{.upperStartCamelObject}}) error
