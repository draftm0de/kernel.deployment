# actions/convert-branch-to-version

## description
Explode given branch name into version

- Prefix
- Major
- Minor
- Patch
- Postfix

base on version patterns

### inputs
- branch [required]

### outputs
- branch<br>
In case of matching patterns identically with given branch
- prefix<br>
Prefix for given branch 
- major<br>
Major version for given branch 
- minor<br>
Minor version for given branch 
- patch<br>
Patch version for given branch
- postfix<br>
Postfix for given branch

### version patterns
```
regex="^(v)?([0-9]+)(\.[0-9]+)?(\.[0-9]+)?(-[a-zA-Z0-9]+)?$"
```

### examples
```
branch: DM12021
> branch:
> prefix:
> major:
> minor:
> patch:
> postfix:
```

```
branch: v1.0
> branch: v1.0
> prefix: v
> major: 1
> minor: 0
> patch:
> postfix:
```

```
branch: v1.0.2
> branch: v1.0
> prefix: v
> major: 1
> minor: 0
> patch: 2
> postfix:
```

```
branch: v1.0.2-prod
> branch: v1.0
> prefix: v
> major: 1
> minor: 0
> patch: 2
> postfix: prod
```