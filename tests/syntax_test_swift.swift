// SYNTAX TEST "Swift.sublime-syntax"

// MARK: - Imports & Access Control (Swift 6 SE-0409)
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ entity.name.section.mark.swift

public import Foundation
// ^^^ storage.modifier.access-control.swift
//     ^^^^^^ keyword.control.import.swift
//            ^^^^^^^^^^ support.type.user-defined.swift

package import struct Observation.ObservationRegistrar
// ^^^^ storage.modifier.access-control.swift
//      ^^^^^^ keyword.control.import.swift
//             ^^^^^^ storage.type.swift

// MARK: - Swift 5.9 / 6.0 Macros
@freestanding(expression)
// ^^^^^^^^^^ variable.annotation.macro.swift
//            ^^^^^^^^^^ support.constant.attribute.macro.swift
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "Macros", type: "StringifyMacro")
// ^^^ storage.modifier.access-control.swift
//     ^^^^^ storage.type.macro.swift
//           ^^^^^^^^^ entity.name.function.macro.swift
//                                    ^^ punctuation.separator.return-type.swift
//                                           ^^^^^^ support.type.swift
//                                                     ^^^^^^^^^^^^^^ support.function.magic.swift

@attached(member, names: named(init), arbitrary)
// ^^^^^^ variable.annotation.macro.swift
//        ^^^^^^ support.constant.attribute.macro.swift
//                ^^^^^ support.constant.attribute.macro.swift
//                       ^^^^^ support.constant.attribute.macro.swift
//                                    ^^^^^^^^^ support.constant.attribute.macro.swift
public macro AddInit() = #externalMacro(module: "Macros", type: "AddInitMacro")

// MARK: - Ownership & Noncopyable Types (~Copyable, ~Escapable)
package struct UniqueResource<T: ~Copyable>: ~Copyable, Sendable {
// ^^^^ storage.modifier.access-control.swift
//      ^^^^^^ storage.type.struct.swift
//             ^^^^^^^^^^^^^^ entity.name.type.struct.swift
//                               ^ keyword.operator.tilde.suppressed.swift
//                                ^^^^^^^^ support.type.protocol.suppressed.swift
//                                           ^ keyword.operator.tilde.suppressed.swift
//                                            ^^^^^^^^ support.type.protocol.suppressed.swift
//                                                      ^^^^^^^^ support.type.swift
    private(set) var handle: Int
//  ^^^^^^^ storage.modifier.access-control.swift
//          ^^^ keyword.other.accessor.swift
//               ^^^ storage.type.property.swift
//                           ^^^ support.type.swift

    public init(_ initial: consuming T) {
//         ^^^^ storage.type.function.init.swift
//                         ^^^^^^^^^ storage.modifier.ownership.swift
        self.handle = 0
//      ^^^^ variable.language.swift
//                    ^ constant.numeric.integer.decimal.swift
    }

    public borrowing func inspect() -> Bool {
//         ^^^^^^^^^ storage.modifier.ownership.swift
//                   ^^^^ storage.type.function.swift
//                        ^^^^^^^ entity.name.function.swift
        return true
//      ^^^^^^ keyword.control.flow.swift
//             ^^^^ constant.language.boolean.swift
    }

    public consuming func close() {
//         ^^^^^^^^^ storage.modifier.ownership.swift
        discard self
//      ^^^^^^^ keyword.operator.word.ownership.swift
//              ^^^^ variable.language.swift
    }

    deinit {
//  ^^^^^^ storage.type.function.deinit.swift
    }
}

// MARK: - Swift 6 Concurrency, Isolation & Typed Throws
public enum NetworkError: Error, Sendable {
//     ^^^^ storage.type.enum.swift
//          ^^^^^^^^^^^^ entity.name.type.enum.swift
    case timeout(Duration)
//  ^^^^ keyword.control.conditional.swift
//               ^^^^^^^^ support.type.swift
    case invalidPayload
}

public distributed actor WorkerNode {
//     ^^^^^^^^^^^ storage.modifier.concurrency.swift
//                 ^^^^^ storage.type.actor.swift
//                       ^^^^^^^^^^ entity.name.type.actor.swift
    nonisolated(unsafe) static var sharedCount: Int = 0
//  ^^^^^^^^^^^ storage.modifier.concurrency.swift
//              ^^^^^^ storage.modifier.concurrency.swift
//                      ^^^^^^ storage.modifier.swift

    public func execute<Result: Sendable>(
        isolation: isolated (any Actor)? = #isolation,
//                 ^^^^^^^^ storage.modifier.concurrency.swift
//                           ^^^ storage.modifier.type.swift
//                               ^^^^^ support.type.swift
//                                         ^^^^^^^^^^ variable.language.isolation.swift
        operation: @isolated(any) @Sendable () async throws(NetworkError) -> sending Result
//                 ^ punctuation.definition.annotation.swift
//                  ^^^^^^^^ variable.annotation.swift
//                           ^^^ storage.modifier.type.swift
//                                 ^^^^^^^^ variable.annotation.swift
//                                             ^^^^^ storage.modifier.async.swift
//                                                   ^^^^^^ keyword.control.exception.throws.swift
//                                                          ^^^^^^^^^^^^ support.type.user-defined.swift
//                                                                           ^^^^^^^ storage.modifier.concurrency.swift
    ) async throws(NetworkError) -> sending Result {
//    ^^^^^ storage.modifier.async.swift
//          ^^^^^^ keyword.control.exception.throws.swift
//                 ^^^^^^^^^^^^ support.type.user-defined.swift
//                                  ^^^^^^^ storage.modifier.concurrency.swift
        return try await operation()
//             ^^^ keyword.control.exception.swift
//                 ^^^^^ keyword.control.flow.await.swift
    }
}

// MARK: - Parameter Packs (Variadic Generics)
func pairUp<each T, each U>(
//          ^^^^ keyword.operator.pack.swift
//                  ^^^^ keyword.operator.pack.swift
    first: repeat each T,
//         ^^^^^^ keyword.operator.pack.swift
//                ^^^^ keyword.operator.pack.swift
    second: repeat each U
) -> (repeat (each T, each U)) {
//    ^^^^^^ keyword.operator.pack.swift
    return (repeat (each first, each second))
//          ^^^^^^ keyword.operator.pack.swift
//                  ^^^^ keyword.operator.pack.swift
}

// MARK: - Literals, Strings, Interpolations & Regex
func testLiterals() {
    let bin = 0b1010_0101
//            ^^^^^^^^^^^ constant.numeric.integer.binary.swift
    let oct = 0o755
//            ^^^^^ constant.numeric.integer.octal.swift
    let hex = 0xFF_EC_00
//            ^^^^^^^^^^ constant.numeric.integer.hexadecimal.swift
    let flt = 3.14159e-2
//            ^^^^^^^^^^ constant.numeric.float.decimal.swift
    let msg = "Hello, \(bin + 1)!"
//            ^^^^^^^^^^^^^^^^^^^^ string.quoted.double.swift
//                    ^^ punctuation.section.interpolation.begin.swift
//                      ^^^^^^^ meta.interpolation.swift
    let raw = #"Raw string with \#(hex) value"#
//            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ string.quoted.double.raw.swift
//                              ^^^ punctuation.section.interpolation.begin.swift
    let rx1 = /[a-zA-Z_][a-zA-Z0-9_]*/
//            ^ punctuation.definition.string.begin.regexp.swift
//             ^^^^^^^^^^^^^^^^^^^^^^ string.regexp.swift
//                                   ^ punctuation.definition.string.end.regexp.swift
    let rx2 = #/\d{4}-\d{2}-\d{2}/#
//            ^^^^^^^^^^^^^^^^^^^^^ string.regexp.extended.swift

    #expect(bin == 165)
//  ^ punctuation.definition.macro.swift
//   ^^^^^^ support.function.macro.swift
}

/* Outer block comment
   /* Nested block comment */
   Still in outer comment */
// ^^^^^^^^^^^^^^^^^^^^^^ comment.block.swift
