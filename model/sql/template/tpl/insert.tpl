
// 插入{{.upperStartCamelObject}}记录
func (m *{{.upperStartCamelObject}}Model)Insert(ctx context.Context, in *{{.upperStartCamelObject}}) (out *{{.upperStartCamelObject}}, err error) {
	db := m.DbEngin.WithContext(ctx).Table(TableName{{.upperStartCamelObject}})

	err = db.Create(&in).Error
	if err != nil {
		return nil, err
	}
	return in, err
}

// 插入{{.upperStartCamelObject}}记录
func (m *{{.upperStartCamelObject}}Model)InsertBatch(ctx context.Context, in ...*{{.upperStartCamelObject}}) (rows int64, err error) {
	db := m.DbEngin.WithContext(ctx).Table(TableName{{.upperStartCamelObject}})

	err = db.CreateInBatches(&in, len(in)).Error
	if err != nil {
		return 0, err
	}
	return rows, err
}
