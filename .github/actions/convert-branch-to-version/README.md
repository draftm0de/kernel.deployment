# Action: Convert Branch Name to Version Components

## description
Parse the provided branch name into its version components, including:

- Prefix
- Major
- Minor
- Patch
- Postfix

This action uses version patterns to extract and identify these components.

### inputs
- ``branch`` _(required)_: The branch name to be processed.

### outputs
- ``branch``: Returned if the given branch matches the version patterns.
- ``prefix``: Extracted prefix from the branch name.
- ``major``: Major version component.
- ``minor``: Minor version component.
- ``patch``: Patch version component.
- ``postfix``: Postfix string, if available.

### version patterns

This regex identifies version strings with an optional prefix (v), numerical components, and an optional postfix.
```
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
```

### examples
```
**Input**:  
branch: DM12021

**Output**:
branch:
prefix:
major:
minor:
patch:
postfix:
```

```
**Input**:
branch: v1.0

**Output**:
branch: v1.0
prefix: v
major: 1
minor: 0
patch:
postfix:
```

```
**Input**:
branch: v1.0.2

**Output**:
branch: v1.0
prefix: v
major: 1
minor: 0
patch: 2
postfix:
```

```
**Input**:
branch: v1.0.2-prod

**Output**:
branch: v1.0
prefix: v
major: 1
minor: 0
patch: 2
postfix: prod
```