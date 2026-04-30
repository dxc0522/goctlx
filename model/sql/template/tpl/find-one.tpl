func (m *default{{.upperStartCamelObject}}Model) FindOne(ctx context.Context, {{.lowerStartCamelPrimaryKey}} {{.dataType}}) (*{{.upperStartCamelObject}}, error) {
	{{if .withCache}}{{.cacheKey}}
	var resp {{.upperStartCamelObject}}
	err := m.QueryRowCtx(ctx, &resp, {{.cacheKeyVariable}}, func(ctx context.Context, conn sqlx.SqlConn, v any) error {
		query :=  fmt.Sprintf("select %s from %s where {{.originalPrimaryKey}} = {{if .postgreSql}}$1{{else}}?{{end}} limit 1", {{.lowerStartCamelObject}}Rows, m.table)
		return conn.QueryRowCtx(ctx, v, query, {{.lowerStartCamelPrimaryKey}})
	})
	switch err {
	case nil:
		return &resp, nil
	case sqlc.ErrNotFound:
		return nil, ErrNotFound
	default:
		return nil, err
	}{{else}}query := fmt.Sprintf("select %s from %s where {{.originalPrimaryKey}} = {{if .postgreSql}}$1{{else}}?{{end}} limit 1", {{.lowerStartCamelObject}}Rows, m.table)
	var resp {{.upperStartCamelObject}}
	err := m.conn.QueryRowCtx(ctx, &resp, query, {{.lowerStartCamelPrimaryKey}})
	switch err {
	case nil:
		return &resp, nil
	case sqlx.ErrNotFound:
		return nil, ErrNotFound
	default:
		return nil, err
	}{{end}}
}

func (m *default{{.upperStartCamelObject}}Model) FirstGorm(ctx context.Context, conditions string, args ...interface{}) (*{{.upperStartCamelObject}}, error) {
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

func (m *default{{.upperStartCamelObject}}Model) FindCountGorm(ctx context.Context, conditions string, args ...interface{}) (int64, error) {
	var count int64
	err := m.gormDB.WithContext(ctx).Model(&{{.upperStartCamelObject}}{}).Where(conditions, args...).Count(&count).Error
	return count, err
}

func (m *default{{.upperStartCamelObject}}Model) FindALLGorm(ctx context.Context, conditions string, args ...interface{}) ([]*{{.upperStartCamelObject}}, error) {
	var resp []*{{.upperStartCamelObject}}
	err := m.gormDB.WithContext(ctx).Where(conditions, args...).Find(&resp).Error
	return resp, err
}

func (m *default{{.upperStartCamelObject}}Model) FindListGorm(ctx context.Context, limit, offset int64, sorts, conditions string, args ...interface{}) ([]*{{.upperStartCamelObject}}, error) {
	var resp []*{{.upperStartCamelObject}}
	err := m.gormDB.WithContext(ctx).Where(conditions, args...).Order(sorts).Limit(int(limit)).Offset(int(offset)).Find(&resp).Error
	return resp, err
}
