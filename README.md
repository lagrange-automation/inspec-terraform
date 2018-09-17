# Inspec Terraform outputs

InSpec resources for interacting with Terraform outputs.

## Examples

### Look up terraform outputs in the current directory

```
$ terraform output
app_engine_enabled = false
domain =
group_email =
project_bucket_self_link = []
project_bucket_url = []
project_id = dev-simple-service-msa-74ff
project_number = 870097726498
```

```ruby
describe terraform_outputs() do
  it { should exist }

  its('app_engine_enabled') { should eq "false" }
  its('project_number') { should eq "870097726498" }
end
```

### Look up terraform outputs in a different directory

```ruby
describe terraform_outputs(dir: "/opt/terraform/state") do
  its('app_engine_enabled') { should eq "false" }
  its('project_number') { should eq "870097726498" }
end
```

### Look up terraform outputs in a non-root module

```
$ terraform output -state dev-inspec-gcp
dev_host_project_id = dev-host-7e99
dev_host_project_number = 150809430813
dev_inspec_gcp_project_id = dev-inspec-gcp-94f7
dev_inspec_gcp_project_number = 584678632542
dev_service_msa_project_id = dev-service-msa-eef5
dev_service_msa_project_number = 343255259805
dev_simple_service_msa_project_id = dev-simple-service-msa-74ff
dev_simple_service_msa_project_number = 870097726498
```

```ruby
describe terraform_outputs(mod: "dev-inspec-gcp") do
  its('dev_host_project_id') { should eq "dev-host-7e99" }
end
```

### Use terraform outputs in multiple controls

```ruby
outputs = terraform_outputs()

# Test that a project exists, based on the terraform output
describe google_project(project: outputs.project_id) do
  it { should exist }
end

# Test that the GCP project API service account exists
describe google_service_account(
  name: "projects/#{outputs.project_id}/serviceAccounts/#{outputs.project_number}@cloudservices.gserviceaccount.com"
) do
  it { should exist }
end
```
