### Installation
NOTE: SSH is set up in this security group, so you if can create a KeyPair in US-East-1, you can ssh into the instance to see the Docker Container running after running Terraform Apply

1. Clone the repo
   ```sh
   git clone https://github.com/aerielellisk5/el_technical.git
   ```
2. CD into the repo
3. Run this command
   ```sh
   terraform apply --auto-approve
   ```
4. Check your EC2 instances in US-EAST-1 and see the running image!
