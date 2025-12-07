import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct macroKitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AddSubviewsMacro.self,
        AddToMacro.self,
    ]
}
