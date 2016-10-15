# coding: utf-8
require "rake"

stack_name = "sample-stack"
parameters = [
  { parameter_key: "VpcCidr", parameter_value: "10.0.0.0/16" }
]

namespace "VPC" do
  desc "VPCのデプロイ"
  task :deploy do
    require "./vpc"
    vpc = VPC.new(stack_name)
    vpc.stack.deploy_and_wait(parameters: parameters)
  end

  desc "VPCのチェンジセットの作成"
  task :create_change_set do
    require "./vpc"
    vpc = VPC.new(stack_name)
    vpc.stack.create_change_set(parameters: parameters)
  end

  desc "CloudFormationテンプレートの作成"
  task :template do
    require "./vpc"
    vpc = VPC.new(stack_name)
    puts vpc.stack.to_cf
  end
end
