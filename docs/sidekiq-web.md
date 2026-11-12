## Viewing the Sidekiq UI for Locations API

We have access to the Sidekiq UI but because Locations API doesn't have a
frontend we have to use port forwarding to see it in our live environments.

You'll need to have access to our EKS clusters before you can follow these
instructions. There's [documentation here](https://docs.publishing.service.gov.uk/kubernetes/get-started/access-eks-cluster/#access-a-cluster-that-you-have-accessed-before) on how to do that. This means that
you'll need [full production access](https://docs.publishing.service.gov.uk/manual/rules-for-getting-production-access.html#production-admin-access) before you can view the Sidekiq UI. Note that port-forwarding
in production and staging requires fulladmin access, so you'll need to set up [Temporary Production and Staging admin access](https://docs.publishing.service.gov.uk/manual/rules-for-getting-production-access.html#temporary-production-and-staging-admin-access)

To view the UI run:

```
kubectl -n apps port-forward deployment/locations-api 8080:8080
```

and then navigate to localhost:8080/sidekiq
