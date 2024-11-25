# actions/build-commit-tag

## description
Calculate the next version number based on the specified target branch. This action evaluates existing tags and version patterns to determine and increment the appropriate versioning component (major, minor, or patch) based on predefined rules and the repository's current state.

_Related Actions_
- [actions/convert-branch-to-version](../convert-branch-to-version/README.md): Extracts version components from a branch name.

### input
- ``source`` _(required)_: Specifies the source branch of the merge request.
- ``target`` _(required)_: Specifies the target branch of the merge request.

### output
- ``tags`` _(string | empty)_: Outputs the next calculated version tag or remains empty if no tag is generated.

### next version rules

- If the target branch lacks a patch version:
  - Retrieve the latest tag for the specified target branch.<br>
  _Filter ``{Prefix}.{Major}.{Minor}.*{Postfix}``_
  - Increment the patch version.
- If the target branch lacks a minor version:
  - Retrieve the latest tag for the specified target branch.<br>
    _Filter ``{Prefix}.{Major}.*{Postfix}``_
  - Increment the minor version.

### version patterns

This regex identifies version strings with an optional prefix (v), numerical components, and an optional postfix.

```
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
```

### verifications

The following verifications are performed:

- The source branch name does not match the version patterns.
- The source branch does not contain any tags matching the version patterns.
- The target branch must match the version patterns.
- The calculated tag must not exist as a branch name.

**_Note:_** If any verification fails, a warning is displayed, and no output tag is set.

### examples
```
**Input**:
source: DM12021
target: 1.0

**Output**:
1.0.1
```

```
**Input**:
source: 1.0.1
target: 1.0

**Output**:
> failure > source branch matches version patterns
```

```
**Input**:
source: 1.0.1
target: yes

**Output**:
> failure > target branch does not match version patterns
```