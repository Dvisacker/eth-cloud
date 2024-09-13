## Very outdated docs

## Setup

```bash
packer init .
packer build .
terraform init
terraform apply
```

## Logs

```bash
journalctl -f -u reth
journalctl -f -u lighthouse
```

## References
- https://gist.github.com/yorickdowne/f3a3e79a573bf35767cd002cc977b038
- https://pawelurbanek.com/ethereum-node-aws

## Tips
- Hetzner is much cheaper than AWS (4 times cheaper for compute, 1.5 cheaper for storage)

## Todo
- [x] AWS: reth configuration
- [ ] AWS: geth configuration
- [ ] Hetzner: reth configuration
- [ ] Hetzner: geth configuration
- [ ] Arbitrum: geth configuration
- [ ] Optimism: geth configuration
- [ ] Optimism: reth configuration
- [ ] Simple metrics