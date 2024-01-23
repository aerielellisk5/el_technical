### The Assignment
Implement a fully automated deployment of the Go Ethereum Client (GETH) running in AWS. If you haven't used this before it's a standalone piece of software that connects to the Ethereum network to form part of the peer to peer network.

[https://geth.ethereum.org/](https://t.lever-analytics.com/email-link?dest=https%3A%2F%2Fgeth.ethereum.org%2F&eid=710b0902-d5ed-45af-9fab-8713edc0f461&idx=0&token=VIh3HngFvVlEVQLMfsE3UdEkQQM)

This should be running on an EC2 instance (or container) which will start up, install the Ethereum client software and start syncing the blockchain to MAINNET. A full sync can take many days to complete (depending on instance type) so it's OK if your client starts up and is gradually syncing after keeping an eye on it for a few hours.

### Installation
1. Clone the repo
   ```sh
   git clone https://github.com/your_username_/Project-Name.git
   ```
2. CD into the repo
3. Run this command
   ```sh
   terraform apply --auto-approve
   ```

