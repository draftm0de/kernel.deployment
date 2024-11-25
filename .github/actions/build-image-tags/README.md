# actions/build-image-tag

## description
...<br>

_Related Actions_
- [actions/convert-branch-to-version](../convert-branch-to-version/README.md): Extracts version components from a branch name.

### input
- ``source`` _(required)_: Specifies the source branch of the merge request.
- ``target`` _(required)_: Specifies the target branch of the merge request.

### output
- ``tags`` _(string | empty)_: Returns calculated image tags