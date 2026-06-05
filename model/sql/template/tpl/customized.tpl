// ==================== 查询方法 ====================

// FindOne 按主键查询单条记录
func (m *default{{.upperStartCamelObject}}Model) FindOne(ctx context.Context, {{.lowerStartCamelPrimaryKey}} {{.primaryKeyDataType}}) (*{{.upperStartCamelObject}}, error) {
	var resp {{.upperStartCamelObject}}
	err := m.gormDB.WithContext(ctx).Where("{{.originalPrimaryKey}} = ?", {{.lowerStartCamelPrimaryKey}}).First(&resp).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &resp, nil
}

// FindOneByConditions 按自定义条件查询单条记录
func (m *default{{.upperStartCamelObject}}Model) FindOneByConditions(ctx context.Context, conditions string, args ...interface{}) (*{{.upperStartCamelObject}}, error) {
	var resp {{.upperStartCamelObject}}
	err := m.gormDB.WithContext(ctx).Where(conditions, args...).First(&resp).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return &resp, nil
}

// FindCount 按条件统计记录数
func (m *default{{.upperStartCamelObject}}Model) FindCount(ctx context.Context, conditions string, args ...interface{}) (int64, error) {
	var count int64
	err := m.gormDB.WithContext(ctx).Model(&{{.upperStartCamelObject}}{}).Where(conditions, args...).Count(&count).Error
	return count, err
}

// FindAll 按条件查询所有匹配记录
func (m *default{{.upperStartCamelObject}}Model) FindAll(ctx context.Context, conditions string, args ...interface{}) ([]*{{.upperStartCamelObject}}, error) {
	var resp []*{{.upperStartCamelObject}}
	err := m.gormDB.WithContext(ctx).Where(conditions, args...).Find(&resp).Error
	return resp, err
}

// FindList 分页查询
func (m *default{{.upperStartCamelObject}}Model) FindList(ctx context.Context, limit, offset int64, sorts, conditions string, args ...interface{}) ([]*{{.upperStartCamelObject}}, error) {
	var resp []*{{.upperStartCamelObject}}
	query := m.gormDB.WithContext(ctx).Where(conditions, args...)
	if sorts != "" {
		query = query.Order(sorts)
	}
	err := query.Limit(int(limit)).Offset(int(offset)).Find(&resp).Error
	return resp, err
}

// FindPageWithCount 分页查询并返回总数
func (m *default{{.upperStartCamelObject}}Model) FindPageWithCount(ctx context.Context, limit, offset int64, sorts, conditions string, args ...interface{}) ([]*{{.upperStartCamelObject}}, int64, error) {
	var resp []*{{.upperStartCamelObject}}
	var count int64
	db := m.gormDB.WithContext(ctx).Model(&{{.upperStartCamelObject}}{}).Where(conditions, args...)
	if err := db.Count(&count).Error; err != nil {
		return nil, 0, err
	}
	query := m.gormDB.WithContext(ctx).Where(conditions, args...)
	if sorts != "" {
		query = query.Order(sorts)
	}
	err := query.Limit(int(limit)).Offset(int(offset)).Find(&resp).Error
	return resp, count, err
}

// ==================== 写入方法 ====================

// Insert 插入一条记录{{if .withCache}}，并清除相关缓存{{end}}
func (m *default{{.upperStartCamelObject}}Model) Insert(ctx context.Context, data *{{.upperStartCamelObject}}) error {
	if err := m.gormDB.WithContext(ctx).Create(data).Error; err != nil {
		return err
	}
	{{if .withCache}}m.invalidateCache(ctx, data){{end}}
	return nil
}

// InsertBatch 批量插入记录{{if .withCache}}，并清除相关缓存{{end}}
func (m *default{{.upperStartCamelObject}}Model) InsertBatch(ctx context.Context, dataList []*{{.upperStartCamelObject}}) error {
	if len(dataList) == 0 {
		return nil
	}
	if err := m.gormDB.WithContext(ctx).Create(&dataList).Error; err != nil {
		return err
	}
	{{if .withCache}}for _, data := range dataList {
		m.invalidateCache(ctx, data)
	}{{end}}
	return nil
}

// Update 全量更新记录（Save 模式，所有字段）{{if .withCache}}，并清除相关缓存{{end}}
func (m *default{{.upperStartCamelObject}}Model) Update(ctx context.Context, data *{{.upperStartCamelObject}}) error {
	if err := m.gormDB.WithContext(ctx).Save(data).Error; err != nil {
		return err
	}
	{{if .withCache}}m.invalidateCache(ctx, data){{end}}
	return nil
}

// UpdateFields 部分更新指定字段
// {{if .withCache}}注意：此方法无法获取更新前的唯一索引值，缓存清除依赖 TTL 过期。如需即时清缓存，请先查询再调用 Update。{{end}}
func (m *default{{.upperStartCamelObject}}Model) UpdateFields(ctx context.Context, {{.lowerStartCamelPrimaryKey}} {{.primaryKeyDataType}}, fields map[string]interface{}) error {
	if len(fields) == 0 {
		return nil
	}
	return m.gormDB.WithContext(ctx).Model(&{{.upperStartCamelObject}}{}).Where("{{.originalPrimaryKey}} = ?", {{.lowerStartCamelPrimaryKey}}).Updates(fields).Error
}

// ==================== 删除方法 ====================

// Delete 按主键删除单条记录
// {{if .withCache}}注意：此方法无法获取被删记录的唯一索引值，缓存清除依赖 TTL 过期。如需即时清缓存，请先查询再调用 DeleteBatch。{{end}}
func (m *default{{.upperStartCamelObject}}Model) Delete(ctx context.Context, {{.lowerStartCamelPrimaryKey}} {{.primaryKeyDataType}}) error {
	return m.gormDB.WithContext(ctx).Where("{{.originalPrimaryKey}} = ?", {{.lowerStartCamelPrimaryKey}}).Delete(&{{.upperStartCamelObject}}{}).Error
}

// DeleteBatch 按条件批量删除记录{{if .withCache}}（注意：批量删除无法精确清除缓存，依赖 TTL 过期）{{end}}
func (m *default{{.upperStartCamelObject}}Model) DeleteBatch(ctx context.Context, conditions string, args ...interface{}) (int64, error) {
	db := m.gormDB.WithContext(ctx).Where(conditions, args...).Delete(&{{.upperStartCamelObject}}{})
	return db.RowsAffected, db.Error
}

{{if .withCache}}
// ==================== 缓存辅助方法 ====================

// invalidateCache 清除与给定记录关联的缓存（主键 + 唯一索引）
func (m *default{{.upperStartCamelObject}}Model) invalidateCache(ctx context.Context, data *{{.upperStartCamelObject}}) {
	if m.cacheClient == nil {
		return
	}
	{{.data.PrimaryCacheKey.DataKeyExpression}}
	{{range .data.UniqueCacheKey}}{{.DataKeyExpression}}
	{{end}}
	_ = m.cacheClient.DelCtx(ctx, {{.data.PrimaryCacheKey.KeyLeft}}{{range .data.UniqueCacheKey}}, {{.KeyLeft}}{{end}})
}
{{end}}
