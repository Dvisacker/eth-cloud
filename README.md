
## Setup

```bash
packer init .
packer build .
terraform init
terraform apply
```

### Hetzner

1. Create a project
2. [Generate an API key](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/) and add it to `terraform.tfvars`
3. [Add a SSH key](https://community.hetzner.com/tutorials/add-ssh-key-to-your-hetzner-cloud)

## Logs

```bash
journalctl -f -u reth
journalctl -f -u lighthouse
```

## References
- https://gist.github.com/yorickdowne/f3a3e79a573bf35767cd002cc977b038
- https://pawelurbanek.com/ethereum-node-aws

## Todo
- [x] AWS: reth configuration
- [ ] AWS: geth configuration
- [ ] Hetzner: reth configuration
- [ ] Hetzner: geth configuration