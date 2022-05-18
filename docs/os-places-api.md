# OS Places API

Locations API uses OS Places API under the hood. It makes requests to OS Places API whenever it needs to add or update the results for a given postcode.

## API keys

Each of the three environments Locations API runs in - Integration, Staging and Production - is set up as its own 'project' in the OS Data Hub. Each project defines its own set of API keys.

These keys are stored in govuk-secrets under `puppet_aws/hieradata/apps`, in their respective environment.

## Login credentials

You can log into the [OS Data Hub](https://osdatahub.os.uk/) to view usage and to regenerate API keys if needed.
The credentials for the account are stored in govuk-secrets, under `govuk-secrets/pass/2ndline/ordnance-survey/os-data-hub.gpg`.
