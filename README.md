### The Assignment
Implement a fully automated deployment of the Go Ethereum Client (GETH) running in AWS. If you haven't used this before it's a standalone piece of software that connects to the Ethereum network to form part of the peer to peer network.

This should be running on an EC2 instance (or container) which will start up, install the Ethereum client software and start syncing the blockchain to MAINNET. A full sync can take many days to complete (depending on instance type) so it's OK if your client starts up and is gradually syncing after keeping an eye on it for a few hours.

### Installation
NOTE: SSH is set up in this security group, so you if can create a KeyPair in US-East-1, you can ssh into the instance to see the Docker Container running after running Terraform Apply

1. Clone the repo
   ```sh
   git clone https://github.com/your_username_/Project-Name.git
   ```
2. CD into the repo
3. Run this command
   ```sh
   terraform apply --auto-approve
   ```
4. Check your EC2 instances in US-EAST-1 and see the running image!
