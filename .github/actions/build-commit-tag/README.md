# action/build-commit-tag

## description
Calculate the next version based on the given target branch.<br>

_related actions_
- [action/convert-branch-to-version](../convert-branch-to-version/README.md)

### input
- source branch name [required]
- target branch name [required]

### output
- tags [string | empty]

### next version rules

- If the target branch has no patch version:
  - Retrieve the latest tag for the given target branch.<br>
  _Filter ``{Prefix}.{Major}.{Minor}.*{Postfix}``_
  - Increment the patch version.
- If the target branch has no minor version:
  - Retrieve the latest tag for the given target branch.<br>
    _Filter ``{Prefix}.{Major}.*{Postfix}``_
  - Increment the minor version.

### version patterns
```
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
```

### verifications
- Source branch name does not match the version patterns
- Source branch has no tag matches the version patterns
- Target branch has to match the version patterns
- Calculated tag does not exist as a branch name

If any verification fails, a warning is displayed, and no output tag is set.

### examples
```
source: DM12021
target: 1.0
> success > commit tag: 1.0.1
```

```
source: 1.0.1
target: 1.0
> failure > source branch matches version patterns
```

```
source: 1.0.1
target: yes
> failure > target branch does not match version patterns
```