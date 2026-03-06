// 更新{{.upperStartCamelObject}}记录
func (m *default{{.upperStartCamelObject}}Model) Update(ctx context.Context, in *{{.upperStartCamelObject}}) error {
	err := m.db.WithContext(ctx).Table(m.table).Updates(in).Error
	if err != nil {
		return err
	}
	return nil
}

// 更新{{.upperStartCamelObject}}记录
func (m *default{{.upperStartCamelObject}}Model) Save(ctx context.Context, in *{{.upperStartCamelObject}}) error {
	err := m.db.WithContext(ctx).Table(m.table).Save(in).Error
	if err != nil {
		return err
	}
	return nil
}
