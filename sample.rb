stack = Humidifier::Stack.new(name: "sample-stack", aws_template_format_version: "2010-09-09")

stack.add_parameter("VpcCidr", type: "String", no_echo: false)

vpc = Humidifier::EC2::VPC.new(
  cidr_block: Humidifier.ref("VpcCidr"),
  enable_dns_support: true,
  enable_dns_hostnames: true
)

stack.add('VPC', vpc)

stack.deploy_and_wait(parameters: [ { parameter_key: "VpcCidr", parameter_value: "10.0.0.0/16" } ])
