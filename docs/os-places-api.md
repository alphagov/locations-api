# OS Places API

Locations API uses Ordnance Survey Places API under the hood. It makes requests to OS Places API whenever it needs to add or update the results for a given postcode.

## API keys

Each of the three environments Locations API runs in - Integration, Staging and Production - is set up as its own 'API project' in the OS Data Hub within the ["GOV.UK" Team Space](https://osdatahub.os.uk/data/team-spaces/576). Each project defines its own set of API keys.

These keys are stored in AWS Secrets Manager under `govuk/locations-api/os-places`, in their respective environment. The corresponding secret references are configured in the Helm chart values ([example](https://github.com/alphagov/govuk-helm-charts/blob/d878281a26b45cd897f30da62a7aead3a9e6b4c8/charts/app-config/values-production.yaml#L2152-L2161)) and made available to the application.

## Login credentials

You can log into the [OS Data Hub](https://osdatahub.os.uk/) to view usage and to regenerate API keys and [update them](https://docs.publishing.service.gov.uk/kubernetes/manage-app/set-env-var/#update-an-environment-variable-from-a-secrets-manager-secret) if needed.

[Ask a member of Senior Tech](https://docs.publishing.service.gov.uk/manual/ask-for-help.html#contact-senior-tech) to invite you to the Department for Science, Innovation & Technology organisation and the GOV.UK Team Space.
