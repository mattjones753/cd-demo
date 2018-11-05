//go:generate mockgen -package db -source=db.go -destination db_mock.go
package db

import (
	"fmt"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

type Db interface {
	Select(user string) (*User, error)
}

type dbConn struct {
	dataSourceString string
}

type User struct {
	Name string `db:"name"`
}

func NewDb(username, host, password, schema string) *dbConn {
	dataSourceString := fmt.Sprintf("postgres://%v:%v@%v/%v?sslmode=disable",
		username,
		password,
		host,
		schema)
	return &dbConn{
		dataSourceString,
	}
}

func (db *dbConn) Select(username string) (*User, error) {
	database, err := sqlx.Connect("postgres", db.dataSourceString)
	if err != nil {
		return nil, err
	}
	var users []User
	database.Select(&users, `SELECT name FROM users where name = $1`, username)

	if len(users) > 0 {
		return &users[0], nil
	}
	return nil, nil

}
