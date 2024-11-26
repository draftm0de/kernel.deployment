# Workflows

## build-image

_related actions_
- [actions/image-build](../actions/image-build/README.md)
- [actions/image-save](../actions/image-save/README.md)

### Inputs
- `image` _(required)_: Docker image name
- `target` _(optional)_: build option: `--target ${target}`
- `context` _(optional, default: .)_: build context path
- `options` _(optional)_: additional build options (e.g. `--label author=draftmode`)
- `build_args_file` _(optional)_: filename to be converted into `--build-arg ${arg}=${value}`
- `artifact` _(optional, if set: image will be saved to given artifact)_: Artifact name
- 
## push-image
_related actions_
- [actions/build-image-tags](../actions/build-image-tags/README.md)

### Inputs
- `image` _(required)_: Docker image name
- `secrets.DOCKER_USERNAME` _(required)_: Docker hub login username
- `secrets.DOCKER_PASSWORD` _(required)_: Docker hub login password/token
- `source` _(optional, default: github.ref_name)_: Branch to be merged from
- `target` _(optional, default: github.event.pull_request.base.ref)_: Branch to be merged into
- `artifact` _(optional, if image is stored as an artifact)_: Artifact name

## scan-image

_related actions_
- [actions/image-load](../actions/image-load/README.md)
- [actions/image-scan-scout](../actions/image-scan-scout/README.md)
- [actions/image-scan-trivy](../actions/image-scan-trivy/README.md)

### Inputs
- `image` _(required)_: Docker image name
- `artifact` _(optional, if set: image will be loaded from given artifact)_: Artifact name 
- `scanner` _(required)_: supported scanner implementations `scout` / `trivy`
- `config` _(optional)_: scanner based configuration file
- `secrets.DOCKER_USERNAME` _(required for scanner: scout)_: Docker hub login username
- `secrets.DOCKER_PASSWORD` _(required for scanner: scout)_: Docker hub login password/token

## tag-commit

_related actions_
- [actions/build-commit-tag](../actions/build-commit-tag/README.md)

### Inputs
- `source` _(optional, default: github.ref_name)_: Branch to be merged from
- `target` _(optional, default: github.event.pull_request.base.ref)_: Branch to be merged into

