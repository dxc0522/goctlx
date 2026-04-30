	Delete(ctx context.Context, {{.lowerStartCamelPrimaryKey}} {{.dataType}}) error
	DeleteBatchGorm(ctx context.Context, conditions string, args ...interface{}) (int64, error)
