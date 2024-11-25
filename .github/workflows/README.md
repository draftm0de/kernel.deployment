# Workflows

## build-image
## scan-image
## tag-commit

_related actions_
- [actions/build-commit-tag](../actions/build-commit-tag/README.md)

### input
- source branch name [optional, default: github.ref_name]
- target branch name [optional, default: github.event.pull_request.base.ref]

### output
- tag [string | empty]
