# actions/dto-explode-git-branch-to-version

## Description
Parses the given branch name to extract and identify its version components, which include:

- `Prefix` The initial segment of the branch name (if present).
- `Major` The major version number.
- `Minor` The minor version number.
- `Patch` The patch version number.
- `Postfix` Any additional information following the version numbers.

This action utilizes predefined version patterns to accurately parse and extract these components.

### Inputs
- ``branch`` _(required)_: The branch name to be processed.

### Outputs
- ``branch``: Returned if the given branch matches the version patterns.
- ``prefix``: Extracted prefix from the branch name.
- ``major``: Major version component.
- ``minor``: Minor version component.
- ``patch``: Patch version component.
- ``postfix``: Postfix string, if available.

### Version patterns

This regex identifies version strings in the following format:
- Optional `v` prefix (e.g., `v1.2.3`)
- Numeric components separated by dots (e.g., `1.2.3`)
- Optional postfix (e.g., `-beta` or `-rc1`).

```
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
```

### Examples

| Input         | Branch | Prefix | Major | Minor | Patch | Postfix |
|---------------|------|--------|-------|-------|-------|---------|
| `DM12021`     |      |        |       |       |       |         |
| `v1`          |    `v1`  | `v`      | `1`     |       |       |         |
| `v1.0`        |    `v1.0` | `v`      | `1`     | `0`     |       |         |
| `v1.0.2`      |    `v1.0` | `v`      | `1`     | `0`     | `2`   |         |
| `v1.0.2-prod` |    `v1.0` | `v`      | `1`     | `0`     | `2`   | `prod`    |
| `1.0.2-prod` |    `v1.0` |      | `1`     | `0`     | `2`   | `prod`    |
