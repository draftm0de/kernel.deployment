# action/image-manifest-property

## Description
Retrieves the manifest for a specified image.

If the `inputs.property` is provided, returns the value of the specified property from the retrieved manifest (using a jq-based query).

### Inputs
- ``image`` _(required)_: The identifier of the image from which to retrieve the manifest.
- ``property`` _(optional)_: A jq-based query string specifying the property to extract from the manifest.

### Outputs
- ``manifest`` _(string | empty)_: The complete (Base64-encoded) manifest of the specified image. Returns an empty string if no manifest is found.
- ``property`` _(string | empty)_: The value of the specified property from the manifest. Returns an empty string if no property is specified or found.

### Notes
- Ensure the provided `image` is valid and accessible.
- The `property` input must follow jq syntax for property extraction. For more information on jq, refer to its documentation.

_Decode Base64_
````
manifest=$(echo "${{ steps.get-manifest.outputs.manifest }}" | base64 --decode)
````
