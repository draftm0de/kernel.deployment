# action/image-manifest-property

## Description
Returns the value of the specified property from the retrieved manifest (using a jq-based query).

### Inputs
- ``image`` _(required)_: The identifier of the image from which to retrieve the manifest.
- ``property`` _(required)_: A jq-based query string specifying the property to extract from the manifest.

### Outputs
- ``property`` _(string | empty)_: The value of the specified property from the manifest. Returns an empty string if no property is specified or found.

### Notes
- Ensure the provided `image` is valid and accessible.
- The `property` input must follow jq syntax for property extraction. For more information on jq, refer to its documentation.
