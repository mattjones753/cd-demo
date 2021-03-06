// Code generated by MockGen. DO NOT EDIT.
// Source: db.go

// Package db is a generated GoMock package.
package db

import (
	gomock "github.com/golang/mock/gomock"
	reflect "reflect"
)

// MockDb is a mock of Db interface
type MockDb struct {
	ctrl     *gomock.Controller
	recorder *MockDbMockRecorder
}

// MockDbMockRecorder is the mock recorder for MockDb
type MockDbMockRecorder struct {
	mock *MockDb
}

// NewMockDb creates a new mock instance
func NewMockDb(ctrl *gomock.Controller) *MockDb {
	mock := &MockDb{ctrl: ctrl}
	mock.recorder = &MockDbMockRecorder{mock}
	return mock
}

// EXPECT returns an object that allows the caller to indicate expected use
func (m *MockDb) EXPECT() *MockDbMockRecorder {
	return m.recorder
}

// Select mocks base method
func (m *MockDb) Select(user string) (*User, error) {
	ret := m.ctrl.Call(m, "Select", user)
	ret0, _ := ret[0].(*User)
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// Select indicates an expected call of Select
func (mr *MockDbMockRecorder) Select(user interface{}) *gomock.Call {
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "Select", reflect.TypeOf((*MockDb)(nil).Select), user)
}
