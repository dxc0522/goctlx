
// 更新{{.upperStartCamelObject}}记录
func (m *{{.upperStartCamelObject}}Model)Update(ctx context.Context, in *{{.upperStartCamelObject}}) (out *{{.upperStartCamelObject}}, err error) {
	db := m.DbEngin.WithContext(ctx).Table(TableName{{.upperStartCamelObject}})

	err = db.Updates(&in).Error
	if err != nil {
		return nil, err
	}
	return in, err
}

// 更新{{.upperStartCamelObject}}记录
func (m *{{.upperStartCamelObject}}Model)UpdateColumns(ctx context.Context, id int64, columns map[string]interface{}) error {
	db := m.DbEngin.WithContext(ctx).Table(TableName{{.upperStartCamelObject}})

	return db.Where("`id` = ?", id).UpdateColumns(&columns).Error
}

// 更新{{.upperStartCamelObject}}记录
func (m *{{.upperStartCamelObject}}Model)Save(ctx context.Context, in *{{.upperStartCamelObject}}) (out *{{.upperStartCamelObject}}, err error) {
	db := m.DbEngin.WithContext(ctx).Table(TableName{{.upperStartCamelObject}})

	err = db.Save(&in).Error
	if err != nil {
		return nil, err
	}
	return in, err
}