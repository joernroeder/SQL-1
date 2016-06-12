// RowProtocol.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Formbound
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@_exported import String


public protocol RowConvertible {
    init<T: RowProtocol>(row: T) throws
}

public protocol RowProtocol {
    associatedtype Result: ResultProtocol
    
    var result: Result { get }
    var index: Int { get }
    
    func data(_ field: QualifiedField) throws -> Data?
}

public enum RowProtocolError: ErrorProtocol {
    case expectedQualifiedField(QualifiedField)
    case unexpectedNilValue(QualifiedField)
}

public extension RowProtocol {
    
    public func data(_ field: QualifiedField) throws -> Data? {
        
        let fieldName: String
        
        
        if let alias = field.alias {
            fieldName = alias
        }
        else {
            fieldName = field.unqualifiedName
        }
        
        guard let fieldIndex = result.index(ofFieldByName: fieldName) else {
            throw RowProtocolError.expectedQualifiedField(field)
        }
        
        return result.data(atRow: index, forFieldIndex: fieldIndex)
    }
    
    public func data(_ field: QualifiedField) throws -> Data {
        guard let data: Data = try data(field) else {
            throw RowProtocolError.unexpectedNilValue(field)
        }
        
        return data
    }
    
    public func data(_ field: String) throws -> Data {
        let field = QualifiedField(field)
        guard let data: Data = try data(field) else {
            throw RowProtocolError.unexpectedNilValue(field)
        }
        
        return data
    }
    
    // MARK: - ValueConvertible
    
    public func value<T: ValueConvertible>(_ field: QualifiedField) throws -> T? {
        guard let data: Data = try data(field) else {
            return nil
        }
        
        return try T(rawSQLData: data)
    }
    
    public func value<T: ValueConvertible>(_ field: QualifiedField) throws -> T {
        guard let data: Data = try data(field) else {
            throw RowProtocolError.unexpectedNilValue(field)
        }
        
        return try T(rawSQLData: data)
    }
    
    // MARK - String support
    
    public func data(field: String) throws -> Data? {
        return try data(QualifiedField(field))
    }
    
    public func value<T: ValueConvertible>(_ field: String) throws -> T? {
        return try value(QualifiedField(field))
    }
    
    public func value<T: ValueConvertible>(_ field: String) throws -> T {
        return try value(QualifiedField(field))
    }
}

public protocol TableRowConvertible: TableProtocol, RowConvertible {
    init<Row: RowProtocol>(row: TableRow<Self, Row>) throws
}

extension TableRowConvertible {
    init<Row: RowProtocol>(row: Row) throws {
        try self.init(row: TableRow(row: row))
    }
}

public struct TableRow<Table: TableProtocol, Row: RowProtocol>: RowProtocol {
    public var result: Row.Result
    public var index: Int
    private let _data: (QualifiedField) throws -> Data?
    
    public init(row: Row) {
        self.result = row.result
        self.index = row.index
        self._data = row.data
    }
    
    public func data(_ field: QualifiedField) throws -> Data? {
        return try self._data(field)
    }
}

extension TableRow where Table.Field.RawValue == String {
    public func value<T: ValueConvertible>(_ field: Table.Field) throws -> T {
        return try value(Table.field(field))
    }
    
    public func value<T: ValueConvertible>(_ field: Table.Field) throws -> T? {
        return try value(Table.field(field))
    }
}
