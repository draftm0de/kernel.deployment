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

Use the given TARGET_IMAGE:[TAG] and increase the TAG version + 1 (e.g. 1.2.3) based on his provided structure.

--tag-increase value conditions:
- value has to be greater or equal to the provided IMAGE:[TAG]
- value is used to count + 1 to the provided IMAGE:[TAG]

_example (--tag-increase=true)_<br>
TARGET_IMAGE:[TAG] is required
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3 --tag-increase
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.4

./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2 --tag-increase
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.3
```

_example (--tag-increase=1.2)_<br>
TARGET_IMAGE:[TAG] is not given
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy --tag-increase=1.2.3
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.4
```
TARGET_IMAGE:[TAG] is given: the calculated tag will match the same structure (major, minor, patch).
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2 --tag-increase=1.4
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.4

./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.1 --tag-increase=1.4
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.4.1
```

#### option: --tag-level|--tag-level=[LEVEL]
_default: LEVEL=1_<br><br>
The SOURCE_IMAGE[TAG] is split by ```.``` and based on the LEVEL the SOURCE_IMAGE is tagged with additional tags.

_example (--tag-level not set)_
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3 --tag-level
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3
```

_example (--tag-level set to 2)_
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3 --tag-level=2
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2
```

_example (--tag-level set to 3)_
```
./docker.sh image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3 --tag-level=3
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2.3
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1.2
>> docker image tag draftmode/base.caddy:latest draftmode/base.caddy:1
```

### command: image sha
Get the SHA for a given image.<br>

```
./docker.sh image sha draftmode/base.caddy:1.2.1
./docker.sh image sha draftmode/base.caddy:1.2.1 --remote
>> sha256:17a42d6b26d2158c95b53acb2074503df708f984eae216cc8ed8ee79fe497ebb
```
### command: image tags|tags
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

#### IMAGE:[TAG]
There are three options
#### TAG starts with *
List all tags where tag.name starts with
```
./docker.sh image tags draftmode/base.caddy:la*
>> latest
```

#### TAG ends with *
List all tags where tag.name ends with
```
./docker.sh image tags draftmode/base.caddy:*st
>> latest
```

#### TAG does not have any *
List all tags having the same SHA from the given IMAGE:TAG.
```
./docker.sh image tags draftmode/base.caddy:latest
>> 1
>> 1.2
>> 1.2.2
>> latest
xx 1.1 (has another SHA and is not returned)
```

#### option: --format=[FORMAT]
List only tags matching the format
- major: [0-9]
- minor: [0-9].[0-9]
- patch: [0-9].[0-9].[0-9]

```
./docker.sh image tags draftmode/base.caddy:latest --format=major
>> 1

./docker.sh image tags draftmode/base.caddy:latest --format=minor
>> 1.2

./docker.sh image tags draftmode/base.caddy:latest --format=patch
>> 1.2.2
```

#### option: --latest
_This option is only used when --format is used!_<br>
Order all filtered tags and returns only the first (latest) one.<br>

```
./docker.sh image tags draftmode/base.caddy:latest --format=patch --latest
>> 1.2.2

./docker.sh image tags draftmode/base.caddy:latest --format=minor --latest
>> 1.2

./docker.sh image tags draftmode/caddy.proxy:latest --format=major --latest
>> 1
```

#### option: --with-image-name
Prefix the calculated tag(s) with the provided IMAGE_NAME

_example_
```
./docker.sh image tags draftmode/caddy.proxy:latest --with-image-name
>> draftmode/caddy.proxy:1.2.2
>> draftmode/caddy.proxy:1.2
>> draftmode/caddy.proxy:1
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