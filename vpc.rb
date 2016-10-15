# -*- coding: utf-8 -*-
require "humidifier"

class VPC

  ##
  #=== コンストラクタ
  def initialize(stack_name)
    @stack_name = stack_name
    stack.add_parameter("VpcCidr", type: "String", no_echo: false)
    stack.add("VPC", vpc)
    stack.add("Subnet1", subnet1)
    stack.add("Subnet2", subnet2)
    stack.add("InternetGateway", internet_gateway)
    stack.add("VPCGatewayAttachment", vpc_gateway_attachment)
    stack.add("PublicRouteTable", public_route_table)
    stack.add("PublicRoute", public_route)
    stack.add("Subnet1RouteTableAssociation", subnet1_route_table_association)
    stack.add("Subnet2RouteTableAssociation", subnet2_route_table_association)
    stack.add("PublicNetworkAcl", public_network_acl)
    stack.add("InboundHTTPPublicNetworkAclEntry", inbound_http_public_network_acl_entry)
    stack.add("InboundSSHPublicNetworkAclEntry", inbound_ssh_public_network_acl_entry)
    stack.add("InboundEphemeralPublicNetworkAclEntry", inbound_ephemeral_public_network_acl_entry)
    stack.add("OutboundPublicNetworkAclEntry", outbound_public_network_acl_entry)
    stack.add("Subnet1NetworkAclAssociation", subnet1_network_acl_association)
    stack.add("Subnet2NetworkAclAssociation", subnet2_network_acl_association)
    stack.add("DHCPOptions", dhcp_options)
    stack.add_output("VpcId", value: Humidifier.ref("VPC"))
    stack.add_output("Subnet1Id", value: Humidifier.ref("Subnet1"))
    stack.add_output("Subnet2Id", value: Humidifier.ref("Subnet2"))
  end

  ##
  #=== CloudFormationスタック
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-properties-stack.html AWS::CloudFormation::Stack
  def stack
    @stack ||= Humidifier::Stack.new(
      name: @stack_name,
      aws_template_format_version: "2010-09-09",
      description: "Sample CloudFormation Stack"
    )
  end

  private

  ##
  #=== VPC
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpc.html
  def vpc
    Humidifier::EC2::VPC.new(
      cidr_block: Humidifier.ref("VpcCidr"),
      enable_dns_support: true,
      enable_dns_hostnames: true
    )
  end

  ##
  #=== サブネット1
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet.html
  def subnet1
    Humidifier::EC2::Subnet.new(
      vpc_id: Humidifier.ref("VPC"),
      availability_zone: "ap-northeast-1b",
      cidr_block: "10.0.0.0/24"
    )
  end

  ##
  #=== サブネット2
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet.html
  def subnet2
    Humidifier::EC2::Subnet.new(
      vpc_id: Humidifier.ref("VPC"),
      availability_zone: "ap-northeast-1c",
      cidr_block: "10.0.2.0/24"
    )
  end

  ##
  #=== インターネットゲートウェイ
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-internet-gateway.html
  def internet_gateway
    Humidifier::EC2::InternetGateway.new
  end

  ##
  #=== VPCゲートウェイアタッチメント
  def vpc_gateway_attachment
    Humidifier::EC2::VPCGatewayAttachment.new(
      vpc_id: Humidifier.ref("VPC"),
      internet_gateway_id: Humidifier.ref("InternetGateway")
    )
  end

  ##
  #=== パブリックルートテーブル
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-route-table.html
  def public_route_table
    Humidifier::EC2::RouteTable.new(
      vpc_id: Humidifier.ref("VPC")
    )
  end

  ##
  #=== パブリックルート
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-route.html
  def public_route
    Humidifier::EC2::Route.new(
      route_table_id: Humidifier.ref("PublicRouteTable"),
      destination_cidr_block: "0.0.0.0/0",
      gateway_id: Humidifier.ref("InternetGateway")
    )
  end

  ##
  #=== サブネット1をルートテーブルに関連付け
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet-route-table-assoc.html
  def subnet1_route_table_association
    Humidifier::EC2::SubnetRouteTableAssociation.new(
      subnet_id: Humidifier.ref("Subnet1"),
      route_table_id: Humidifier.ref("PublicRouteTable")
    )
  end

  ##
  #=== サブネット2をルートテーブルに関連付け
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet-route-table-assoc.html
  def subnet2_route_table_association
    Humidifier::EC2::SubnetRouteTableAssociation.new(
      subnet_id: Humidifier.ref("Subnet2"),
      route_table_id: Humidifier.ref("PublicRouteTable")
    )
  end

  ##
  #=== サブネット2をルートテーブルに関連付け
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet-route-table-assoc.html
  def public_network_acl
    Humidifier::EC2::NetworkAcl.new(
      vpc_id: Humidifier.ref("VPC")
    )
  end

  ##
  #=== ネットワークACLにエントリ(http)を作成します
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-network-acl-entry.html
  def inbound_http_public_network_acl_entry
    Humidifier::EC2::NetworkAclEntry.new(
      network_acl_id: Humidifier.ref("PublicNetworkAcl"),
      rule_number: 100,
      protocol: 6,
      rule_action: "allow",
      egress: false,
      cidr_block: "0.0.0.0/0",
      port_range: { From: 80, To: 80 }
    )
  end

  ##
  #=== ネットワークACLにエントリ(ssh)を作成します
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-network-acl-entry.html
  def inbound_ssh_public_network_acl_entry
    Humidifier::EC2::NetworkAclEntry.new(
      network_acl_id: Humidifier.ref("PublicNetworkAcl"),
      rule_number: 102,
      protocol: 6,
      rule_action: "allow",
      egress: false,
      cidr_block: "0.0.0.0/0",
      port_range: { From: 22, To: 22 },
    )
  end

  ##
  #=== ネットワークACLにエントリ(エフェメラルポート)を作成します
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-network-acl-entry.html
  def inbound_ephemeral_public_network_acl_entry
    Humidifier::EC2::NetworkAclEntry.new(
      network_acl_id: Humidifier.ref("PublicNetworkAcl"),
      rule_number: 103,
      protocol: 6,
      rule_action: "allow",
      egress: false,
      cidr_block: "0.0.0.0/0",
      port_range: { From: 1024, To: 65535 },
    )
  end

  ##
  #=== ネットワークACLにエントリ(アウトバウンド)を作成します
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-network-acl-entry.html
  def outbound_public_network_acl_entry
    Humidifier::EC2::NetworkAclEntry.new(
      network_acl_id: Humidifier.ref("PublicNetworkAcl"),
      rule_number: 100,
      protocol: 6,
      rule_action: "allow",
      egress: true,
      cidr_block: "0.0.0.0/0",
      port_range: { From: 0, To: 65535 },
    )
  end

  ##
  #=== サブネット1をネットワーク ACL に関連付けます
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet-network-acl-assoc.html
  def subnet1_network_acl_association
    Humidifier::EC2::SubnetNetworkAclAssociation.new(
      subnet_id: Humidifier.ref("Subnet1"),
      network_acl_id: Humidifier.ref("PublicNetworkAcl")
    )
  end

  ##
  #=== サブネット2をネットワーク ACL に関連付けます
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet-network-acl-assoc.html
  def subnet2_network_acl_association
    Humidifier::EC2::SubnetNetworkAclAssociation.new(
      subnet_id: Humidifier.ref("Subnet2"),
      network_acl_id: Humidifier.ref("PublicNetworkAcl")
    )
  end

  ##
  #=== VPC 用の DHCP オプションセット
  # @see https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-dhcp-options.html
  def dhcp_options
    Humidifier::EC2::DHCPOptions.new(
      domain_name: "ap-northeast-1.compute.internal",
      domain_name_servers: [ "AmazonProvidedDNS" ]
    )
  end
end
