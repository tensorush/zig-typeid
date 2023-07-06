## :lizard: :id: **zig typeid**

[![CI][ci-shield]][ci-url]
[![CD][cd-shield]][cd-url]
[![Docs][docs-shield]][docs-url]
[![Codecov][codecov-shield]][codecov-url]
[![License][license-shield]][license-url]

### Zig implementation of [TypeID](https://github.com/jetpack-io/typeid), a type-safe extension of UUIDv7, created by the [jetpack.io team](https://www.jetpack.io/).

#### :rocket: Usage

1. Add `typeid` as a dependency in your `build.zig.zon`.

    <details>

    <summary><code>build.zig.zon</code> example</summary>

    ```zig
    .{
        .name = "<name_of_your_package>",
        .version = "<version_of_your_package>",
        .dependencies = .{
            .typeid = .{
                .url = "https://github.com/tensorush/zig-typeid/archive/<git_tag_or_commit_hash>.tar.gz",
                .hash = "<package_hash>",
            },
        },
    }
    ```

    Set `<package_hash>` to `12200000000000000000000000000000000000000000000000000000000000000000`, and Zig will provide the correct found value in an error message.

    </details>

2. Add `typeid` as a module in your `build.zig`.

    <details>

    <summary><code>build.zig</code> example</summary>

    ```zig
    const typeid = b.dependency("typeid", .{});
    exe.addModule("typeid", typeid.module("typeid"));
    ```

    </details>

<!-- MARKDOWN LINKS -->

[ci-shield]: https://img.shields.io/github/actions/workflow/status/tensorush/zig-typeid/ci.yaml?branch=main&style=for-the-badge&logo=github&label=CI&labelColor=black
[ci-url]: https://github.com/tensorush/zig-typeid/blob/main/.github/workflows/ci.yaml
[cd-shield]: https://img.shields.io/github/actions/workflow/status/tensorush/zig-typeid/cd.yaml?branch=main&style=for-the-badge&logo=github&label=CD&labelColor=black
[cd-url]: https://github.com/tensorush/zig-typeid/blob/main/.github/workflows/cd.yaml
[docs-shield]: https://img.shields.io/badge/click-F6A516?style=for-the-badge&logo=zig&logoColor=F6A516&label=docs&labelColor=black
[docs-url]: https://tensorush.github.io/zig-typeid
[codecov-shield]: https://img.shields.io/codecov/c/github/tensorush/zig-typeid?style=for-the-badge&labelColor=black
[codecov-url]: https://app.codecov.io/gh/tensorush/zig-typeid
[license-shield]: https://img.shields.io/github/license/tensorush/zig-typeid.svg?style=for-the-badge&labelColor=black
[license-url]: https://github.com/tensorush/zig-typeid/blob/main/LICENSE.md
