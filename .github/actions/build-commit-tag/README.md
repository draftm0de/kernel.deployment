# action/build-commit-tag

Based on a given target branch calculate next version.<br>
The target branch is extracted into
- Prefix
- Major
- Minor
- Patch
- Postfix

**Next version rules**
- target has no patch version
  - get latest tag for given target branch<br>
  _Filter ``{Prefix}.{Major}.{Minor}.*{Postfix}``_
  - increase patch version
- target has no minor version
  - get latest tag for given target branch<br>
    _Filter ``{Prefix}.{Major}.*{Postfix}``_
  - increase minor version

**Version patterns**
```
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
```

## verifications
- Source branch name does not match the version patterns
- Source branch has no tag matches the version patterns
- Target branch has to match the version patterns
- Calculated tag does not exist as a branch name

## examples
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