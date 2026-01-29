// 切换事务操作
Insert(ctx context.Context, in *{{.upperStartCamelObject}}) (*{{.upperStartCamelObject}}, error)
InsertBatch(ctx context.Context, in ...*{{.upperStartCamelObject}}) (rows int64, err error)