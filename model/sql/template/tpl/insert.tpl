// 插入{{.upperStartCamelObject}}记录
func (m *default{{.upperStartCamelObject}}Model) Insert(ctx context.Context, in *{{.upperStartCamelObject}}) error {
	err := m.db.WithContext(ctx).Table(m.table).Create(in).Error
	if err != nil {
		return err
	}
	return nil
}

// 插入{{.upperStartCamelObject}}记录
func (m *default{{.upperStartCamelObject}}Model) InsertBatch(ctx context.Context, in ...*{{.upperStartCamelObject}}) (int64, error) {
	result := m.db.WithContext(ctx).Table(m.table).CreateInBatches(in, len(in))
	if result.Error != nil {
		return 0, result.Error
	}
	return result.RowsAffected, nil
}
