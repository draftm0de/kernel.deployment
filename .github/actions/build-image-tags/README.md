# actions/build-image-tag

This GitHub Action calculates Docker image tags based on the provided source and target branches. It supports dynamic tagging logic to generate meaningful and reusable tags for your Docker images.

## Description
This action ensures consistent and meaningful Docker image tags based on branching strategies. It validates source and target branch names to maintain semantic versioning and generate Docker tags.

_Related Actions_
- [actions/dto-git-branch-version](../dto-git-branch-version/README.md): Extracts version components from a branch name.

### Input
- ``source`` _(required)_: Specifies the source branch of the merge request.
- ``target`` _(required)_: Specifies the target branch of the merge request.

### Output
- ``tags`` _(string | empty)_: Returns calculated image tags

### Version patterns

This regex identifies version strings in the following format:
- Optional `v` prefix (e.g., `v1.2.3`)
- Numeric components separated by dots (e.g., `1.2.3`)
- Optional postfix (e.g., `-beta` or `-rc1`).

```
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
```

### Verifications (Name Based)

The following source target branch combination will failure:

| Source  | Target  | Failure                                                                     |
|---------|---------|-----------------------------------------------------------------------------|
|         | `1.1.1` | Target branch already has a patch version.                                  |
| `1.2.2` | `1.2.3` | Source and target branches having the same version depth (patch).           |
| `1.2`   | `1.3`   | Source and target branches having the same version depth (minor).           |
| `1`     | `2`     | Source and target branches having the same version depth (major).           |
| `1.2.1` | `1.1` | Source minor version is greater than target minor version.                  |
| `2.2.3` | `1.1` | Source major version is greater than target major version.                  |
| `1.2.1` | `1` | Source branch with patch version requires target branch with minor version. |

### Verifications (git branch based)

Base on the target branch `git` related branches are fetched and verified against given source branch.
```
git fetch origin
From https://github.com/draftm0de/images.caddy
 * [new branch]      1.0        -> origin/1.0
 * [new branch]      1.0.2      -> origin/1.0.2
 * [new branch]      1.1        -> origin/1.1
 * [new branch]      main       -> origin/main
```

| Source  | Target | Failure                                                                    |
|---------|--------|----------------------------------------------------------------------------|
| `1.0.1` | `1.0`  | Source branch has a lower patch version than latest related target branch. |
| `1.0`   | `1`    | Source branch has a lower minor version than latest related target branch. |
