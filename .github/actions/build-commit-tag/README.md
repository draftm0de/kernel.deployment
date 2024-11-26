# action/build-commit-tag

## description
Calculate the next version number based on the specified target branch. This action evaluates existing tags and version patterns to determine and increment the appropriate versioning component (major, minor, or patch) based on predefined rules and the repository's current state.

_Related Actions_
- [actions/convert-branch-to-version](../convert-branch-to-version/README.md): Extracts version components from a branch name.

### Inputs
- ``source`` _(required)_: Specifies the source branch of the merge request.
- ``target`` _(required)_: Specifies the target branch of the merge request.

### Outputs
- ``tags`` _(string | empty)_: Outputs the next calculated version tag or remains empty if no tag is generated.

### Next Version Rules

- If the target branch lacks a patch version:
  - Retrieve the latest tag for the specified target branch.<br>
  _Filter ``{Prefix}.{Major}.{Minor}.*{Postfix}``_
  - Increment the patch version.
- If the target branch lacks a minor version:
  - Retrieve the latest tag for the specified target branch.<br>
    _Filter ``{Prefix}.{Major}.*{Postfix}``_
  - Increment the minor version.

### Version patterns

This regex identifies version strings in the following format:
- Optional `v` prefix (e.g., `v1.2.3`)
- Numeric components separated by dots (e.g., `1.2.3`)
- Optional postfix (e.g., `-beta` or `-rc1`).

```
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
```

### Verifications

The following verifications are performed:

- The source branch name does not match the version patterns.
- The source branch does not contain any tags matching the version patterns.
- The target branch must match the version patterns.
- The calculated tag must not exist as a branch name.

**_Note:_** If any verification fails, a warning is displayed, and no output tag is set.

```
git fetch origin
From https://github.com/draftm0de/images.caddy
 * [new branch]      1.0        -> origin/1.0
 * [new branch]      1.0.2      -> origin/1.0.2
 * [new branch]      1.1        -> origin/1.1
 * [new branch]      main       -> origin/main
```

| Source  | Target | Output `tags`                                              |
|---------|--------|------------------------------------------------------------|
|   `DM12021`      | `1.0`  | `1.0.3`                                                    |
| `1.0.1` | `1.0`  | **failure** source branch matches version patterns.        |
| `1.0.1`   | `yes`  | **failure** target branch does not match version patterns. |

