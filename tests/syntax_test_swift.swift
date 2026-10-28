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
// ^^^^^^^^^^^^ storage.type.operator.swift
    higherThan: MultiplicationPrecedence
}
infix operator **: ExponentiationPrecedence
// ^^ storage.modifier.swift
//    ^^^^^^^^ storage.type.operator.swift
//             ^^ keyword.operator.arithmetic.swift
prefix operator +++
// ^^^ storage.modifier.swift
//     ^^^^^^^^ storage.type.operator.swift
postfix operator ---
// ^^^^ storage.modifier.swift
//      ^^^^^^^^ storage.type.operator.swift

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
//            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ string.quoted.double.swift
//                  ^^ constant.character.escape.swift
//                    ^^^^^^^^^ constant.character.escape.swift
//                               ^^ punctuation.section.interpolation.begin.swift
//                                 ^^^^^^^^^^^^^ meta.interpolation.swift
//                                              ^ punctuation.section.interpolation.end.swift
    let raw = #"Raw \#n \#u{1F600} with \#(hex) value"#
//            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ string.quoted.double.raw.swift
//                  ^^^ constant.character.escape.swift
//                      ^^^^^^^^^^ constant.character.escape.swift
//                                      ^^^ punctuation.section.interpolation.begin.swift
    let raw2 = ##"Raw2 \##n \##(hex)"##
//             ^^^^^^^^^^^^^^^^^^^^^^^^ string.quoted.double.raw.swift
//                     ^^^^ constant.character.escape.swift
//                          ^^^^ punctuation.section.interpolation.begin.swift
    let raw3 = ###"Raw3 \###n \###(hex)"###
//             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ string.quoted.double.raw.swift
//                      ^^^^^ constant.character.escape.swift
//                            ^^^^^ punctuation.section.interpolation.begin.swift

    let multi = """
//              ^^^ punctuation.definition.string.begin.swift
        Line 1 \(bin)
//      ^^^^^^^^^^^^^ string.quoted.triple.swift
        """
//      ^^^ punctuation.definition.string.end.swift

    let rawMulti = #"""
//                 ^ punctuation.definition.string.begin.raw.swift
//                  ^^^ punctuation.definition.string.begin.swift
        Raw multiline \#(oct)
//      ^^^^^^^^^^^^^^^^^^^^^ string.quoted.triple.raw.swift
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

let unclosed = "unterminated
//                          ^ invalid.illegal.unclosed-string.swift

/* Outer block comment
   /* Nested block comment */
   Still in outer comment */
// ^^^^^^^^^^^^^^^^^^^^^^ comment.block.swift
