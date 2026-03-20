# astroflow-status-website
Static website to monitor Astroflow status.

## Deployment

1. Update GCP project as needed in `infra/variables`.
2. Update URLs to status check as needed in `config/urls.json`
3. Commit and push, then pull from Cloudshell (if not using keys locally)
4. Deploy with `terraform init` followed by `terraform plan` inside cloudshell.

The status page will then deploy at:
```
http://{bucket-name}.storage.googleapis.com/index.html
```

## Code organisation

```
├── config
│   └── urls.json
├── infra  (Terraform files)
│   ├── bucket_files.tf
│   ├── main.tf
│   └── variables.tf
├── LICENSE
├── README.md
└── src (Website code)
    ├── 404.html
    ├── index.html
    ├── status.js
    └── styles.css

```


