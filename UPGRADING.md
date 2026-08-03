# Upgrading

## v2.0.0 - path-keyed integrations

### What changed and why

The four submodules that build path integrations (`s3_integrations`,
`sns_integrations`, `proxy_integrations`, `lambda_integrations`, all in `paths.tf`)
used to be instantiated with `count = length(local.<type>_mappings)`, addressed as
`module.sns_integrations[0]`, `[1]`, etc. - a plain list index into `var.mappings`
filtered by type.

That means the state address of every path depended on its **position** in
`var.mappings`, not on the path itself. Inserting, removing, or reordering any entry
- including an apparently-safe change like wrapping the list in `toset()` to dedupe
it - shifts every subsequent instance's index. Terraform then plans a destroy and
recreate of every API Gateway path after the shift point, even though most of them
didn't actually change.

v2.0.0 converts all four to `for_each`, keyed by `trim(path, "/")` - so `"foo"`,
`"/foo"`, and `"foo/"` all key identically. Addresses are now:

```
module.s3_integrations["<path>"]
module.sns_integrations["<path>"]
module.proxy_integrations["<path>"]
module.lambda_integrations["<path>"]
```

Since the key is the path itself, adding, removing, or reordering entries in
`var.mappings` only affects the entries that actually changed. No unrelated path
gets touched.

### What you need to do

`moved` blocks tell Terraform "this state address used to mean X, now it means Y."
They must be **literal** - no variables, no `for_each`, no computed expressions -
which means they can't live inside this reusable module. You add them to your own
root module, next to wherever you call this module.

1. **Before** bumping this module's `version`, generate the moves against your
   current (pre-upgrade) state. From your root module directory:

   ```
   curl -O https://raw.githubusercontent.com/PackagePortal/terraform-aws-opinionated-api-gateway/main/scripts/generate-path-moves.sh
   chmod +x generate-path-moves.sh
   ./generate-path-moves.sh module.<your_module_call_name> moved.tf
   ```

   Make sure you read the script before running this command so you can see that you
   have appropriate local permissions to run it.

   Run it once per module call if you have more than one (e.g. an internal and a
   public gateway) - pass a different out-file or the same one; the script appends.

   The script reads `terraform show -json` and recovers each path from the
   submodule's terminal `aws_api_gateway_resource`'s computed `path` attribute - the
   same value AWS itself uses, not a re-guess from your config's list order. See the
   script's header comment for exactly which resource it reads per type.

   If it errors with "could not recover a path for ... lambda_integrations[N]", that
   instance is the one edge case the script can't resolve automatically: a
   `lambda` mapping whose `path` is literally `"/"` (attached directly at the API
   root, no proxy resource created at all). Add that one `moved` block by hand:
   ```hcl
   moved {
     from = module.<your_module_call_name>.module.lambda_integrations[N]
     to   = module.<your_module_call_name>.module.lambda_integrations[""]
   }
   ```

2. Bump the module version:
   ```hcl
   module "my_gateway" {
     source  = "PackagePortal/opinionated-api-gateway/aws"
     version = "2.0.0"
     ...
   }
   ```

3. Run `terraform plan`. Expected output is **only the moves, plus one replacement**
   of `aws_api_gateway_deployment.api_gateway_deployment` (its redeployment-trigger
   hash changes because the four submodules are now maps, iterated in a different
   order than the old lists) - that replacement is safe, the deployment resource has
   `create_before_destroy = true`. You should see **zero** resources to add and
   **zero** to destroy. If you see any add/destroy beyond that one deployment
   replacement, stop - it means a path's recovered key doesn't match what
   `trim(path, "/")` produces for that same mapping in your `var.mappings`, and
   applying would destroy and recreate that path instead of moving it.

4. Apply, then delete `moved.tf` - `moved` blocks are one-shot; leaving them in
   doesn't hurt, but they're dead weight once applied.

### Also in this release

- `required_version` is now `>= 1.1` (previously `>= 1.0`) - `moved` blocks require
  Terraform 1.1+.
- A `validation` block on `var.mappings` now rejects two entries of the same `type`
  whose `trim(path, "/")` collide, since that would otherwise be a hard-to-read
  "duplicate map key" error. Cross-type path collisions are unaffected - AWS Gateway
  already rejects those at apply time.
- No input or output variable shapes changed - `var.mappings` is still a list, this
  release only changes how it's addressed internally.
