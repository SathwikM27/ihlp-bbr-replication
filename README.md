# IHLP-BBR-replication

This setup requires installing gcloud cli and logging into a project that has a billing account linked and and compute engine enabled (Free trial available to first time users) Recommended Ubuntu 20.04 LTS +
Install Gcloud cli : https://cloud.google.com/sdk/docs/install

This setup has followed the original setup instructions from google's repo to get bbr running with some changes made for updated kernels.

https://github.com/google/bbr/blob/master/Documentation/bbr-quick-start.md

## Creating VMs
Once gcloud cli has been setup and billing account has been linked, update project id in [settings](/settings.sh)