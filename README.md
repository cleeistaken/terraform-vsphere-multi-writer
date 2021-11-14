# terraform-vsphere-multi-writer
Sample code to deploy VM with shared disk on vSAN using Terraform. 

This code creates a content library and imports an OVA that will be used to create 
the test VMs. The first VM has additional data disks added with the sharing set to
multi-writer. All additional VM attach the data disks created in the first VM.

# Requirements
* Terraform v1.0.10

# Procedure
1. Copy terraform.tfvars.sample to terraform.tfvars
```bash
cp terraform.tfvars.sample terraform.tfvars
```

2. Edit and update the variables in terraform.tfvars

3. Initialize the project
```bash
terraform init
```

5. Validate the configuration
```bash
terraform plan -out=tfplan
```

7. Deploy
```bash
terraform apply "tfplan"
```

9. Destroy
```bash
terraform destroy
```
