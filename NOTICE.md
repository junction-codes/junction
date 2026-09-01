# Third-Party Notices

Junction vendors a small number of third-party files. Each file listed below is
redistributed unmodified under its original license.

Gem dependencies are not listed here. Their licenses ship inside their own gems
and are resolved by Bundler.

## Vendored files

| Package              | Version | License | Vendored path                                   |
| -------------------- | ------- | ------- | ----------------------------------------------- |
| `@floating-ui/core`  | 1.8.0   | MIT     | `vendor/javascript/@floating-ui--core.js`       |
| `@floating-ui/dom`   | 1.8.0   | MIT     | `vendor/javascript/@floating-ui--dom.js`        |
| `@floating-ui/utils` | 0.2.12  | MIT     | `vendor/javascript/@floating-ui--utils.js`      |
| `@floating-ui/utils` | 0.2.12  | MIT     | `vendor/javascript/@floating-ui--utils--dom.js` |
| `cytoscape`          | 3.34.1  | MIT     | `vendor/javascript/cytoscape.js`                |
| `tw-animate-css`     | 1.4.0   | MIT     | `vendor/stylesheets/tw-animate-css.css`         |

The two `@floating-ui/utils` entries are separate subpath exports of the same
package and share a version.

## Copyright notices

Every vendored file is distributed under the MIT License, reproduced below.
The following copyright notices are preserved as that license requires.

- [floating-ui] — `@floating-ui/core`, `@floating-ui/dom` and
  `@floating-ui/utils`:

    Copyright (c) 2021-present Floating UI contributors

- [cytoscape]:

    Copyright (c) 2016-2026, The Cytoscape Consortium.

- [tw-animate-css]:

    Copyright (c) 2025 Wombosvideo

## MIT License

```text
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Updating this file

The JavaScript files are managed by importmap-rails. Re-pinning a package
rewrites both the vendored file and its version comment in
`config/importmap.rb`:

```bash
bin/importmap pin cytoscape
bin/importmap outdated
```

`vendor/stylesheets/tw-animate-css.css` is not an importmap package. It is
downloaded from the npm tarball and carries its own provenance header, so
update it by replacing the file and its header together.

After changing any vendored file, update the version in the table above and
confirm the copyright notice and license still matches the upstream `LICENSE`.

[cytoscape]: https://github.com/cytoscape/cytoscape.js
[floating-ui]: https://github.com/floating-ui/floating-ui
[tw-animate-css]: https://github.com/Wombosvideo/tw-animate-css
