	// 查询方法
	FindOne(ctx context.Context, {{.lowerStartCamelPrimaryKey}} {{.dataType}}) (*{{.upperStartCamelObject}}, error)
	FindOneByConditions(ctx context.Context, conditions string, args ...interface{}) (*{{.upperStartCamelObject}}, error)
	FindCount(ctx context.Context, conditions string, args ...interface{}) (int64, error)
	FindAll(ctx context.Context, conditions string, args ...interface{}) ([]*{{.upperStartCamelObject}}, error)
	FindList(ctx context.Context, limit, offset int64, sorts, conditions string, args ...interface{}) ([]*{{.upperStartCamelObject}}, error)
	FindPageWithCount(ctx context.Context, limit, offset int64, sorts, conditions string, args ...interface{}) ([]*{{.upperStartCamelObject}}, int64, error)
	// 写入方法
	Insert(ctx context.Context, data *{{.upperStartCamelObject}}) error
	InsertBatch(ctx context.Context, dataList []*{{.upperStartCamelObject}}) error
	Update(ctx context.Context, data *{{.upperStartCamelObject}}) error
	UpdateFields(ctx context.Context, {{.lowerStartCamelPrimaryKey}} {{.dataType}}, fields map[string]interface{}) error
	Delete(ctx context.Context, {{.lowerStartCamelPrimaryKey}} {{.dataType}}) error
	DeleteBatch(ctx context.Context, conditions string, args ...interface{}) (int64, error)
