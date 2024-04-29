# inno-cli

## Goal
This project was meant to be a CLI utility for executing [Inno Setup](https://github.com/jrsoftware/issrc) installers. The project would implement [required Pascal code](https://github.com/amkillam/inno-cli-ps) for execution of Inno Setup's embedded [Pascal Script](https://github.com/remobjects/pascalscript) bytecode, which would then be compiled and statically linked with the [primary Rust code base](https://github.com/amkillam/inno-cli-rs).

## Results
Results for this project were very mixed. Ultimately, the project was a failure, but could be helpful for others attempting similar projects. In particular, my work to implement basic Rust FFI for Pascal should be helpful to anyone requiring similar functionality in the future.

### Successes

- Implement [Free Pascal](https://github.com/fpc/FPCSource) and Pascal Script data structures in Rust, successfully passed between the linked code compiled from the respective languages.
- Automated static compilation and linking process with Pascal and Rust binaries works seamlessly on GNU targets.
- Executes compiled Pascal Script bytecode as expected.

### Failures
- Crucially, the overall approach of this project was a failure. This project intended to use Pascal Script's `RunProcPN` function to execute the `CurStepChanged` function within Inno Setup's embedded Pascal Script bytecode, to execute the portion of the script which performs the actual installation. Unfortunately, calling `RunProcPN` does not seem work unless the respective `TPSExec` class executing the function is first provided pointers to any procedures or functions called by name with `RunProcPN`. These pointers are automatically made available if `TPSExec` is instantiated by first compiling bytecode, but difficult to programmatically generate otherwise, making this approach impractical.
- Static linking of the InnoCli Pascal library and the inno-cli Rust executable does not work on Windows MSVC targets. The duplicate symbol of `__tls_used` in sysinitpas.o needed by the Pascal runtime and within the generated Rust binary creates a consistent linking error by lld-link. Stripping this symbol from either the Pascal or Rust binaries causes a plethora of errors about undefined symbols in the stripped binary, as the binary relies on [TLS](https://en.wikipedia.org/wiki/Thread-local_storage) to define imported symbols. Neither dynamic linking nor compiling the sysinitpas.o object without usage of TLS remedied the issue; dynamic linking had the same error due to the duplicated `__tls_used` symbol, and using the sysinitpas.o object without TLS caused the same errors as when stripping the `__tls_used` symbol from the provided sysinitpas.o object. This issue in particular is likely fixable given more time, but not worth fixing, as this approach in general is clearly not feasible due to the first failure mentioned.
- As Rust does not use classes, attempting to call functions within a Pascal class is not possible without considerable effort, which is outside the scope of this project. Instead, a workaround was to pass a Pascal class to and from Rust as an opaque struct, and call functions within the class by passing the object to [ simple Pascal functions written only to do so](https://github.com/amkillam/inno-cli-ps/blob/master/src/GenerateExec.pas). However, this is an unnatural usage of Pascal class functions, and as such is a minor failure in the Pascal FFI implementation.
- There is a lot of incomplete code left in the code base which was planned to be for extraction of Inno Setup embedded bytecode, temporary installer files, etc. This code was not completed due to the impractical nature of the project itself.  Instead, the tools mentioned in [Resources](##Resources) were used for incremental testing while this code remained incomplete.

## Resources
The following resources were used in research and testing of this project.

- [Free Pascal](https://github.com/fpc/FPCSource) for compilation of Pascal code
- [Pascal Script](https://github.com/remobjects/pascalscript) for execution of Pascal Script bytecode
- [Innounp](https://github.com/WhatTheBlock/innounp) for extraction of embedded Pascal Script bytecode
- [Innoextract](https://github.com/dscharrer/innoextract) for extraction of Inno Setup installer temporary files
- [Inno Setup](https://github.com/jrsoftware/issrc) for research of source implementation of Inno Setup installers
- [IFPSTools.NET](https://github.com/Wack0/IFPSTools.NET.git) for disassembly of Pascal Script bytecode, helping to better functions called and used
