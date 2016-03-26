# tf_filemodule
Terraform plan to return input file name

## Variables

* `file`: The file name to return. Path can be full or relative

## Outputs

* `file`: Outputs `${var.file}`

## Use case
This terraform plan makes it so you can use interpolation on plan generated files. When you execute a plan that involves using content from generated files, use of the `file("")` interpolation fails because it doesn't exist at the start of the plan. Using this plan as a module allows you to have resources generate files for use in other resources.

Example:
```
aws_instance "chef-server" {
  # ...
  # ... create chef-server ...
  # ...
  # Harvest organziation private key
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no use@${aws_instance.server.public_ip}:/etc/chef/myorg-validator.pem ."
  }
}
module "filename" {
  source = "https://github.com/mengesb/tf_filemodule"
  file   = "myorg-validator.pem"
}
aws_instance "chef-node" {
  depends_on = ["aws_instance.server"]
  ...
  provisioner "chef" {
    attributes_json = "${file("...")}"
    environment     = "_default"
    run_list        = ["..."]
    node_name       = "${aws_instance.chef-node.tags.Name}"
    server_url      = "https://${aws_instance.chef-server.tags.Name}/organizations/${replace(module.filename.file, "-validator.pem", "")}"
    validation_client_name = "${replace(module.filename.file, ".pem", "")}"
    validation_key  = "${file("${module.filename.file}")}"
  }
}
```

The above harvests the validation PEM from a newly created Chef server and allows you to create a node using Chef provisioning from a generated item in the plan. Specifying `${file("myorg-validator.pem")}` would result in a Terraform error that the file could not be found until the server has been created.

## Contributing

Please refer to the [`CONTRIBUTING.md`](CONTRIBUTING.md)

## Contributors

* [Brian Menges](https://github.com/mengesb)

## `CHANGELOG`

Please refer to the [`CHANGELOG.md`](CHANGELOG.md)

## License

This is licensed under [the Apache 2.0 license](LICENSE).
