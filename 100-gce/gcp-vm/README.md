# gcp-vm-load-balancer Project

This Terraform project sets up a simple virtual machine in Google Cloud and configures a load balancer to efficiently distribute traffic to web servers.

## Project Structure

```
gcp-vm-load-balancer
├── main.tf            # Main configuration for the Terraform project
├── variables.tf       # Input variables for the Terraform configuration
├── outputs.tf         # Output values displayed after infrastructure creation
├── terraform.tfvars    # Values for the variables defined in variables.tf
└── README.md          # Documentation for the project
```

## Prerequisites

- Terraform installed on your local machine.
- Google Cloud account with billing enabled.
- Google Cloud SDK installed and configured.

## Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd gcp-vm-load-balancer
   ```

2. **Configure your Google Cloud credentials**:
   Make sure you have authenticated your Google Cloud SDK with the necessary permissions.

3. **Update `terraform.tfvars`**:
   Modify the `terraform.tfvars` file to set your project ID, region, and any other specific configurations.

4. **Initialize Terraform**:
   Run the following command to initialize the Terraform project:
   ```bash
   terraform init
   ```

5. **Plan the deployment**:
   Generate an execution plan with:
   ```bash
   terraform plan
   ```

6. **Apply the configuration**:
   Deploy the infrastructure by running:
   ```bash
   terraform apply
   ```

7. **Access the Load Balancer**:
   After the deployment is complete, you can access your web servers through the load balancer's IP address, which will be displayed in the output.

## Cleanup

To remove all resources created by this project, run:
```bash
terraform destroy
```

## License

This project is licensed under the MIT License.