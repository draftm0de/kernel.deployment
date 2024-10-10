# base script collection

All **OPTIONS** and **COMMANDS** are forwarded in the same way you pass them to the regular command. We "just" added some custom commands/options to provide more features. At least to pass some commands to a remote host.<br>

## docker.sh
```
Usage:  ./docker.sh [OPTIONS] COMMAND"
```

### command: image tag|tag
Tag a given SOURCE_IMAGE:[TAG] to a TARGET_IMAGE:[TAG]

#### option: --tag-increase|--tag-increase=[BASE_TAG]
_default: BASE_TAG=true_<br>

The common usage is to set TARGET_IMAGE:[TAG] to the latest TAG version (e.g. 1.2.3) AND provide a --tag-increase value (e.g. 1.3).
The business logic will automatically try to increase the latest TAG (+1) based on his structure.

--tag-increase has a value
- value has to be greater or equal to the provided IMAGE:[TAG]
- value is used to count + 1 to the provided IMAGE:[TAG]

_example (--tag-increase=true)_<br>
TARGET_IMAGE:[TAG] is required
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3 --tag-increase
>> draftmode/base.caddy:1.2.4

./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2 --tag-increase
>> draftmode/base.caddy:1.3
```

_example (--tag-increase=1.2)_<br>
TARGET_IMAGE:[TAG] is not given
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy --tag-increase=1.2.3
>> draftmode/base.caddy:1.2.4
```
TARGET_IMAGE:[TAG] is given: the calculated tag will match the same structure (major, minor, patch).
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2 --tag-increase=1.4
>> draftmode/base.caddy:1.4

./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.1 --tag-increase=1.4
>> draftmode/base.caddy:1.4.1
```

#### option: --tag-level|--tag-level=[LEVEL]
_default: LEVEL=1_<br><br>
The SOURCE_IMAGE[TAG] is split by ```.``` and based on the LEVEL the SOURCE_IMAGE is tagged with additional tags.

_example (--tag-level not set)_
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3 --tag-level
>> draftmode/base.caddy:1.2.3
```

_example (--tag-level set to 2)_
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3 --tag-level=2
>> draftmode/base.caddy:1.2.3
>> draftmode/base.caddy:1.2
```

_example (--tag-level set to 3)_
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3 --tag-level=3
>> draftmode/base.caddy:1.2.3
>> draftmode/base.caddy:1.2
>> draftmode/base.caddy:1
```

### command: image sha
Get the SHA for a given image.<br>

_example_
```
./docker.sh image sha draftmode/base.caddy:1.2.1
./docker.sh image sha draftmode/base.caddy:1.2.1 --remote
>> sha256:17a42d6b26d2158c95b53acb2074503df708f984eae216cc8ed8ee79fe497ebb
```

#### option: --compare|--compare=[TYPE]
_default: TYPE=eq_<br><br>
In case of using the OPTION **--remote** the remote and local SHA keys are compared.

_--compare=eq_<br>
- remote SHA is equal to local SHA: no response, no exit code
- remote SHA is NOT euqal to local SHA: respond an error message, exit code 1

_--compare=neq_<br>
- remote SHA is equal to local SHA: respond an error message, exit code 1
- remote SHA is NOT euqal to local SHA: no response, no exit code

_example_
```
./docker.sh image sha draftmode/base.caddy:latest --remote --compare
```

### command: image tags|tags
List all [IMAGE_NAME] related tags.

```
REPOSITORY                TAG       SHA
draftmode/base.caddy      1         sha256:17a42d6b26d2158c95b53acb2074503df708f984eae216cc8ed8ee79fe497ebb
draftmode/base.caddy      1.1       sha256:567899abc6d2158c95b53acb2074503df708f984eae216cc8ed8ee1245abc123
draftmode/base.caddy      1.2       sha256:17a42d6b26d2158c95b53acb2074503df708f984eae216cc8ed8ee79fe497ebb
draftmode/base.caddy      1.2.2     sha256:17a42d6b26d2158c95b53acb2074503df708f984eae216cc8ed8ee79fe497ebb
draftmode/base.caddy      latest    sha256:17a42d6b26d2158c95b53acb2074503df708f984eae216cc8ed8ee79fe497ebb
```

List all [IMAGE_NAME] tags
```
./docker.sh image tags draftmode/base.caddy
./docker.sh image tags draftmode/base.caddy --remote
>> 1
>> 1.1
>> 1.2
>> 1.2.2
>> latest
```

#### option: --sha=[sha]
List all [IMAGE_NAME] tags filtered on the given SHA
```
./docker.sh image tags draftmode/base.caddy --sha=sha256:567899abc6d2158c95b53acb2074503df708f984eae216cc8ed8ee1245abc123
./docker.sh image tags draftmode/base.caddy --remote --sha=sha256:567899abc6d2158c95b53acb2074503df708f984eae216cc8ed8ee1245abc123
>> 1.1
```

#### option: --latest|--latest=[TYPE]
_default: TYPE=patch_<br><br>
Reduce all [IMAGE_NAME] tags based on the OPTION [TYPE].<br>
TYPE options:
- patch (pattern: #.#.#)
- major (pattern: #.#)
- minor (minor: #)

_example (type not set or type=patch)_
```
./docker.sh image tags draftmode/base.caddy --latest
./docker.sh image tags draftmode/base.caddy --latest --remote
>> 1.2.2
```
_example (type=minor)_
```
./docker.sh image tags draftmode/base.caddy --latest=minor
./docker.sh image tags draftmode/base.caddy --latest=minor --remote
>> 1.2
```
_example (type=major)_
```
./docker.sh image tags draftmode/caddy.proxy --latest=major
./docker.sh image tags draftmode/caddy.proxy --latest=major --remote
>> 1
```
#### option: --exists
If there is at least one TAG matching to the given SHA 
- respond an error message
- exit(1)
```
./docker.sh image tags draftmode/base.caddy --remote --sha=sha256:567899abc6d2158c95b53acb2074503df708f984eae216cc8ed8ee1245abc123 --exit
```

### Options
#### --remote|--remote=[TYPE]
Execute a docker command remotely. To be a supported COMMAND /docker.sh has to provide an implementation.<br><br>
_Arguments_<br>
- _TYPE_<br>
determines the remote api implementation (optional, default=remote/docker.hub.sh)<br>

_Supported for COMMAND_
- docker image remove
- docker image rmi
- docker rmi
- docker sha ([see: custom command](#command-image-sha))
- docker image [IMAGE] tags ([see: custom command](#command-image-tagstags))

_Insides_<br>
The implementation is realized in his related bash script and requires next methods:
- docker_api_get_tags
- docker_api_get_sha
- docker_api_image_remove

_Supported API(s)_
- docker.hub [remote/docker.hub.sh](interpreter/docker.hub.sh)

#### --build-args=[file]
Converts given arguments in <file> into --build-arg [key]=[value].<br><br>
_Arguments_<br>
- _file_
file to be ensources (required)<br><br>

```
cat .build_envs
>>
VERSION=1.2
ENVIRONMENT=prod
```
_example_
```
./docker.sh build --build-args=.build_envs
>>
docker build --build-arg VERSION=1.2 --build-arg ENVIRONMENT=prod 
```

### Real World Example
```
REPOSITORY="draftmode/base.caddy"
BUILD_ARGS_FILE=".build_args"

echo "[Notice] Build image..."
BUILT_IMAGE_NAME="$REPOSITORY:latest"
("${SCRIPT_PATH}/docker.sh" "build" "--build-args=$BUILD_ARGS_FILE" "-t $BUILT_IMAGE_NAME" ".")
echo "[Notice] > build successfully"

echo "[Notice] Protect built SHA against remote"
SHA=$("${SCRIPT_PATH}/docker.sh" "image sha" "$BUILT_IMAGE_NAME")
("${SCRIPT_PATH}/docker.sh" "image tags" "$REPOSITORY" "--remote" "--sha=$SHA" "--exists")
echo "[Notice] > Protection successfully"

echo "[Notice] Get latest remote tag for $BUILT_IMAGE_NAME "
LATEST_TAG=$("${SCRIPT_PATH}/docker.sh" "image tags" "$BUILT_IMAGE_NAME" "--remote" "--latest=patch")
echo "[Notice] > latest remote tag for $BUILT_IMAGE_NAME: $LATEST_TAG"

echo "[Notice] Tag docker image"
TAGS=$("${SCRIPT_PATH}/docker.sh" "image tag" "$BUILT_IMAGE_NAME" "$REPOSITORY:$LATEST_TAG" "--tag-increase" "--tag-level=3")
echo "[Notice] > docker image tagged successfully"

echo "[Notice] Push docker images"
TAGS=($TAGS)
TAGS+=("$BUILT_IMAGE_NAME")
for TAG in "${TAGS[@]}"; do
  echo "docker push $TAG"
done
echo "[Notice] > Pushing docker images successfully"
```