// SYNTAX TEST "Swift.sublime-syntax"

// MARK: - Comments & Documentation Tags
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ comment.line.double-slash.mark.swift entity.name.section.mark.swift

/// Documentation line comment with TODO: and tags.
// <- punctuation.definition.comment.documentation.swift
//  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ comment.line.documentation.swift
//                                  ^^^^^ keyword.other.documentation.label.swift
/// - Parameter value: The input value.
//  ^^^^^^^^^^^^^^^^^^ keyword.other.documentation.tag.swift
/// - Returns: A boolean result.
//  ^^^^^^^^^^ keyword.other.documentation.tag.swift
/// - Throws: `NetworkError` on failure.
//  ^^^^^^^^^ keyword.other.documentation.tag.swift

/**/
// <- comment.block.empty.swift punctuation.definition.comment.swift

/**
// <- punctuation.definition.comment.begin.documentation.swift
 * Block documentation comment.
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ comment.block.documentation.swift
 * - Note: Supports /* nested block comments */ inside doc comments.
// ^^^^^^^ keyword.other.documentation.tag.swift
//                  ^^ punctuation.definition.comment.begin.swift
//                                           ^^ punctuation.definition.comment.end.swift
 * FIXME: Check edge cases.
// ^^^^^^ keyword.other.documentation.label.swift
*/
// <- punctuation.definition.comment.end.documentation.swift

// Regular comment with NOTE: label
// <- punctuation.definition.comment.swift
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ comment.line.double-slash.swift
//                      ^^^^^ keyword.other.documentation.label.swift

// MARK: - Imports & Access Control (Swift 6 SE-0409)
public import Foundation
// ^^^ meta.import.swift storage.modifier.access-control.swift
//     ^^^^^^ meta.import.swift keyword.control.import.swift
//            ^^^^^^^^^^ support.type.user-defined.swift

package import struct Observation.ObservationRegistrar
// ^^^^ storage.modifier.access-control.swift
//      ^^^^^^ keyword.control.import.swift
//             ^^^^^^ storage.type.swift

private import func Darwin.nanosleep
// ^^^^ storage.modifier.access-control.swift
//      ^^^^^^ keyword.control.import.swift
//             ^^^^ storage.type.swift

// MARK: - Preprocessor & Compiler Control Directives
#if os(macOS) && arch(arm64) // platform check
// <- meta.preprocessor.conditional.swift keyword.control.directive.conditional.swift
//  ^^ support.function.directive.swift
//     ^^^^^ support.constant.directive.swift
//               ^^^^ support.function.directive.swift
//                    ^^^^^ support.constant.directive.swift
//                           ^^^^^^^^^^^^^^^^^ comment.line.double-slash.swift - meta.preprocessor.conditional.swift
struct PlatformConfig {
// <- meta.declaration.type.struct.swift storage.type.struct.swift
//     ^^^^^^^^^^^^^^ entity.name.type.struct.swift
    var matrix: [3 of Int]
//                 ^^ keyword.operator.word.swift
//                    ^^^ support.type.swift
    func copySelf() -> Self {
//                     ^^^^ variable.language.swift
        return self
//      ^^^^^^ keyword.control.flow.swift
//             ^^^^ variable.language.swift
    }
}
#elseif canImport(UIKit) || compiler(>=6.0) || hasFeature(StrictMemorySafety)
// ^^^^ keyword.control.directive.conditional.swift
//      ^^^^^^^^^ support.function.directive.swift
//                          ^^^^^^^^ support.function.directive.swift
//                                             ^^^^^^^^^^ support.function.directive.swift
#else
// <- keyword.control.directive.conditional.swift
#sourceLocation(file: "Generated.swift", line: 10)
// ^^^^^^^^^^^^ keyword.control.directive.swift
#error("Unsupported platform")
// ^^^ keyword.control.directive.swift
#endif
// <- keyword.control.directive.conditional.swift

// MARK: - Swift 5.9 / 6.0 Macros
@freestanding(expression)
// ^^^^^^^^^^ meta.annotation.macro.swift variable.annotation.macro.swift
//            ^^^^^^^^^^ support.constant.attribute.macro.swift
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "Macros", type: "StringifyMacro")
// ^^^ storage.modifier.access-control.swift
//     ^^^^^ meta.declaration.macro.swift storage.type.macro.swift
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

// MARK: - Declarations (Protocol, Class, Enum, Extension, Typealias, Operator)
public protocol Configurable: Sendable {
// ^^^ storage.modifier.access-control.swift
//     ^^^^^^^^ meta.declaration.type.protocol.swift storage.type.protocol.swift
//              ^^^^^^^^^^^^ entity.name.type.protocol.swift
//                            ^^^^^^^^ support.type.swift
    associatedtype Item: ~Copyable, ~Escapable
//  ^^^^^^^^^^^^^^ meta.declaration.type.typealias.swift storage.type.typealias.swift
//                 ^^^^ entity.name.type.typealias.swift
//                       ^ meta.generic-constraint.suppressed.swift keyword.operator.tilde.suppressed.swift
//                        ^^^^^^^^ support.type.protocol.suppressed.swift
//                                  ^ keyword.operator.tilde.suppressed.swift
//                                   ^^^^^^^^^ support.type.protocol.suppressed.swift
    var count: Int { get throws }
//  ^^^ storage.type.property.swift
//             ^^^ support.type.swift
//                   ^^^ keyword.other.accessor.swift
//                       ^^^^^^ keyword.control.exception.throws.swift
    var name: String { get set }
//                     ^^^ keyword.other.accessor.swift
//                         ^^^ keyword.other.accessor.swift
    subscript(i: Int) -> Int { get nonmutating set }
//                             ^^^ keyword.other.accessor.swift
//                                 ^^^^^^^^^^^ storage.modifier.ownership.swift
//                                             ^^^ keyword.other.accessor.swift
}

package private(set) var packageCounter = 0
// ^^^^ storage.modifier.access-control.swift
//      ^^^^^^^ storage.modifier.access-control.swift
public final private(set) var finalCounter = 0
//     ^^^^^ storage.modifier.swift

public typealias ByteSpan = RawSpan
//     ^^^^^^^^^ meta.declaration.type.typealias.swift storage.type.typealias.swift
//               ^^^^^^^^ entity.name.type.typealias.swift
//                        ^ keyword.operator.assignment.swift
//                          ^^^^^^^ support.type.swift

open class BaseController: NSObject {
// ^ storage.modifier.access-control.swift
//   ^^^^^ meta.declaration.type.class.swift storage.type.class.swift
//         ^^^^^^^^^^^^^^ entity.name.type.class.swift
//                         ^^^^^^^^ support.type.user-defined.swift
    public final var tag: Int = 0
//         ^^^^^ storage.modifier.swift
    internal lazy var cachedName: String = "default"
//  ^^^^^^^^ storage.modifier.access-control.swift
//           ^^^^ storage.modifier.swift
    fileprivate weak var delegate: AnyObject?
//  ^^^^^^^^^^^ storage.modifier.access-control.swift
//              ^^^^ storage.modifier.swift
//                                 ^^^^^^^^^ support.type.swift
//                                          ^ keyword.operator.optional.swift
    private unowned(safe) var owner: AnyObject
//  ^^^^^^^ storage.modifier.access-control.swift
//          ^^^^^^^ storage.modifier.swift
//                  ^^^^ storage.modifier.swift

    public required init?(coder: Any) {
//         ^^^^^^^^ storage.modifier.swift
//                  ^^^^ meta.declaration.function.init.swift storage.type.function.init.swift
//                      ^ keyword.operator.optional.swift
        super.init()
//      ^^^^^ variable.language.swift
//            ^^^^ variable.function.swift
    }

    public convenience init!(flag: Bool) {
//         ^^^^^^^^^^^ storage.modifier.swift
//                     ^^^^ storage.type.function.init.swift
//                         ^ keyword.operator.optional.swift
        self.init(coder: flag)
    }

    open class func classIdentifier() -> String {
//  ^^^^ storage.modifier.access-control.swift
//       ^^^^^ storage.modifier.swift - storage.type.class.swift
//             ^^^^ meta.declaration.function.swift storage.type.function.swift
//                  ^^^^^^^^^^^^^^^ entity.name.function.swift
        return "BaseController"
    }

    open subscript(index: Int) -> Int {
//       ^^^^^^^^^ meta.declaration.function.subscript.swift storage.type.function.subscript.swift
        get { return index }
//      ^^^ keyword.other.accessor.swift
        set(newValue) { _ = newValue }
//      ^^^ keyword.other.accessor.swift
    }
}

public final class DetailController: BaseController {
//     ^^^^^ storage.modifier.swift
//           ^^^^^ storage.type.class.swift
//                 ^^^^^^^^^^^^^^^^ entity.name.type.class.swift
    public override func viewDidLoad() {
//         ^^^^^^^^ storage.modifier.swift
//                  ^^^^ storage.type.function.swift
//                       ^^^^^^^^^^^ entity.name.function.swift
    }
}

public indirect enum BinaryTree<Element: BitwiseCopyable>: ~BitwiseCopyable {
//     ^^^^^^^^ meta.declaration.type.enum.swift storage.modifier.swift
//              ^^^^ storage.type.enum.swift
//                   ^^^^^^^^^^ entity.name.type.enum.swift
//                                       ^^^^^^^^^^^^^^^ support.type.swift
//                                                         ^ keyword.operator.tilde.suppressed.swift
//                                                          ^^^^^^^^^^^^^^^ support.type.protocol.suppressed.swift
    case leaf(Element)
    indirect case node(BinaryTree<Element>, BinaryTree<Element>)
//  ^^^^^^^^ storage.modifier.swift
//           ^^^^ keyword.control.conditional.swift
}

extension BinaryTree.Node {
// ^^^^^^ meta.declaration.type.extension.swift storage.type.extension.swift
//        ^^^^^^^^^^^^^^^ entity.name.type.extension.swift
    mutating func reset() {}
//  ^^^^^^^^ storage.modifier.ownership.swift
    nonmutating func log() {}
//  ^^^^^^^^^^^ storage.modifier.ownership.swift
}

precedencegroup ExponentiationPrecedence {
// ^^^^^^^^^^^^ meta.declaration.precedencegroup.swift storage.type.operator.swift
//              ^^^^^^^^^^^^^^^^^^^^^^^^ meta.declaration.precedencegroup.swift entity.name.type.precedencegroup.swift
    higherThan: MultiplicationPrecedence
//  ^^^^^^^^^^ keyword.other.operator.precedence.swift
    associativity: right
//  ^^^^^^^^^^^^^ keyword.other.operator.precedence.swift
//                 ^^^^^ constant.language.precedence.swift
    assignment: false
//  ^^^^^^^^^^ keyword.other.operator.precedence.swift
//              ^^^^^ constant.language.boolean.swift
}
infix operator **: ExponentiationPrecedence
// ^^ storage.modifier.swift
//    ^^^^^^^^ meta.declaration.operator.swift storage.type.operator.swift
//             ^^ meta.declaration.operator.swift entity.name.function.operator.swift
prefix operator +++
// ^^^ storage.modifier.swift
//     ^^^^^^^^ meta.declaration.operator.swift storage.type.operator.swift
//              ^^^ meta.declaration.operator.swift entity.name.function.operator.swift
postfix operator ---
// ^^^^ storage.modifier.swift
//      ^^^^^^^^ meta.declaration.operator.swift storage.type.operator.swift
//               ^^^ meta.declaration.operator.swift entity.name.function.operator.swift

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

    var observed: Int = 0 {
        willSet(nextVal) { _ = nextVal }
//      ^^^^^^^ keyword.other.accessor.swift
        didSet { _ = observed }
//      ^^^^^^ keyword.other.accessor.swift
    }

    var computed: Int {
        init(initialValue) initializes(handle) accesses(observed) {
//                         ^^^^^^^^^^^ keyword.other.accessor.swift
//                                             ^^^^^^^^ keyword.other.accessor.swift
            handle = initialValue
        }
        get { handle }
//      ^^^ keyword.other.accessor.swift
        set { handle = newValue }
//      ^^^ keyword.other.accessor.swift
    }

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
//  ^^^^^^ meta.declaration.function.deinit.swift storage.type.function.deinit.swift
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
//     ^^^^^^^^^^^ meta.declaration.type.actor.distributed.swift storage.modifier.concurrency.swift
//                 ^^^^^ storage.type.actor.swift
//                       ^^^^^^^^^^ entity.name.type.actor.swift
    nonisolated(unsafe) static var sharedCount: Int = 0
//  ^^^^^^^^^^^ storage.modifier.concurrency.swift
//              ^^^^^^ storage.modifier.concurrency.swift
//                      ^^^^^^ storage.modifier.swift

    nonisolated(nonsending) public func poll() async {}
//  ^^^^^^^^^^^ storage.modifier.concurrency.swift
//              ^^^^^^^^^^ storage.modifier.concurrency.swift
//                                             ^^^^^ storage.modifier.async.swift

    public func execute<Result: Sendable>(
        isolation: isolated (any Actor)? = #isolation,
//                 ^^^^^^^^ storage.modifier.concurrency.swift
//                           ^^^ storage.modifier.type.swift
//                               ^^^^^ support.type.swift
//                                         ^^^^^^^^^^ variable.language.isolation.swift
        operation: @isolated(any) @Sendable () async throws(NetworkError) -> sending Result
//                 ^ meta.annotation.isolated.swift punctuation.definition.annotation.swift
//                  ^^^^^^^^ variable.annotation.swift
//                           ^^^ storage.modifier.type.swift
//                                 ^^^^^^^^ meta.annotation.swift variable.annotation.swift
//                                             ^^^^^ storage.modifier.async.swift
//                                                   ^^^^^^ meta.throws.typed.swift keyword.control.exception.throws.swift
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

    public func makeView() -> some Sendable {
//                            ^^^^ storage.modifier.type.swift
//                                 ^^^^^^^^ support.type.swift
        return 0
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

// MARK: - Control Flow, Error Handling, Closures & Operators
func testControlFlowAndOperators(input: inout Int?) throws -> Int {
//                                      ^^^^^ storage.modifier.ownership.swift
//                                                  ^^^^^^ keyword.control.exception.throws.swift
    defer { input = nil }
//  ^^^^^ keyword.control.flow.swift
//                  ^^^ constant.language.nil.swift

    guard let value = input, value >= 0 else {
//  ^^^^^ keyword.control.conditional.swift
//        ^^^ storage.type.property.swift
//                                 ^^ keyword.operator.comparison.swift
//                                      ^^^^ keyword.control.conditional.swift
        throw NetworkError.invalidPayload
//      ^^^^^ keyword.control.exception.swift
    }

    var total = copy value
//              ^^^^ keyword.operator.word.ownership.swift
    let moved = consume total
//              ^^^^^^^ keyword.operator.word.ownership.swift

    for index in 0..<10 where index != 5 {
//  ^^^ keyword.control.loop.swift
//            ^^ keyword.control.loop.swift
//                ^^^ keyword.operator.range.swift
//                      ^^^^^ keyword.control.conditional.swift
//                                  ^^ keyword.operator.comparison.swift
        if index == 1 {
//      ^^ keyword.control.conditional.swift
//               ^^ keyword.operator.comparison.swift
            continue
//          ^^^^^^^^ keyword.control.loop.swift
        } else if index > 8 {
//        ^^^^ keyword.control.conditional.swift
//             ^^ keyword.control.conditional.swift
            break
//          ^^^^^ keyword.control.loop.swift
        }
    }

    var count = 0
    while count <= 3 && !false || count == 0 {
//  ^^^^^ keyword.control.loop.swift
//              ^^ keyword.operator.comparison.swift
//                   ^^ keyword.operator.logical.swift
//                      ^ keyword.operator.logical.swift
//                       ^^^^^ constant.language.boolean.swift
//                             ^^ keyword.operator.logical.swift
        count += 1
//            ^^ keyword.operator.assignment.compound.swift
    }

    repeat {
//  ^^^^^^ keyword.control.loop.swift - keyword.operator.pack.swift
        count &+= 1
//            ^^^ keyword.operator.assignment.compound.swift
        count &<<= 1
//            ^^^^ keyword.operator.assignment.compound.swift
        count = (count &+ 1) &<< 1
//                     ^^ keyword.operator.arithmetic.swift
//                           ^^^ keyword.operator.arithmetic.swift
    } while count < 2

    switch moved {
//  ^^^^^^ keyword.control.conditional.swift
    case 0...10:
//  ^^^^ keyword.control.conditional.swift
//        ^^^ keyword.operator.range.swift
        fallthrough
//      ^^^^^^^^^^^ keyword.control.loop.swift
    default:
//  ^^^^^^^ keyword.control.conditional.swift
        break
    }

    do {
//  ^^ keyword.control.exception.swift
        let a = try? String(contentsOfFile: "a")
//              ^^^ keyword.control.exception.swift
//                 ^ keyword.operator.try.swift
        let b = try! String(contentsOfFile: "b")
//              ^^^ keyword.control.exception.swift
//                 ^ keyword.operator.try.swift
        _ = (a ?? b) as? String ?? (b as! String)
//             ^^ keyword.operator.nil-coalescing.swift
//                   ^^ keyword.operator.word.cast.swift
//                     ^ keyword.operator.optional.swift
//                                    ^^ keyword.operator.word.cast.swift
//                                      ^ keyword.operator.optional.swift
        if a is String && (a as AnyObject) === (b as AnyObject) || (a as AnyObject) !== (b as AnyObject) {
//           ^^ keyword.operator.word.cast.swift
//                                         ^^^ keyword.operator.comparison.swift
//                                                                                  ^^^ keyword.operator.comparison.swift
        }
    } catch {
//    ^^^^^ keyword.control.exception.swift
    }

    let closure: (Int) -> Int = { [weak delegate, unowned(unsafe) owner] in
//                                 ^^^^ storage.modifier.swift
//                                                ^^^^^^^ storage.modifier.swift
//                                                        ^^^^^^ storage.modifier.swift
        _ = (delegate, owner, $wrapper)
//                            ^^^^^^^^ variable.other.projected.swift
        return $0 + 1
//             ^^ variable.language.anonymous.swift
    }
    return closure(moved)
}

// MARK: - Literals, Strings, Interpolations & Regex
func testLiterals() {
    let bin = 0b1010_0101
//            ^^^^^^^^^^^ constant.numeric.integer.binary.swift
    let oct = 0o755
//            ^^^^^ constant.numeric.integer.octal.swift
    let hex = 0xFF_EC_00
//            ^^^^^^^^^^ constant.numeric.integer.hexadecimal.swift
    let hfl = 0x1.fp-2
//            ^^^^^^^^ constant.numeric.float.hexadecimal.swift
    let flt = 3.14159e-2
//            ^^^^^^^^^^ constant.numeric.float.decimal.swift
    let msg = "Hello\n\u{1F600}, \(bin + (1 + 2))!"
//            ^^^^^^^^^^^^^^^^^^^ string.quoted.double.swift - meta.interpolation
//                  ^^ constant.character.escape.swift
//                    ^^^^^^^^^ constant.character.escape.swift
//                               ^^ meta.interpolation.swift punctuation.section.interpolation.begin.swift - string
//                                 ^^^^^^^^^^^^^ meta.interpolation.swift source.swift.embedded.swift - string
//                                              ^ meta.interpolation.swift punctuation.section.interpolation.end.swift - string
//                                               ^^ string.quoted.double.swift - meta.interpolation
    let raw = #"Raw \#n \#u{1F600} with \#(hex) value"#
//            ^^^^^^^^^^^^^^^^^^^^^^^^^^ string.quoted.double.raw.swift - meta.interpolation
//                  ^^^ constant.character.escape.swift
//                      ^^^^^^^^^^ constant.character.escape.swift
//                                      ^^^ meta.interpolation.swift punctuation.section.interpolation.begin.swift - string
//                                         ^^^ meta.interpolation.swift source.swift.embedded.swift - string
//                                            ^ meta.interpolation.swift punctuation.section.interpolation.end.swift - string
//                                             ^^^^^^^^ string.quoted.double.raw.swift - meta.interpolation
    let raw2 = ##"Raw2 \##n \##(hex)"##
//             ^^^^^^^^^^^^^ string.quoted.double.raw.swift - meta.interpolation
//                     ^^^^ constant.character.escape.swift
//                          ^^^^ meta.interpolation.swift punctuation.section.interpolation.begin.swift - string
//                              ^^^ meta.interpolation.swift source.swift.embedded.swift - string
//                                 ^ meta.interpolation.swift punctuation.section.interpolation.end.swift - string
//                                  ^^^ string.quoted.double.raw.swift - meta.interpolation
    let raw3 = ###"Raw3 \###n \###(hex)"###
//             ^^^^^^^^^^^^^^^ string.quoted.double.raw.swift - meta.interpolation
//                      ^^^^^ constant.character.escape.swift
//                            ^^^^^ meta.interpolation.swift punctuation.section.interpolation.begin.swift - string
//                                 ^^^ meta.interpolation.swift source.swift.embedded.swift - string
//                                    ^ meta.interpolation.swift punctuation.section.interpolation.end.swift - string
//                                     ^^^^ string.quoted.double.raw.swift - meta.interpolation

    let multi = """
//              ^^^ punctuation.definition.string.begin.swift
        Line 1 \(bin)
//      ^^^^^^^ string.quoted.triple.swift - meta.interpolation
//             ^^ meta.interpolation.swift punctuation.section.interpolation.begin.swift - string
//               ^^^ meta.interpolation.swift source.swift.embedded.swift - string
//                  ^ meta.interpolation.swift punctuation.section.interpolation.end.swift - string
        """
//      ^^^ punctuation.definition.string.end.swift

    let rawMulti = #"""
//                 ^ punctuation.definition.string.begin.raw.swift
//                  ^^^ punctuation.definition.string.begin.swift
        Raw multiline \#(oct)
//      ^^^^^^^^^^^^^^ string.quoted.triple.raw.swift - meta.interpolation
//                    ^^^ meta.interpolation.swift punctuation.section.interpolation.begin.swift - string
//                       ^^^ meta.interpolation.swift source.swift.embedded.swift - string
//                          ^ meta.interpolation.swift punctuation.section.interpolation.end.swift - string
        """#
//      ^^^ punctuation.definition.string.end.swift
//         ^ punctuation.definition.string.end.raw.swift

    let rx1 = /[a-zA-Z_][a-zA-Z0-9_]*/
//            ^ punctuation.definition.string.begin.regexp.swift
//             ^^^^^^^^^^^^^^^^^^^^^^ string.regexp.swift
//                                   ^ punctuation.definition.string.end.regexp.swift
    let rx2 = #/\d{4}-\d{2}-\d{2}/#
//            ^^^^^^^^^^^^^^^^^^^^^ string.regexp.extended.swift
//              ^^ constant.character.escape.regexp.swift
    let rx3 = #/#[0-9a-f]{6}/#
//            ^^^^^^^^^^^^^^^^ string.regexp.extended.swift - comment
//                          ^^ punctuation.definition.string
    let rx4 = #/
        \d{4} # year comment
//      ^^ constant.character.escape.regexp.swift
//            ^^^^^^^^^^^^^^ comment.line.number-sign.regexp.swift
    /#
//  ^^ punctuation.definition.string
    let rx5 = ##/\d+/#still_regex/##
//            ^^^^^^^^^^^^^^^^^^^^^^ string.regexp.extended.swift - comment

    let div1 = bin/2 + oct/4 + (bin + 1)/2 + [1, 2][0]/2
//                ^ keyword.operator.arithmetic.swift - string.regexp
//                        ^ keyword.operator.arithmetic.swift - string.regexp
//                                      ^ keyword.operator.arithmetic.swift - string.regexp
//                                                    ^ keyword.operator.arithmetic.swift - string.regexp
    let nestedTuple = ((10, 20), 30)
    let elem = nestedTuple.0.1/2
//                        ^ punctuation.accessor.dot.swift
//                         ^ constant.numeric.integer.decimal.swift - constant.numeric.float
//                          ^ punctuation.accessor.dot.swift
//                           ^ constant.numeric.integer.decimal.swift - constant.numeric.float
//                            ^ keyword.operator.arithmetic.swift - string.regexp

    if #available(macOS 15, *) {
//     ^^^^^^^^^^ keyword.control.directive.available.swift
        #warning("check availability")
//      ^^^^^^^^ keyword.control.directive.swift
    }
    if #unavailable(iOS 16) {
//     ^^^^^^^^^^^^ keyword.control.directive.available.swift
    }

    let loc = (#file, #fileID, #filePath, #line, #column, #function, #dsohandle)
//             ^^^^^ constant.language.magic.swift
//                    ^^^^^^^ constant.language.magic.swift
//                             ^^^^^^^^^ constant.language.magic.swift
//                                        ^^^^^ constant.language.magic.swift
//                                               ^^^^^^^ constant.language.magic.swift
//                                                        ^^^^^^^^^ constant.language.magic.swift
//                                                                   ^^^^^^^^^^ constant.language.magic.swift
    let kp = #keyPath(NSObject.description)
//           ^^^^^^^^ support.function.magic.swift
    let sel = #selector(BaseController.viewDidLoad)
//            ^^^^^^^^^ support.function.magic.swift

    #expect(bin == 165)
//  ^ meta.macro.expansion.swift punctuation.definition.macro.swift
//   ^^^^^^ support.function.macro.swift

    let expanded = #Macros.stringify(bin)
//                 ^ punctuation.definition.macro.swift
//                  ^^^^^^ support.other.module.swift
//                        ^ punctuation.accessor.dot.swift
//                         ^^^^^^^^^ support.function.macro.swift

    let qualified = CoreModule::compute(bin)
//                            ^^ punctuation.accessor.module.swift
//                              ^^^^^^^ variable.function.swift
}

// MARK: - Unicode Identifiers, Contextual Keywords & Accessors Regression
struct 坐标 {
//     ^^ entity.name.type.struct.swift
    func 计算总价(of item: Int) -> Int {
//       ^^^^ entity.name.function.swift
//            ^^ - keyword.operator.word.swift
        return item
    }
}

func testContextualKeywords() {
    let package = 1
//      ^^^^^^^ - storage.modifier
    let open = 1
//      ^^^^ - storage.modifier
    let prefix = "http"
//      ^^^^^^ - storage.modifier
    let postfix = "end"
//      ^^^^^^^ - storage.modifier
    let optional = true
//      ^^^^^^^^ - storage.modifier
    let lazy = false
//      ^^^^ - storage.modifier
    let dynamic = 0
//      ^^^^^^^ - storage.modifier
    let weak = 0
//      ^^^^ - storage.modifier
    let unowned = 0
//      ^^^^^^^ - storage.modifier
    let final = 0
//      ^^^^^ - storage.modifier
    let override = 0
//      ^^^^^^^^ - storage.modifier
    let required = 0
//      ^^^^^^^^ - storage.modifier
    let convenience = 0
//      ^^^^^^^^^^^ - storage.modifier
    let consuming = 2
//      ^^^^^^^^^ - storage.modifier
    for each in [1, 2] {
//      ^^^^ - keyword.operator.pack.swift
        _ = each
//      ^ variable.language.wildcard.swift
    }
    for actor in [1, 2] {
//      ^^^^^ - storage.type.actor.swift
//            ^^ keyword.control.loop.swift - entity.name.type
        _ = actor
    }
    for macro in [1, 2] {
//      ^^^^^ - storage.type.macro.swift
//            ^^ keyword.control.loop.swift - entity.name.function
        _ = macro
    }
    let val = worker.sending
//                   ^^^^^^^ - storage.modifier
    worker.borrowing()
//         ^^^^^^^^^ variable.function.swift - storage.modifier
    let ptr = unsafe getPointer()
//            ^^^^^^ keyword.operator.word.unsafe.swift
    var sum = 0
    sum &+= 1
//      ^^^ keyword.operator.assignment.compound.swift
    let mask = ~UInt32(0)
//             ^ keyword.operator.bitwise.swift - keyword.operator.tilde.suppressed.swift
    let seq = repeatElement(1, count: 3)
//            ^^^^^^^^^^^^^ support.function.builtin.swift
    let get = 1, set = 2
//      ^^^ - keyword.other.accessor.swift
//               ^^^ - keyword.other.accessor.swift
    let forced = ptr!/2 + val/2
//                  ^ keyword.operator.logical.swift
//                   ^ keyword.operator.arithmetic.swift - string.regexp
//                           ^ keyword.operator.arithmetic.swift - string.regexp
}

struct StorageView {
    var item: Int {
        yielding borrow {
//      ^^^^^^^^ storage.modifier.ownership.swift
//               ^^^^^^ keyword.other.accessor.swift
            yield 0
//          ^^^^^ keyword.control.flow.swift
        }
        mutate {
//      ^^^^^^ keyword.other.accessor.swift
        }
    }
}

actor LocalCounter {
// <- meta.declaration.type.actor.swift storage.type.actor.swift
//    ^^^^^^^^^^^^ entity.name.type.actor.swift
//                 ^ punctuation.section.block.begin.swift
    func record(pair: (Int, Int), list: [Int]) {
//                  ^ punctuation.separator.colon.swift
//                    ^ punctuation.section.parens.begin.swift
//                        ^ punctuation.separator.comma.swift
//                             ^ punctuation.section.parens.end.swift
//                                      ^ punctuation.section.brackets.begin.swift
//                                          ^ punctuation.section.brackets.end.swift
        let a = 1; _ = a
//               ^ punctuation.terminator.statement.swift
    }
}
// <- punctuation.section.block.end.swift

// MARK: - Swift 6.3 & 6.4 Features (~Sendable, anyAppleOS, RigidArray, Concurrency)
import Synchronization
// <- meta.import.swift keyword.control.import.swift
//     ^^^^^^^^^^^^^^^ support.type.user-defined.swift

@available(anyAppleOS 26.0, iOS 18.2.1, introduced: 18.0, deprecated, noasync, *)
// ^^^^^^^ meta.annotation.swift variable.annotation.swift
//         ^^^^^^^^^^ meta.availability.swift support.constant.directive.swift
//                    ^^^^ constant.numeric.float.decimal.swift
//                          ^^^ support.constant.directive.swift
//                              ^^^^^^ constant.numeric.float.decimal.swift
//                                      ^^^^^^^^^^ support.constant.attribute.availability.swift
//                                                        ^^^^^^^^^^ support.constant.attribute.availability.swift
//                                                                    ^^^^^^^ support.constant.attribute.availability.swift
//                                                                             ^ meta.availability.swift constant.language.wildcard.swift - keyword.operator.arithmetic.swift
public class NonSendableToken: ~Sendable {
//           ^^^^^^^^^^^^^^^^ entity.name.type.class.swift
//                             ^ meta.generic-constraint.suppressed.swift keyword.operator.tilde.suppressed.swift
//                              ^^^^^^^^ meta.generic-constraint.suppressed.swift support.type.protocol.suppressed.swift
    var buffer: RigidArray<Int>
//              ^^^^^^^^^^ support.type.swift
    var fixed: InlineArray<4, Int>
//             ^^^^^^^^^^^ support.type.swift
    var span: Span<Int>
//            ^^^^ support.type.swift
    var mspan: MutableSpan<Int>
//             ^^^^^^^^^^^ support.type.swift
    var mrspan: MutableRawSpan
//              ^^^^^^^^^^^^^^ support.type.swift
    var text: UTF8Span
//            ^^^^^^^^ support.type.swift
    var indices: RangeSet<Int>
//               ^^^^^^^^ support.type.swift
    var slice: DiscontiguousSlice<Array<Int>>
//             ^^^^^^^^^^^^^^^^^^ support.type.swift
    var handle: OpaquePointer?
//              ^^^^^^^^^^^^^ support.type.swift
    var counter: Atomic<Int>
//               ^^^^^^ support.type.swift
    var lock: Mutex<Int>
//            ^^^^^ support.type.swift
    var lazyRef: AtomicLazyReference<NonSendableToken>
//               ^^^^^^^^^^^^^^^^^^^ support.type.swift

    isolated deinit {
//  ^^^^^^^^ storage.modifier.concurrency.swift
//           ^^^^^^ storage.type.function.deinit.swift
    }
}

@diagnose(DeprecatedDeclaration, as: warning, reason: "legacy")
// ^^^^^^ meta.annotation.swift variable.annotation.swift
//                               ^^ - keyword.operator.word.cast.swift
//                                                    ^^^^^^^^ string.quoted.double.swift
@available(
    anyAppleOS 26.0, // replaces oldAPI()
//  ^^^^^^^^^^ meta.availability.swift support.constant.directive.swift
//                   ^^^^^^^^^^^^^^^^^^^^ comment.line.double-slash.swift
    *
//  ^ meta.availability.swift constant.language.wildcard.swift - keyword.operator.arithmetic.swift
)
@backDeployed(before: anyAppleOS 26.0)
// ^^^^^^^^^^ meta.annotation.swift variable.annotation.swift
//            ^^^^^^ meta.availability.swift support.constant.attribute.availability.swift
//                    ^^^^^^^^^^ meta.availability.swift support.constant.directive.swift
//                               ^^^^ constant.numeric.float.decimal.swift
public func runShieldedWork() async {
    #if anyAppleOS && compiler(>=6.3.1)
//  ^^^ keyword.control.directive.conditional.swift
//      ^^^^^^^^^^ support.constant.directive.swift
//                    ^^^^^^^^ support.function.directive.swift
//                            ^ punctuation.section.parens.begin.swift
//                               ^^^^^ constant.numeric.float.decimal.swift
//                                    ^ punctuation.section.parens.end.swift
    if #available(anyAppleOS 26.0, macOS 26.4, *) {
//     ^^^^^^^^^^ keyword.control.directive.available.swift
//                ^^^^^^^^^^ meta.availability.swift support.constant.directive.swift
//                           ^^^^ constant.numeric.float.decimal.swift
//                                 ^^^^^ support.constant.directive.swift
        await withTaskCancellationShield {
//            ^^^^^^^^^^^^^^^^^^^^^^^^^^ support.function.builtin.swift
            await withTaskPriorityEscalationHandler {
//                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ support.function.builtin.swift
            } onPriorityEscalated: { _, _ in }
        }
        await withTaskExecutorPreference(nil) {
//            ^^^^^^^^^^^^^^^^^^^^^^^^^^ support.function.builtin.swift
            await withDeadline(in: .now) {
//                ^^^^^^^^^^^^ support.function.builtin.swift
//                             ^^ - keyword.control.loop.swift
            }
        }
    }
    #endif

    withUnsafeTemporaryAllocation(of: Int.self, capacity: 4) { _ in }
//  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ support.function.builtin.swift

    do throws(CancellationError) {
//  ^^ keyword.control.exception.swift
//     ^^^^^^ meta.throws.typed.swift keyword.control.exception.throws.swift
//            ^^^^^^^^^^^^^^^^^ support.type.swift
    } catch {
//    ^^^^^ keyword.control.exception.swift
    }

    let metatype: Int.Type = Int.self
//                    ^^^^ variable.language.swift
//                               ^^^^ variable.language.swift
    let protoType: Sendable.Protocol = Sendable.self
//                          ^^^^^^^^ variable.language.swift
//                                              ^^^^ variable.language.swift
    let cont = """
        line one \  
//               ^^^ constant.character.escape.swift
        line two
        """
    _ = (metatype, protoType, cont)
}

public struct FixedBuffer<let N: Int>: ~Copyable {
//            ^^^^^^^^^^^ entity.name.type.struct.swift
//                        ^^^ storage.type.property.swift
//                               ^^^ support.type.swift
//                                     ^ meta.generic-constraint.suppressed.swift keyword.operator.tilde.suppressed.swift
//                                      ^^^^^^^^ meta.generic-constraint.suppressed.swift support.type.protocol.suppressed.swift
    public func `run benchmark`() {}
//              ^^^^^^^^^^^^^^^ entity.name.function.swift
    public func testRawIdentifiers() {
        `run benchmark`()
//      ^^^^^^^^^^^^^^^ variable.function.swift
        self.`run benchmark`()
//      ^^^^ variable.language.swift
//           ^^^^^^^^^^^^^^^ variable.function.swift
        _ = self.`$raw property`
//               ^^^^^^^^^^^^^^^ variable.other.projected.swift
        let borrowing = Optional(1)
        guard let borrowing else { return }
//                ^^^^^^^^^ - storage.modifier
        if case let consuming = borrowing where consuming > 0 {
//                  ^^^^^^^^^ - storage.modifier
            _ = consuming
        }
    }
}

public protocol BorrowableContainer: ~Copyable {
    var element: Int { borrow mutate }
//                     ^^^^^^ keyword.other.accessor.swift
//                            ^^^^^^ keyword.other.accessor.swift
}

let unclosed = "unterminated
//                          ^ invalid.illegal.unclosed-string.swift
let unclosedEsc = "unterminated \
//                               ^ invalid.illegal.unclosed-string.swift
let afterUnclosed = 42
// <- storage.type.property.swift - string.quoted.double.swift
let unclosedInterp = "unterminated \((1 + 2
//                                 ^^ meta.interpolation.swift punctuation.section.interpolation.begin.swift - string
//                                   ^^^^^^ meta.interpolation.swift source.swift.embedded.swift - string
//                                         ^ invalid.illegal.unclosed-string.swift
let afterUnclosedInterp = 99
// <- storage.type.property.swift - string.quoted.double.swift - meta.interpolation.swift
let unclosedInterpQuote = "x\(foo"
//                          ^^ meta.interpolation.swift punctuation.section.interpolation.begin.swift - string
//                            ^^^ meta.interpolation.swift source.swift.embedded.swift - string
//                               ^ string.quoted.double.swift punctuation.definition.string.end.swift - meta.interpolation
let afterUnclosedInterpQuote = 100
// <- storage.type.property.swift - string.quoted.double.swift - meta.interpolation.swift

// MARK: - V2 Review Regressions (Nested Generics, Keyword Labels, Custom Operators & Extensions)
infix operator <=>: ExponentiationPrecedence
// ^^ storage.modifier.swift
//    ^^^^^^^^ meta.declaration.operator.swift storage.type.operator.swift
//             ^^^ meta.declaration.operator.swift entity.name.function.operator.swift
prefix operator √
// ^^^ storage.modifier.swift
//     ^^^^^^^^ meta.declaration.operator.swift storage.type.operator.swift
//              ^ meta.declaration.operator.swift entity.name.function.operator.swift

prefix func √(x: Double) -> Double { x }
// ^^^ storage.modifier.swift
//     ^^^^ meta.declaration.function.swift storage.type.function.swift
//          ^ meta.declaration.function.swift entity.name.function.swift

func <=> (lhs: Int, rhs: Int) -> Int { lhs - rhs }
// ^ meta.declaration.function.swift storage.type.function.swift
//   ^^^ meta.declaration.function.swift entity.name.function.swift

extension [String] {
// ^^^^^^ meta.declaration.type.extension.swift storage.type.extension.swift
//        ^ punctuation.section.brackets.begin.swift
//         ^^^^^^ support.type.swift
//               ^ punctuation.section.brackets.end.swift
}

extension SwiftUI::View {
// ^^^^^^ meta.declaration.type.extension.swift storage.type.extension.swift
//        ^^^^^^^^^^^^^ meta.declaration.type.extension.swift entity.name.type.extension.swift
//               ^^ punctuation.accessor.module.swift
}

class EdgeCaseClass {
    class final func typeMethod() {}
//  ^^^^^ storage.modifier.swift - meta.declaration.type.class.swift
//        ^^^^^ storage.modifier.swift - entity.name.type.class.swift
//              ^^^^ meta.declaration.function.swift storage.type.function.swift
//                   ^^^^^^^^^^ meta.declaration.function.swift entity.name.function.swift
}

func testKeywordLabels(default: Int, case c: Int, class k: Int, in y: Int) -> Int {
//                     ^^^^^^^ - keyword
//                                   ^^^^ - keyword
//                                                ^^^^^ - storage - meta.declaration.type.class.swift
//                                                      ^ - entity.name
//                                                              ^^ - keyword.control.loop.swift
    let nestedDict: Dictionary<String, Array<Int>> = [:]
//                                              ^^ - keyword.operator.bitwise.swift
    let nestedSet = Set<Set<Int>>()
//                             ^^ - keyword.operator.bitwise.swift
    let shifted = 16 >> 2
//                   ^^ keyword.operator.bitwise.swift
    var counts: [String: Int] = [:]
    counts["a", default: 0] += 1
//              ^^^^^^^ - keyword.control.conditional.swift
    let async = 1
//      ^^^^^ - storage.modifier.async.swift
    let get = 2
//      ^^^ - keyword.other.accessor.swift
    if async < get && get > 0 && (1...5 ~= async) {
//           ^ keyword.operator.comparison.swift
//                        ^ keyword.operator.comparison.swift
//                                      ^^ keyword.operator.comparison.swift
        _ = (nestedDict, nestedSet, shifted, √4.0, 1 <=> 2)
//                                           ^ keyword.operator.custom.swift
//                                                   ^^^ keyword.operator.custom.swift
    }
    return get
//         ^^^ - keyword.other.accessor.swift
}

// MARK: - V2 Fix Review Regressions (label heuristics must not break switch/case, packs, where, or type names)
func testLabelHeuristicRegressions(value: Int, opt: Int?) {
    switch value {
    case kMax: print("max")
//  ^^^^ keyword.control.conditional.swift
    default: print("other")
//  ^^^^^^^ keyword.control.conditional.swift
    }
    switch value { case 1: f(); default: g() }
//                 ^^^^ keyword.control.conditional.swift
//                              ^^^^^^^ keyword.control.conditional.swift
    switch value {
    default: total = 1
//  ^^^^^^^ keyword.control.conditional.swift
    }
    let isNone = opt==.none
//                  ^^ keyword.operator.comparison.swift - keyword.operator.assignment
    let bounded = value<=.max
//                     ^^ keyword.operator.comparison.swift - keyword.operator.custom
    _ = (isNone, bounded)
}

func allEqual<each T: Equatable>(_ lhs: repeat each T, _ rhs: repeat each T) -> Bool { true }
//            ^^^^ keyword.operator.pack.swift
func pair<T>(_ a: T) -> T where T: Hashable, T.Element == (Int, Int)
//                        ^^^^^ keyword.control.conditional.swift

enum Kind: String // values (a, b)
//   ^^^^ entity.name.type.enum.swift
//       ^ - entity.name
protocol Store: AnyObject where Item == (Int, Int)
//       ^^^^^ entity.name.type.protocol.swift
//            ^ - entity.name

func labelKeywords(class key: Int, struct item: Int, in context: Int, default value: Int) {}
//                 ^^^^^^^^^ - storage - entity.name
//                                 ^^^^^^^^^^^ - storage - entity.name
//                                                   ^^ - keyword
//                                                                    ^^^^^^^ - keyword
func multilineLabels(
    class key: Int,
//  ^^^^^^^^^ - storage - entity.name
    struct item: Int,
//  ^^^^^^^^^^^ - storage - entity.name
    case kind: Int,
//  ^^^^ - keyword
    where pred: Bool,
//  ^^^^^ - keyword
    in context: Int,
//  ^^ - keyword
    default value: Int = 0
//  ^^^^^^^ - keyword
) {}
let labeledTuple: (in: Int, for: Int) = (in: 1, for: 2)
//                 ^^ - keyword
//                          ^^^ - keyword
let interpLabel = "\(value, default: 0) \(foo(default: 1))"
//                          ^^^^^^^ - keyword
//                                            ^^^^^^^ - keyword
if case .a = x, case .b = y {}
//              ^^^^ keyword.control.conditional.swift

/* Outer block comment
   /* Nested block comment */
   Still in outer comment */
// ^^^^^^^^^^^^^^^^^^^^^^ comment.block.swift

infix operator ⁂: ExponentiationPrecedence
//             ^ meta.declaration.operator.swift entity.name.function.operator.swift
infix operator .+.
//             ^^^ meta.declaration.operator.swift entity.name.function.operator.swift

enum Direction: CaseIterable {
//              ^^^^^^^^^^^^ support.type.swift
    case north, south
}

func testKeyPathsAndCustomOps(_ a: Int, _ b: Int, assignment: Int, higherThan: Int) -> Int {
//                                                ^^^^^^^^^^ - keyword.other.operator.precedence.swift
//                                                                 ^^^^^^^^^^ - keyword.other.operator.precedence.swift
    let kp1 = \String.count
//            ^ keyword.operator.key-path.swift
//             ^^^^^^ support.type.swift
    let kp2: KeyPath<String, Int> = \.count
//                                  ^ keyword.operator.key-path.swift
//                                   ^ punctuation.accessor.dot.swift
    _ = (kp1, kp2, a <|> b, a |> b, a .+. b)
//                   ^^^ keyword.operator.custom.swift
//                            ^^ keyword.operator.custom.swift
//                                    ^^^ keyword.operator.custom.swift
    return testKeyPathsAndCustomOps(a, b, assignment: 1, higherThan: 2)
//                                        ^^^^^^^^^^ - keyword.other.operator.precedence.swift
//                                                       ^^^^^^^^^^ - keyword.other.operator.precedence.swift
}



