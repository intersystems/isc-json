# Repository Guidelines

## Project Structure & Module Organization
- `latest/cls/pkg/isc/json/`: Core IRIS ObjectScript sources (adaptor, mapping, utils).
- `latest/internal/testing/unit_tests/UnitTest/isc/json/`: Unit tests using `%UnitTest.TestCase`.
- `latest/docs/` and `latest/README.md`: User docs and notes.
- `latest/module.xml`: ZPM module manifest for packaging/testing.

## Source Control
- Perforce is used instead of git.
- If a file is not checked out in perforce, run p4 edit or p4 add as needed before making edits

## Build, Test, and Development Commands
- Compile sources (from IRIS terminal in the correct namespace):
  - `zpm "install isc.json"`
- Run tests via ZPM (prompt for instance and namespace):
  - Prefer this interactive shell snippet so you can choose the IRIS instance and namespace at run time:
    ```sh
    read -r -p "IRIS instance name: " IRISINST
    read -r -p "Namespace to run tests: " NS
    iris session "$IRISINST" -U "$NS" <<'EOF'
_system
SYS
zpm "isc.json test"
halt
EOF
    ```
  - To run a single test case, replace the `zpm` line with, for example:
    ```sh
    zpm "isc.json test -only -DUnitTest.Case=UnitTest.isc.json.exportArray"
    ```
  - If already inside an IRIS terminal in your target namespace, you can simply run:
    - `zpm "isc.json test"`

## Coding Style & Naming Conventions
- One class per `.cls` file; keep class path aligned with package.
- Methods (including tests): PascalCase; avoid underscores.
- Indentation: 4 spaces or tabs consistently; align `Try/Catch`/`While` blocks.
- Use `///` for concise class/method docs; prefer code examples over prose.
- Methods should throw errors instead of returning %Status unless overriding a method that requires returning %Status.

## Testing Guidelines
- Place tests under `latest/internal/testing/unit_tests/UnitTest/isc/json` in `UnitTest.isc.json.*` packages.
- Name test methods `Test...` and keep assertions focused and readable.
- Keep tests hermetic: no external I/O or network; use `%DynamicObject`/`%DynamicArray` fixtures.
- Run tests locally before pushing; ensure new tests pass and do not break existing ones.

## Security & Configuration Tips
- Do not include real data/PII in fixtures.
- Prefer configuration via parameters over hardcoding environment paths.
- Validate JSON with `%DynamicAbstractObject` APIs; avoid unsafe string parsing.
