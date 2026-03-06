// 删除{{.upperStartCamelObject}}记录
func (m *default{{.upperStartCamelObject}}Model) Delete(ctx context.Context, {{.lowerStartCamelPrimaryKey}} {{.dataType}}) (int64, error) {
	result := m.db.WithContext(ctx).Table(m.table).Where("{{.originalPrimaryKey}} = ?", {{.lowerStartCamelPrimaryKey}}).Delete(&{{.upperStartCamelObject}}{})
	if result.Error != nil {
		return 0, result.Error
	}
	return result.RowsAffected, nil
}

// 删除{{.upperStartCamelObject}}记录
func (m *default{{.upperStartCamelObject}}Model) DeleteBatch(ctx context.Context, conditions string, args ...interface{}) (int64, error) {
	db := m.db.WithContext(ctx).Table(m.table)

	// 如果有条件语句
	if len(conditions) != 0 {
		db = db.Where(conditions, args...)
	}

	result := db.Delete(&{{.upperStartCamelObject}}{})
	if result.Error != nil {
		return 0, result.Error
	}
	return result.RowsAffected, nil
}
