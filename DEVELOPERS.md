# Developers memo

## Rotating the Azure Storage SAS token

GHA tests use an Azure Storage SAS token stored as a GitHub Actions secret. The token has an expiry date; when it expires, all `test_as_action_*` jobs will start failing with authentication errors.

* Ensure you're logged in to Azure CLI — beware that the sessions expire after 90 days of inactivity:

    ```sh
    az login
    ```

* Verify you can actually access the storage account (not just that you're logged in):

    ```sh
    az storage blob list \
        --account-name packageskaitai \
        -c test3 \
        --num-results 1 \
        --output table
    ```

    If this succeeds (shows a blob or an empty table), your credentials are good. If it fails with a credentials/token error, your session is still stale — retry `az login`.

* Generate a new SAS token:

    ```sh
    az storage container generate-sas \
        --name test3 \
        --account-name packageskaitai \
        --permissions rwdl \
        --expiry $(date -u -d "+1 year" +%Y-%m-%dT%H:%MZ) \
        --output tsv
    ```

    It will result in a string like this:

    ```
    se=2027-04-15T18%3A36Z&sp=rwdl&sv=2022-11-02&sr=c&sig=[REDACTED]
    ```

* Update the GitHub secret:
  * Go to https://github.com/kaitai-io/repo-apt-handle/settings/secrets/actions
  * Update `TEST_AZURE_STORAGE_SAS_TOKEN` with the new value.
