// Update.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 Formbound
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

public struct Update: PredicatedQuery {
    public var predicate: Predicate? = nil
    
    public private(set) var valuesByField: [QualifiedField: Value?] = [:]
    
    public let tableName: String
    
    public init(_ tableName: String) {
        self.tableName = tableName
    }
    
    public mutating func set<T: ValueConvertible>(_ field: QualifiedField, _ value: T?) {
        valuesByField[field] = value?.sqlValue
    }
    
    public mutating func set(_ dict: [QualifiedField: ValueConvertible?]) {
        for (key, value) in dict {
            valuesByField[key] = value?.sqlValue
        }
    }
}

extension Update: StatementParameterListConvertible {
    public var sqlParameters: [Value?] {
        var parameters = [Value?]()
        
        if let predicate = predicate {
            parameters += predicate.sqlParameters
        }
        
        parameters += valuesByField.values
        
        return parameters
    }
}
